//
//  TDLetter.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDLetter)
public final class TDLetter: TDTerminal {

	@objc
	public static func letter() -> TDLetter {
		return TDLetter(string: nil)
	}

	@objc
	public override init(string: String?) {
		super.init(string: string)
	}

	@objc(qualifies:)
	public override func qualifies(_ object: Any) -> Bool {
		guard let number = object as? NSNumber else {
			return false
		}
		let value = number.intValue
		return (65...90).contains(value) || (97...122).contains(value)
	}
}
