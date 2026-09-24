//
//  TDSymbolState.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDSymbolState)
public final class TDSymbolState: TDTokenizerState {

	@objc
	public var rootNode = TDSymbolRootNode()
	@objc
	public var addedSymbols = NSMutableArray()

	public override func nextToken(from reader: TDReader, startingWith character: Int, tokenizer: TDTokenizer) -> TDToken? {
		let symbol = rootNode.nextSymbol(reader, startingWith: character) ?? ""
		let length = symbol.utf16.count
		if length == 0 || (length > 1 && addedSymbols.contains(symbol)) {
			return TDToken.token(with: TDTokenTypeSymbol, stringValue: symbol, floatValue: 0)
		}

		for _ in 0..<max(length - 1, 0) {
			reader.unread()
		}
		let value = String(UnicodeScalar(character) ?? UnicodeScalar(0))
		return TDToken.token(with: TDTokenTypeSymbol, stringValue: value, floatValue: 0)
	}

	@objc
	public func add(_ symbol: String) {
		guard !symbol.isEmpty else {
			return
		}

		rootNode.add(symbol)
		addedSymbols.add(symbol)
	}

	@objc
	public func remove(_ symbol: String) {
		guard !symbol.isEmpty else {
			return
		}

		rootNode.remove(symbol)
		addedSymbols.remove(symbol)
	}
}
