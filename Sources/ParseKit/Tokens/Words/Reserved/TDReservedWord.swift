//
//  TDReservedWord.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDReservedWord)
public final class TDReservedWord: TDWord {

	nonisolated(unsafe) private static var words: [String] = []

	@objc
	public static func setReservedWords(_ words: [String]) {
		self.words = words
	}
	internal static func reservedWords() -> [String] { words }

	@objc(qualifies:)
	public override func qualifies(_ object: Any) -> Bool {
		guard
			let token = object as? TDToken,
			token.word,
			!token.stringValue.isEmpty
		else {
			return false
		}
		return Self.words.contains(token.stringValue)
	}
}
