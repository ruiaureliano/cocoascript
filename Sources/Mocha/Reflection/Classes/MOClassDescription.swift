//
//  MOClassDescription.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/26/12.
//  Copyright (c) 2012 Logan Collins. All rights reserved.
//

import Foundation
import ObjectiveC.runtime

@objc(MOClassDescription)
public final class MOClassDescription: NSObject {

	private let objectClass: AnyClass
	private var isRegistered: Bool

	@objc
	public static func description(forClassWithName name: String) -> MOClassDescription? {
		guard let objectClass = NSClassFromString(name) else {
			return nil
		}
		return MOClassDescription(objectClass: objectClass)
	}

	@objc
	public static func description(forClass objectClass: AnyClass) -> MOClassDescription {
		return MOClassDescription(objectClass: objectClass, registered: true)
	}

	@objc
	public init(objectClass: AnyClass) {
		self.objectClass = objectClass
		self.isRegistered = true
		super.init()
	}

	@objc
	public static func allocateDescription(forClassWithName name: String, superclass: AnyClass?) -> MOClassDescription? {
		guard NSClassFromString(name) == nil else {
			return nil
		}
		let objectClass: AnyClass? = name.withCString { objc_allocateClassPair(superclass, $0, 0) }
		guard let objectClass else {
			return nil
		}
		return MOClassDescription(objectClass: objectClass, registered: false)
	}

	@objc
	public func registerClass() -> AnyClass {
		guard !isRegistered else {
			return objectClass
		}
		objc_registerClassPair(objectClass)
		isRegistered = true
		return objectClass
	}

	@objc
	public var name: String {
		return String(cString: class_getName(objectClass))
	}

	@objc
	public var descriptedClass: AnyClass {
		return objectClass
	}

	@objc public var superclassDescription: MOClassDescription? {
		guard let superclass = class_getSuperclass(objectClass) else {
			return nil
		}
		return MOClassDescription(objectClass: superclass)
	}

	@objc public var ancestors: [MOClassDescription] {
		var result: [MOClassDescription] = []
		var current: AnyClass? = class_getSuperclass(objectClass)
		while let superclass = current {
			result.append(MOClassDescription(objectClass: superclass))
			current = class_getSuperclass(superclass)
		}
		return result
	}

	@objc public var instanceVariables: [MOInstanceVariableDescription] {
		var count: UInt32 = 0
		guard let ivars = class_copyIvarList(objectClass, &count) else {
			return []
		}
		defer { free(UnsafeMutableRawPointer(ivars)) }

		return (0..<Int(count)).map { index in
			let ivar = ivars[index]
			return MOInstanceVariableDescription(
				name: string(from: ivar_getName(ivar)),
				typeEncoding: string(from: ivar_getTypeEncoding(ivar))
			)
		}
	}

	@objc
	public var instanceVariablesWithAncestors: [MOInstanceVariableDescription] {
		return instanceVariables + ancestors.flatMap { $0.instanceVariables }
	}

	@objc public func addInstanceVariable(withName name: String, typeEncoding: String) -> Bool {
		guard
			!isRegistered,
			let encoding = typeEncoding.utf8.first
		else {
			return false
		}
		let layout = layout(for: encoding)
		return name.withCString { namePointer in
			typeEncoding.withCString { encodingPointer in
				class_addIvar(objectClass, namePointer, layout.size, layout.alignment, encodingPointer)
			}
		}
	}

	@objc public func addClassMethod(withSelector selector: Selector, typeEncoding: String, block: Any) -> Bool {
		let implementation = imp_implementationWithBlock(block)
		return typeEncoding.withCString { encoding in
			class_addMethod(object_getClass(objectClass), selector, implementation, encoding)
		}
	}

	@objc public func addInstanceMethod(withSelector selector: Selector, typeEncoding: String, block: Any) -> Bool {
		let implementation = imp_implementationWithBlock(block)
		return typeEncoding.withCString { encoding in
			class_addMethod(objectClass, selector, implementation, encoding)
		}
	}

	@objc
	public var instanceMethods: [MOMethodDescription] {
		return methodDescriptions(for: objectClass)
	}

	@objc
	public var instanceMethodsWithAncestors: [MOMethodDescription] {
		return instanceMethods + ancestors.flatMap { $0.instanceMethods }
	}

	@objc
	public var classMethods: [MOMethodDescription] {
		return methodDescriptions(for: object_getClass(objectClass))
	}

	@objc public var classMethodsWithAncestors: [MOMethodDescription] {
		var result: [MOMethodDescription] = []
		var current: AnyClass? = object_getClass(objectClass)
		while let metaclass = current {
			result.append(contentsOf: methodDescriptions(for: metaclass))
			current = class_getSuperclass(metaclass)
		}
		return result
	}

	@objc public var properties: [MOPropertyDescription] {
		var count: UInt32 = 0
		guard let properties = class_copyPropertyList(objectClass, &count) else {
			return []
		}
		defer { free(UnsafeMutableRawPointer(properties)) }

		return (0..<Int(count)).map { index in
			let property = MOPropertyDescription()
			let objcProperty = properties[index]
			property.name = String(cString: property_getName(objcProperty))
			apply(attributes: property_getAttributes(objcProperty), to: property)
			return property
		}
	}

	@objc
	public var propertiesWithAncestors: [MOPropertyDescription] {
		return properties + ancestors.flatMap { $0.properties }
	}

	@objc public func addProperty(_ property: MOPropertyDescription) -> Bool {
		guard
			let name = property.name,
			!name.isEmpty,
			let typeEncoding = property.typeEncoding
		else {
			return false
		}

		return name.withCString { namePointer in
			var allocatedPointers: [(UnsafeMutablePointer<CChar>, UnsafeMutablePointer<CChar>)] = []
			defer {
				for (namePointer, valuePointer) in allocatedPointers {
					free(namePointer)
					free(valuePointer)
				}
			}

			func attribute(name: String, value: String) -> objc_property_attribute_t {
				let namePointer = strdup(name)!
				let valuePointer = strdup(value)!
				allocatedPointers.append((namePointer, valuePointer))
				return objc_property_attribute_t(name: namePointer, value: valuePointer)
			}

			var attributes = [attribute(name: "T", value: typeEncoding)]
			if property.isReadOnly {
				attributes.append(attribute(name: "R", value: ""))
			}
			if property.isNonAtomic {
				attributes.append(attribute(name: "N", value: ""))
			}
			if property.isDynamic {
				attributes.append(attribute(name: "D", value: ""))
			}
			return attributes.withUnsafeBufferPointer { buffer in
				class_addProperty(objectClass, namePointer, buffer.baseAddress, UInt32(buffer.count))
			}
		}
	}

	@objc public func addProtocol(_ protocolDescription: MOProtocolDescription) {
		class_addProtocol(objectClass, protocolDescription.objectProtocolReference)
	}

	public override var description: String {
		return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque()) : class=\(name)>"
	}

	private func methodDescriptions(for objectClass: AnyClass?) -> [MOMethodDescription] {
		guard let objectClass else {
			return []
		}
		var count: UInt32 = 0
		guard let methods = class_copyMethodList(objectClass, &count) else {
			return []
		}
		defer { free(UnsafeMutableRawPointer(methods)) }

		return (0..<Int(count)).map { index in
			let method = methods[index]
			return MOMethodDescription(
				selector: method_getName(method),
				typeEncoding: string(from: method_getTypeEncoding(method))
			)
		}
	}

	private func string(from pointer: UnsafePointer<CChar>?) -> String {
		guard let pointer else {
			return ""
		}
		return String(cString: pointer)
	}

	private func apply(attributes: UnsafePointer<CChar>?, to property: MOPropertyDescription) {
		guard let attributes else {
			return
		}
		let values = String(cString: attributes).split(separator: ",", omittingEmptySubsequences: false)
		for value in values {
			switch value.first {
			case "R":
				property.isReadOnly = true
			case "C":
				property.ownershipRule = .copy
			case "&":
				property.ownershipRule = .retain
			case "N":
				property.isNonAtomic = true
			case "D":
				property.isDynamic = true
			case "W":
				property.isWeak = true
			case "T":
				property.typeEncoding = String(value.dropFirst())
			case "V":
				property.ivarName = String(value.dropFirst())
			case "G":
				property.getterSelector = NSSelectorFromString(String(value.dropFirst()))
			case "S":
				property.setterSelector = NSSelectorFromString(String(value.dropFirst()))
			default:
				break
			}
		}
	}

	private func layout(for encoding: UInt8) -> (size: Int, alignment: UInt8) {
		switch Character(UnicodeScalar(encoding)) {
		case "c", "C", "B":
			return (MemoryLayout<UInt8>.size, UInt8(MemoryLayout<UInt8>.alignment))
		case "s", "S":
			return (MemoryLayout<Int16>.size, UInt8(MemoryLayout<Int16>.alignment))
		case "i", "I":
			return (MemoryLayout<Int32>.size, UInt8(MemoryLayout<Int32>.alignment))
		case "q", "Q":
			return (MemoryLayout<Int64>.size, UInt8(MemoryLayout<Int64>.alignment))
		case "f":
			return (MemoryLayout<Float>.size, UInt8(MemoryLayout<Float>.alignment))
		case "d":
			return (MemoryLayout<Double>.size, UInt8(MemoryLayout<Double>.alignment))
		case "@", "#", ":", "*", "^":
			return (MemoryLayout<UnsafeRawPointer>.size, UInt8(MemoryLayout<UnsafeRawPointer>.alignment))
		default:
			return (MemoryLayout<UnsafeRawPointer>.size, UInt8(MemoryLayout<UnsafeRawPointer>.alignment))
		}
	}

	private convenience init(objectClass: AnyClass, registered: Bool) {
		self.init(objectClass: objectClass)
		self.isRegistered = registered
	}
}
