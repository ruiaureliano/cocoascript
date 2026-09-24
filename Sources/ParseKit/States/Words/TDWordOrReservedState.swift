//
//  TDWordOrReservedState.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDWordOrReservedState)
public final class TDWordOrReservedState: TDWordState {

	@objc
	public var reservedWords = NSMutableSet()

	@objc
	public func addReservedWord(_ word: String) {
		reservedWords.add(word)
	}

	public override func nextToken(from reader: TDReader, startingWith character: Int, tokenizer: TDTokenizer) -> TDToken? {
		return nil
	}
}
