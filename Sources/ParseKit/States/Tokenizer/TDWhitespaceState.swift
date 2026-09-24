//
//  TDWhitespaceState.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDWhitespaceState)
public final class TDWhitespaceState: TDTokenizerState {

	private var whitespaceCharacters = Array(repeating: false, count: 256)

	@objc
	public var reportsWhitespaceTokens = false

	public override init() {
		super.init()
		setWhitespaceChars(true, from: 0, to: 32)
	}

	@objc(isWhitespaceChar:)
	public func isWhitespaceChar(_ character: Int) -> Bool {
		return whitespaceCharacters.indices.contains(character) && whitespaceCharacters[character]
	}

	@objc(setWhitespaceChars:from:to:)
	public func setWhitespaceChars(_ value: Bool, from start: Int, to end: Int) {
		guard whitespaceCharacters.indices.contains(start),
			whitespaceCharacters.indices.contains(end), start <= end
		else {
			NSException(
				name: NSExceptionName("TDWhitespaceStateNotSupportedException"),
				reason: "TDWhitespaceState supports Latin-1 characters only", userInfo: nil
			).raise()
			return
		}
		for index in start...end {
			whitespaceCharacters[index] = value
		}
	}

	public override func nextToken(from reader: TDReader, startingWith character: Int, tokenizer: TDTokenizer) -> TDToken? {
		if reportsWhitespaceTokens {
			reset()
		}

		var current = character
		while isWhitespaceChar(current) {
			if reportsWhitespaceTokens {
				append(current)
			}
			current = reader.read()
		}
		if current != -1 {
			reader.unread()
		}

		if reportsWhitespaceTokens {
			return TDToken.token(with: TDTokenTypeWhitespace, stringValue: bufferedString(), floatValue: 0)
		}
		return tokenizer.nextToken()
	}
}
