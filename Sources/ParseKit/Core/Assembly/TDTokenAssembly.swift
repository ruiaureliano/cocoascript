//
//  TDTokenAssembly.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDTokenAssembly)
public final class TDTokenAssembly: TDAssembly {

	private var tokenizer: TDTokenizer?
	private var tokenList: [TDToken]?
	@objc
	public var preservesWhitespaceTokens = false

	@objc(assemblyWithTokenizer:)
	public static func assembly(with tokenizer: TDTokenizer) -> TDTokenAssembly {
		return TDTokenAssembly(tokenizer: tokenizer)
	}

	@objc
	public static func assembly(withTokenArray tokens: [TDToken]) -> TDTokenAssembly {
		return TDTokenAssembly(tokens: tokens)
	}
	@objc(initWithTokenzier:)
	public init(tokenizer: TDTokenizer) {
		self.tokenizer = tokenizer
		super.init(string: tokenizer.string)
	}
	@objc(initWithTokenArray:)
	public init(tokens: [TDToken]) {
		self.tokenList = tokens
		super.init(string: tokens.map(\.stringValue).joined())
	}
	@objc
	public override init() {
		super.init()
	}

	private var tokens: [TDToken] {
		if let tokenList {
			return tokenList
		}
		var result = [TDToken]()
		if let tokenizer {
			while let token = tokenizer.nextToken(), token !== TDToken.eof {
				result.append(token)
			}
		}
		tokenList = result
		return result
	}

	public override func peek() -> Any? {
		while index < tokens.count {
			let token = tokens[index]
			if preservesWhitespaceTokens && token.whitespace {
				push(token)
				index += 1
				continue
			}
			return token
		}
		return nil
	}
	public override func next() -> Any? {
		let value = peek()
		if value != nil {
			index += 1
		}
		return value
	}
	public override func hasMore() -> Bool {
		return index < tokens.count
	}

	public override var length: UInt {
		return UInt(tokens.count)
	}

	public override var objectsConsumed: UInt {
		return UInt(index)
	}

	public override var objectsRemaining: UInt {
		return UInt(tokens.count - index)
	}

	public override func consumedObjectsJoined(by delimiter: String) -> String {
		return join(0, index, delimiter)
	}

	public override func remainingObjectsJoined(by delimiter: String) -> String {
		return join(index, tokens.count, delimiter)
	}

	private func join(_ start: Int, _ end: Int, _ delimiter: String) -> String {
		return tokens[start..<end].map(\.stringValue).joined(separator: delimiter)
	}
}
