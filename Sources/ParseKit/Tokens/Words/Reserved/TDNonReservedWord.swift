//
//  TDNonReservedWord.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDNonReservedWord)
public final class TDNonReservedWord: TDWord {

	@objc(qualifies:)
	public override func qualifies(_ object: Any) -> Bool {
		guard
			let token = object as? TDToken,
			token.word,
			!token.stringValue.isEmpty
		else {
			return false
		}
		return !TDReservedWord.reservedWords().contains(token.stringValue)
	}
}
