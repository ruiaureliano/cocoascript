//
//  TDCaseInsensitiveLiteral.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDCaseInsensitiveLiteral)
public final class TDCaseInsensitiveLiteral: TDLiteral {

	@objc
	public override init(string: String?) {
		super.init(string: string)
	}

	@objc(qualifies:)
	public override func qualifies(_ object: Any) -> Bool {
		guard
			let literalToken,
			let token = object as? TDToken
		else {
			return false
		}
		return literalToken.stringValue.caseInsensitiveCompare(token.stringValue) == .orderedSame
	}
}
