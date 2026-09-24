//
//  TDWordState.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDWordState)
public class TDWordState: TDTokenizerState {

	private var wordCharacters = [Bool](repeating: false, count: 256)

	public override init() {
		super.init()
		setWordChars(true, from: 97, to: 122)
		setWordChars(true, from: 65, to: 90)
		setWordChars(true, from: 48, to: 57)
		setWordChars(true, from: 45, to: 45)
		setWordChars(true, from: 95, to: 95)
		setWordChars(true, from: 39, to: 39)
		setWordChars(true, from: 0xC0, to: 0xFF)
	}

	@objc(setWordChars:from:to:)
	public func setWordChars(_ enabled: Bool, from start: Int, to end: Int) {
		guard
			start >= 0,
			end >= 0,
			start < wordCharacters.count,
			end < wordCharacters.count
		else {
			fatalError("TDWordState only supports Latin-1 word characters")
		}
		for index in start...end {
			wordCharacters[index] = enabled
		}
	}

	@objc(isWordChar:)
	public func isWordChar(_ character: Int) -> Bool {
		if character >= 0 && character < wordCharacters.count - 1 {
			return wordCharacters[character]
		}

		if (0x2000...0x2BFF).contains(character) || (0xFE30...0xFE6F).contains(character) || (0xFF00...0xFF65).contains(character) || (0xFFF0...0xFFFF).contains(character) || character < 0 {
			return false
		}

		return true
	}

	public override func nextToken(from reader: TDReader, startingWith character: Int, tokenizer: TDTokenizer) -> TDToken? {
		reset()
		var current = character
		repeat {
			append(current)
			current = reader.read()
		} while isWordChar(current)
		if current != -1 {
			reader.unread()
		}
		return TDToken.token(with: TDTokenTypeWord, stringValue: bufferedString(), floatValue: 0)
	}
}
