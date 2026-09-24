//
//  TDTokenType.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

/// Indicates the type of a `TDToken`.
@objc
public enum TDTokenType: Int, Sendable {

	/// The end of the input stream has been read.
	case eof

	/// The token is a number, such as `3.14`.
	case number

	/// The token is a quoted string, such as `"Launch Mi"`.
	case quotedString

	/// The token is a symbol, such as `"<="`.
	case symbol

	/// The token is a word, such as `cat`.
	case word

	/// The token contains whitespace.
	case whitespace

	/// The token contains a comment.
	case comment
}

public let TDTokenTypeEOF = TDTokenType.eof

public let TDTokenTypeNumber = TDTokenType.number

public let TDTokenTypeQuotedString = TDTokenType.quotedString

public let TDTokenTypeSymbol = TDTokenType.symbol

public let TDTokenTypeWord = TDTokenType.word

public let TDTokenTypeWhitespace = TDTokenType.whitespace

public let TDTokenTypeComment = TDTokenType.comment
