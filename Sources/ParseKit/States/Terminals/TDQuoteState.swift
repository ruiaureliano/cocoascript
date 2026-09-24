//
//  TDQuoteState.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDQuoteState)
public final class TDQuoteState: TDTokenizerState {

	@objc
	public var balancesEOFTerminatedQuotes = false

	public override func nextToken(from reader: TDReader, startingWith character: Int, tokenizer: TDTokenizer) -> TDToken? {
		reset()
		append(character)

		var current: Int
		repeat {
			current = reader.read()
			if current == -1 {
				current = character
				if balancesEOFTerminatedQuotes {
					append(current)
				}
			} else {
				append(current)
			}
		} while current != character

		return TDToken.token(with: TDTokenTypeQuotedString, stringValue: bufferedString(), floatValue: 0)
	}
}
