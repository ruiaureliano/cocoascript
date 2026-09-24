//
//  TDUppercaseWord.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDUppercaseWord)
public final class TDUppercaseWord: TDWord {

	@objc(qualifies:)
	public override func qualifies(_ object: Any) -> Bool {
		guard
			let token = object as? TDToken,
			token.word,
			let first = token.stringValue.utf16.first
		else {
			return false
		}
		return (65...90).contains(Int(first))
	}
}
