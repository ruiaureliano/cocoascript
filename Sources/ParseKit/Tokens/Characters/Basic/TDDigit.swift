//
//  TDDigit.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDDigit)
public final class TDDigit: TDTerminal {

	@objc
	public static func digit() -> TDDigit {
		return TDDigit(string: nil)
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
		return (48...57).contains(number.intValue)
	}
}
