//
//  TDLowercaseWord.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDLowercaseWord)
public final class TDLowercaseWord: TDWord {

	@objc(qualifies:)
	public override func qualifies(_ object: Any) -> Bool {
		guard
			let token = object as? TDToken,
			token.word,
			let first = token.stringValue.utf16.first
		else {
			return false
		}
		return (97...122).contains(Int(first))
	}
}
