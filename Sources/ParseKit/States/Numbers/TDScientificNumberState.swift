//
//  TDScientificNumberState.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDScientificNumberState)
public final class TDScientificNumberState: TDNumberState {

	private var exponent: CGFloat = 0
	private var negativeExponent = false

	override internal func parseRightSide(from reader: TDReader) {
		super.parseRightSide(from: reader)
		guard currentCharacter == 101 || currentCharacter == 69 else {
			return
		}
		let marker = currentCharacter
		currentCharacter = reader.read()
		var hasExponent = currentCharacter >= 48 && currentCharacter <= 57
		negativeExponent = currentCharacter == 45
		let positiveExponent = currentCharacter == 43
		if !hasExponent && (negativeExponent || positiveExponent) {
			currentCharacter = reader.read()
			hasExponent = currentCharacter >= 48 && currentCharacter <= 57
		}
		if currentCharacter != -1 {
			reader.unread()
		}

		guard hasExponent else {
			return
		}

		append(marker)
		if negativeExponent {
			append(45)
		} else if positiveExponent {
			append(43)
		}
		currentCharacter = reader.read()
		exponent = absorbDigits(from: reader, isFraction: false)
	}

	override internal func reset(_ character: Int) {
		super.reset(character)
		exponent = 0
		negativeExponent = false
	}

	override internal func value() -> CGFloat {
		var result = floatValue
		for _ in 0..<Int(exponent) { result = negativeExponent ? result / 10 : result * 10 }
		return result
	}
}
