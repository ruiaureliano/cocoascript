//
//  TDSpecificChar.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDSpecificChar)
public final class TDSpecificChar: TDTerminal {

	@objc
	public static func specificChar(withChar character: Int) -> TDSpecificChar {
		return TDSpecificChar(specificChar: character)
	}

	@objc
	public init(specificChar character: Int) {
		let scalar = UnicodeScalar(character) ?? UnicodeScalar(0)!
		super.init(string: String(scalar))
	}

	@objc(qualifies:)
	public override func qualifies(_ object: Any) -> Bool {
		guard
			let number = object as? NSNumber,
			let string,
			let first = string.utf16.first
		else {
			return false
		}
		return number.intValue == Int(first)
	}
}
