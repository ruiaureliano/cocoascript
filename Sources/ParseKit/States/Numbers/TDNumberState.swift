//
//  TDNumberState.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDNumberState)
open class TDNumberState: TDTokenizerState {

	@objc
	public var allowsTrailingDot = false
	internal var currentCharacter = -1
	internal var floatValue: CGFloat = 0
	internal var gotADigit = false
	internal var negative = false

	open override func nextToken(from reader: TDReader, startingWith character: Int, tokenizer: TDTokenizer) -> TDToken? {
		reset()
		negative = false
		let originalCharacter = character
		var current = character

		if current == 45 {
			negative = true
			current = reader.read()
			append(45)
		} else if current == 43 {
			current = reader.read()
			append(43)
		}

		reset(current)
		if currentCharacter == 46 {
			parseRightSide(from: reader)
		} else {
			parseLeftSide(from: reader)
			parseRightSide(from: reader)
		}

		if !gotADigit {
			if negative && currentCharacter != -1 {
				reader.unread()
			}

			return tokenizer.symbolState.nextToken(from: reader, startingWith: originalCharacter, tokenizer: tokenizer)
		}

		if currentCharacter != -1 {
			reader.unread()
		}

		if negative {
			floatValue = -floatValue
		}
		return TDToken.token(with: TDTokenTypeNumber, stringValue: bufferedString(), floatValue: value())
	}

	internal func value() -> CGFloat {
		return floatValue
	}

	internal func absorbDigits(from reader: TDReader, isFraction: Bool) -> CGFloat {
		var divideBy: CGFloat = 1
		var result: CGFloat = 0
		while currentCharacter >= 48 && currentCharacter <= 57 {
			append(currentCharacter)
			gotADigit = true
			result = result * 10 + CGFloat(currentCharacter - 48)
			currentCharacter = reader.read()
			if isFraction {
				divideBy *= 10
			}
		}
		if isFraction {
			return result / divideBy
		}

		return result
	}

	internal func parseLeftSide(from reader: TDReader) {
		floatValue = absorbDigits(from: reader, isFraction: false)
	}

	internal func parseRightSide(from reader: TDReader) {
		guard currentCharacter == 46 else {
			return
		}
		let next = reader.read()
		let nextIsDigit = next >= 48 && next <= 57
		if next != -1 {
			reader.unread()
		}

		guard nextIsDigit || allowsTrailingDot else {
			return
		}
		append(46)
		if nextIsDigit {
			currentCharacter = reader.read()
			floatValue += absorbDigits(from: reader, isFraction: true)
		}
	}

	internal func reset(_ character: Int) {
		gotADigit = false
		floatValue = 0
		currentCharacter = character
	}
}
