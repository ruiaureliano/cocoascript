//
//  TDSingleLineCommentState.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDSingleLineCommentState)
public final class TDSingleLineCommentState: TDTokenizerState {

	@objc
	public var startSymbols = NSMutableArray()
	@objc
	public var currentStartSymbol: String?

	@objc
	public func addStartSymbol(_ start: String) {
		guard !start.isEmpty else {
			return
		}

		startSymbols.add(start)
	}

	@objc
	public func removeStartSymbol(_ start: String) {
		guard !start.isEmpty else {
			return
		}

		startSymbols.remove(start)
	}

	public override func nextToken(from reader: TDReader, startingWith character: Int, tokenizer: TDTokenizer) -> TDToken? {
		let reportTokens = (tokenizer.commentState.value(forKey: "reportsCommentTokens") as? Bool) ?? false
		if reportTokens {
			reset()
			if let symbol = currentStartSymbol, symbol.count > 1 {
				appendString(symbol)
			}
		}

		var current: Int
		repeat {
			current = reader.read()
			if current == 10 || current == 13 || current == -1 {
				break
			}

			if reportTokens {
				append(current)
			}
		} while true

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
