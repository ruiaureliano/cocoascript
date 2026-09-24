//
//  TDCharacterAssembly.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDCharacterAssembly)
public final class TDCharacterAssembly: TDAssembly {

	@objc
	public override init() {
		super.init()
		defaultDelimiter = ""
	}

	@objc(initWithString:)
	public override init(string: String?) {
		super.init(string: string)
		defaultDelimiter = ""
	}

	public override func peek() -> Any? {
		guard
			let string,
			index < string.utf16.count
		else {
			return nil
		}
		return NSNumber(value: Int(string.utf16[string.utf16.index(string.utf16.startIndex, offsetBy: index)]))
	}
	public override func next() -> Any? {
		let value = peek()
		if value != nil {
			index += 1
		}
		return value
	}
	public override func hasMore() -> Bool {
		return index < (string?.utf16.count ?? 0)
	}

	public override var length: UInt {
		return UInt(string?.utf16.count ?? 0)
	}

	public override var objectsConsumed: UInt {
		return UInt(index)
	}

	public override var objectsRemaining: UInt {
		return UInt((string?.utf16.count ?? 0) - index)
	}

	public override func consumedObjectsJoined(by delimiter: String) -> String {
		return String(string?.prefix(index) ?? "")
	}

	public override func remainingObjectsJoined(by delimiter: String) -> String {
		return String(string?.dropFirst(index) ?? "")
	}

	public override var description: String {
		let values = stack.map { value -> String in
			if let number = value as? NSNumber {
				return String(UnicodeScalar(number.intValue) ?? UnicodeScalar(0))
			}
			return String(describing: value)
		}.joined()
		return "[\(values)]\(consumedObjectsJoined(by: defaultDelimiter ?? ""))^\(remainingObjectsJoined(by: defaultDelimiter ?? ""))"
	}
}
