//
//  TDTokenizerState.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDTokenizerState)
open class TDTokenizerState: NSObject {

	private var buffer = ""
	@objc
	public func reset() {
		buffer = ""
	}

	@objc
	public func append(_ character: Int) {
		buffer.append(Character(UnicodeScalar(character) ?? UnicodeScalar(0)))
	}

	@objc(appendString:)
	public func appendString(_ string: String) {
		buffer.append(contentsOf: string)
	}

	@objc
	public func bufferedString() -> String {
		return buffer
	}
	open func nextToken(from reader: TDReader, startingWith character: Int, tokenizer: TDTokenizer) -> TDToken? {
		fatalError("TDTokenizerState.nextToken must be overridden")
	}
}
