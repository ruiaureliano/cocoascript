//
//  TDTokenizer.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDTokenizer)
public final class TDTokenizer: NSObject {

	@objc
	public var string: String? {
		didSet {
			reader.string = string
		}
	}
	private let reader = TDReader()
	private var tokenizerStates = [TDTokenizerState](repeating: TDTokenizerState(), count: 256)
	@objc
	public var numberState: TDNumberState
	@objc
	public var quoteState: TDQuoteState
	@objc
	public var commentState: TDCommentState
	@objc
	public var symbolState: TDSymbolState
	@objc
	public var whitespaceState: TDWhitespaceState
	@objc
	public var wordState: TDWordState

	@objc
	public static func tokenizer() -> TDTokenizer {
		return TDTokenizer(string: nil)
	}

	@objc(tokenizerWithString:)
	public static func tokenizer(with string: String?) -> TDTokenizer {
		return TDTokenizer(string: string)
	}

	@objc
	public override convenience init() {
		self.init(string: nil)
	}

	@objc(initWithString:)
	public init(string: String?) {
		self.string = string
		numberState = TDNumberState()
		quoteState = TDQuoteState()
		commentState = TDCommentState()
		symbolState = TDSymbolState()
		whitespaceState = TDWhitespaceState()
		wordState = TDWordState()
		super.init()
		reader.string = string
		symbolState.add("<=")
		symbolState.add(">=")
		symbolState.add("!=")
		symbolState.add("==")
		commentState.addSingleLineStartSymbol("//")
		commentState.addMultiLineStartSymbol("/*", endSymbol: "*/")
		addTokenizerState(whitespaceState, from: 0, to: 32)
		addTokenizerState(symbolState, from: 33, to: 33)
		addTokenizerState(quoteState, from: 34, to: 34)
		addTokenizerState(symbolState, from: 35, to: 38)
		addTokenizerState(quoteState, from: 39, to: 39)
		addTokenizerState(symbolState, from: 40, to: 44)
		addTokenizerState(numberState, from: 45, to: 46)
		addTokenizerState(commentState, from: 47, to: 47)
		addTokenizerState(numberState, from: 48, to: 57)
		addTokenizerState(symbolState, from: 58, to: 64)
		addTokenizerState(wordState, from: 65, to: 90)
		addTokenizerState(symbolState, from: 91, to: 96)
		addTokenizerState(wordState, from: 97, to: 122)
		addTokenizerState(symbolState, from: 123, to: 191)
		addTokenizerState(wordState, from: 192, to: 255)
	}

	@objc
	public func nextToken() -> TDToken? {
		let character = reader.read()
		guard character != -1 else {
			return TDToken.eof
		}

		return state(for: character)?.nextToken(from: reader, startingWith: character, tokenizer: self) ?? TDToken.eof
	}

	@objc
	public func setTokenizerState(_ state: TDTokenizerState, from start: Int, to end: Int) {
		addTokenizerState(state, from: start, to: end, replacing: true)
	}

	private func addTokenizerState(_ state: TDTokenizerState, from start: Int, to end: Int, replacing: Bool = false) {
		for index in start...end where index >= 0 && index < tokenizerStates.count {
			tokenizerStates[index] = state
		}
	}

	private func state(for character: Int) -> TDTokenizerState? {
		if character >= 0 && character <= 255 {
			return tokenizerStates[character]
		}

		if character >= 0x19E0 && character <= 0xFF65 {
			return symbolState
		}

		return wordState
	}
}
