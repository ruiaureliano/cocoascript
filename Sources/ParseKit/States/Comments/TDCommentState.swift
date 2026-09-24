//
//  TDCommentState.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDCommentState)
public final class TDCommentState: TDTokenizerState {

	@objc
	public var rootNode = TDSymbolRootNode()
	@objc
	public var singleLineState = TDSingleLineCommentState()
	@objc
	public var multiLineState = TDMultiLineCommentState()
	@objc
	public var reportsCommentTokens = false
	@objc
	public var balancesEOFTerminatedComments = false

	@objc
	public func addSingleLineStartSymbol(_ start: String) {
		guard !start.isEmpty else {
			return
		}
		rootNode.add(start)
		singleLineState.addStartSymbol(start)
	}

	@objc
	public func removeSingleLineStartSymbol(_ start: String) {
		guard !start.isEmpty else {
			return
		}
		rootNode.remove(start)
		singleLineState.removeStartSymbol(start)
	}

	@objc public func addMultiLineStartSymbol(_ start: String, endSymbol end: String) {
		guard
			!start.isEmpty,
			!end.isEmpty
		else {
			return
		}
		rootNode.add(start)
		rootNode.add(end)
		multiLineState.addStartSymbol(start, endSymbol: end)
	}

	@objc
	public func removeMultiLineStartSymbol(_ start: String) {
		guard !start.isEmpty else {
			return
		}
		rootNode.remove(start)
		multiLineState.removeStartSymbol(start)
	}

	public override func nextToken(from reader: TDReader, startingWith character: Int, tokenizer: TDTokenizer) -> TDToken? {
		let symbol = rootNode.nextSymbol(reader, startingWith: character) ?? ""

		if multiLineState.startSymbols.contains(symbol) {
			multiLineState.currentStartSymbol = symbol
			return multiLineState.nextToken(from: reader, startingWith: character, tokenizer: tokenizer)
		}
		if singleLineState.startSymbols.contains(symbol) {
			singleLineState.currentStartSymbol = symbol
			return singleLineState.nextToken(from: reader, startingWith: character, tokenizer: tokenizer)
		}

		for _ in 0..<max(symbol.utf16.count - 1, 0) {
			reader.unread()
		}
		let value = String(UnicodeScalar(character) ?? UnicodeScalar(0))
		return TDToken.token(with: TDTokenTypeSymbol, stringValue: value, floatValue: 0)
	}
}
