//
//  MOFunctionArgument.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/13/12.
//  Copyright 2012 Logan Collins. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc(MOFunctionArgument)
public final class MOFunctionArgument: NSObject {

	@objc public var typeEncoding: Int8 = 0
	@objc public var pointerTypeEncoding: String?
	@objc public var structureTypeEncoding: String?
	@objc public var pointer: MOPointer?
	@objc public var isReturnValue = false
	@objc public private(set) var storage: UnsafeMutableRawPointer?

	deinit {
		if let storage {
			storage.deallocate()
		}
	}

	@objc public func setTypeEncoding(_ encoding: Int8, withCustomStorage storage: UnsafeMutableRawPointer?) {
		guard Self.getSize(forTypeEncoding: encoding) != nil else {
			return
		}
		typeEncoding = encoding
		pointerTypeEncoding = nil
		structureTypeEncoding = nil
		setStorage(storage, size: Self.getSize(forTypeEncoding: encoding) ?? 0)
	}

	@objc public func setPointerTypeEncoding(_ encoding: String?, withCustomStorage storage: UnsafeMutableRawPointer?) {
		typeEncoding = Int8(ascii: "^")
		pointerTypeEncoding = encoding
		structureTypeEncoding = nil
		setStorage(storage, size: MemoryLayout<UnsafeRawPointer>.size)
	}

	@objc public func setStructureTypeEncoding(_ encoding: String?, withCustomStorage storage: UnsafeMutableRawPointer?) {
		typeEncoding = Int8(ascii: "{")
		pointerTypeEncoding = nil
		structureTypeEncoding = encoding
		setStorage(storage, size: Self.sizeOfStructureTypeEncoding(encoding ?? ""))
	}

	private func setStorage(_ customStorage: UnsafeMutableRawPointer?, size: Int) {
		if storage == nil, let customStorage {
			storage = customStorage
			return
		}
		if storage != nil {
			storage?.deallocate()
		}
		storage = size > 0 ? UnsafeMutableRawPointer.allocate(byteCount: size, alignment: max(1, size)) : nil
	}

	@objc public var typeDescription: String {
		return Self.description(ofTypeEncoding: typeEncoding, fullTypeEncoding: structureTypeEncoding)
	}

	@objc public func getValueAsJSValue(inContext context: JSContextRef) -> JSValueRef? {
		guard let storage else {
			return nil
		}
		return Self.toJSValue(inContext: context, typeEncoding: typeEncoding, storage: storage)
	}

	@objc public func setValueAsJSValue(_ value: JSValueRef?, context: JSContextRef) {
		guard let value, let storage else {
			return
		}
		Self.fromJSValue(value, inContext: context, typeEncoding: typeEncoding, storage: storage)
	}

	public static func getAlignment(forTypeEncoding encoding: Int8) -> Int? {
		switch Character(UnicodeScalar(UInt8(bitPattern: encoding))) {
		case "c", "C", "B":
			return MemoryLayout<UInt8>.alignment
		case "s", "S":
			return MemoryLayout<Int16>.alignment
		case "i", "I":
			return MemoryLayout<Int32>.alignment
		case "q", "Q":
			return MemoryLayout<Int64>.alignment
		case "f":
			return MemoryLayout<Float>.alignment
		case "d":
			return MemoryLayout<Double>.alignment
		case "@", "#", ":", "*", "^":
			return MemoryLayout<UnsafeRawPointer>.alignment
		default:
			return nil
		}
	}

	public static func getSize(forTypeEncoding encoding: Int8) -> Int? {
		switch Character(UnicodeScalar(UInt8(bitPattern: encoding))) {
		case "c", "C", "B":
			return MemoryLayout<UInt8>.size
		case "s", "S":
			return MemoryLayout<Int16>.size
		case "i", "I":
			return MemoryLayout<Int32>.size
		case "q", "Q":
			return MemoryLayout<Int64>.size
		case "f":
			return MemoryLayout<Float>.size
		case "d":
			return MemoryLayout<Double>.size
		case "@", "#", ":", "*", "^":
			return MemoryLayout<UnsafeRawPointer>.size
		default:
			return nil
		}
	}

	@objc public static func description(ofTypeEncoding encoding: Int8, fullTypeEncoding: String? = nil) -> String {
		let character = Character(UnicodeScalar(UInt8(bitPattern: encoding)))
		switch character {
		case "c", "C":
			return "char"
		case "B":
			return "BOOL"
		case "s", "S":
			return "short"
		case "i", "I":
			return "int"
		case "q", "Q":
			return "long long"
		case "f":
			return "float"
		case "d":
			return "double"
		case "@":
			return "object"
		case "#":
			return "class"
		case ":":
			return "selector"
		case "*":
			return "string"
		case "^":
			return "pointer"
		case "{":
			return structureTypeEncodingDescription(fullTypeEncoding ?? "")
		default:
			return "unknown"
		}
	}

	@objc public static func sizeOfStructureTypeEncoding(_ encoding: String) -> Int {
		return typeEncodings(fromStructureTypeEncoding: encoding).reduce(0) { result, type in
			result + (type.utf8.first.flatMap { getSize(forTypeEncoding: Int8(bitPattern: $0)) } ?? 0)
		}
	}

	public static func alignPointer(_ pointer: UnsafeMutablePointer<UnsafeMutableRawPointer?>, accordingToEncoding encoding: Int8) {
		guard
			let alignment = getAlignment(forTypeEncoding: encoding),
			alignment > 1,
			let rawPointer = pointer.pointee
		else {
			return
		}
		let address = UInt(bitPattern: rawPointer)
		let alignedAddress = (address + UInt(alignment - 1)) & ~UInt(alignment - 1)
		pointer.pointee = UnsafeMutableRawPointer(bitPattern: alignedAddress)
	}

	public static func advancePointer(_ pointer: UnsafeMutablePointer<UnsafeMutableRawPointer?>, accordingToEncoding encoding: Int8) {
		guard
			let size = getSize(forTypeEncoding: encoding),
			let rawPointer = pointer.pointee
		else {
			return
		}
		pointer.pointee = rawPointer.advanced(by: size)
	}

	@objc public static func typeEncodings(fromStructureTypeEncoding encoding: String) -> [String] {
		var result = [String]()
		var current = ""
		for character in encoding {
			if character == "{" || character == "}" || character == "=" || character == "," || character == " " {
				continue
			}
			if current.isEmpty {
				current = String(character)
				result.append(current)
				current.removeAll()
			}
		}
		return result
	}

	@objc public static func structureName(fromStructureTypeEncoding encoding: String) -> String {
		guard let start = encoding.firstIndex(of: "{") else {
			return encoding
		}
		let value = encoding[encoding.index(after: start)...]
		return String(value.split(whereSeparator: { $0 == "=" || $0 == "}" }).first ?? Substring())
	}

	public static func structureFullTypeEncoding(fromStructureTypeEncoding encoding: String) -> String {
		guard let equals = encoding.firstIndex(of: "=") else {
			return encoding
		}
		var result = String(encoding[equals...])
		while result.last == "}" {
			result.removeLast()
		}
		return result
	}

	public static func structureFullTypeEncoding(fromStructureName name: String) -> String? {
		return name.isEmpty ? nil : "{\(name)=}"
	}

	@objc public static func structureTypeEncodingDescription(_ encoding: String) -> String {
		return structureName(fromStructureTypeEncoding: encoding)
	}

	private static func toJSValue(inContext context: JSContextRef, typeEncoding: Int8, storage: UnsafeMutableRawPointer) -> JSValueRef? {
		switch Character(UnicodeScalar(UInt8(bitPattern: typeEncoding))) {
		case "c", "C", "B":
			return JSValueMakeNumber(context, Double(storage.load(as: UInt8.self)))
		case "s", "S":
			return JSValueMakeNumber(context, Double(storage.load(as: Int16.self)))
		case "i", "I":
			return JSValueMakeNumber(context, Double(storage.load(as: Int32.self)))
		case "q", "Q":
			return JSValueMakeNumber(context, Double(storage.load(as: Int64.self)))
		case "f":
			return JSValueMakeNumber(context, Double(storage.load(as: Float.self)))
		case "d":
			return JSValueMakeNumber(context, storage.load(as: Double.self))
		default:
			return nil
		}
	}

	private static func fromJSValue(_ value: JSValueRef, inContext context: JSContextRef, typeEncoding: Int8, storage: UnsafeMutableRawPointer) {
		var exception: JSValueRef?
		let number = JSValueToNumber(context, value, &exception)
		switch Character(UnicodeScalar(UInt8(bitPattern: typeEncoding))) {
		case "c", "C", "B":
			storage.storeBytes(of: UInt8(number), as: UInt8.self)
		case "s", "S":
			storage.storeBytes(of: Int16(number), as: Int16.self)
		case "i", "I":
			storage.storeBytes(of: Int32(number), as: Int32.self)
		case "q", "Q":
			storage.storeBytes(of: Int64(number), as: Int64.self)
		case "f":
			storage.storeBytes(of: Float(number), as: Float.self)
		case "d":
			storage.storeBytes(of: number, as: Double.self)
		default:
			break
		}
	}
}

extension Int8 {

	fileprivate init(ascii character: Character) {
		self = Int8(character.asciiValue ?? 0)
	}
}
