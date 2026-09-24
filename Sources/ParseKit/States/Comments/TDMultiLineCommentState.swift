//
//  TDMultiLineCommentState.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDMultiLineCommentState)
public final class TDMultiLineCommentState: TDTokenizerState {

	@objc
	public var startSymbols = NSMutableArray()
	@objc
	public var endSymbols = NSMutableArray()
	@objc
	public var currentStartSymbol: String?

	@objc public func addStartSymbol(_ start: String, endSymbol end: String) {
		guard
			!start.isEmpty,
			!end.isEmpty
		else {
			return
		}
		startSymbols.add(start)
		endSymbols.add(end)
	}

	@objc public func removeStartSymbol(_ start: String) {
		let index = startSymbols.index(of: start)
		guard index != NSNotFound else {
			return
		}
		startSymbols.removeObject(at: index)
		endSymbols.removeObject(at: index)
	}

	private func unreadSymbol(_ symbol: String, from reader: TDReader) {
		for _ in 0..<(max(symbol.utf16.count - 1, 0)) {
			reader.unread()
		}
	}

	public override func nextToken(from reader: TDReader, startingWith character: Int, tokenizer: TDTokenizer) -> TDToken? {
		let commentState = tokenizer.commentState
		let balanceEOF = (commentState.value(forKey: "balancesEOFTerminatedComments") as? Bool) ?? false
		let reportTokens = (commentState.value(forKey: "reportsCommentTokens") as? Bool) ?? false

		if reportTokens {
			reset()
			if let symbol = currentStartSymbol {
				appendString(symbol)
			}
		}

		guard
			let start = currentStartSymbol,
			startSymbols.index(of: start) != NSNotFound,
			let startIndex = Optional(startSymbols.index(of: start)),
			let end = endSymbols.object(at: startIndex) as? String,
			let endCharacter = end.utf16.first
		else {
			currentStartSymbol = nil
			return tokenizer.nextToken()
		}

		let root = commentState.value(forKey: "rootNode") as? TDSymbolRootNode
		var current = 0
		while true {
			current = reader.read()
			if current == -1 {
				if balanceEOF {
					appendString(end)
				}
				break
			}

			if current == Int(endCharacter), let root {
				let peek = root.nextSymbol(reader, startingWith: current)
				if peek == end {
					if reportTokens {
						appendString(end)
					}
					current = reader.read()
					break
				} else if let peek {
					unreadSymbol(peek, from: reader)
					if endCharacter != peek.utf16.first {
						if reportTokens {
							append(current)
						}
						current = reader.read()
					}
				}
			}
			if reportTokens {
				append(current)
			}
		}

		if current != -1 {
			reader.unread()
		}
		currentStartSymbol = nil
		if reportTokens {
			return TDToken.token(with: TDTokenTypeComment, stringValue: bufferedString(), floatValue: 0)
		}
		return tokenizer.nextToken()
	}
}
