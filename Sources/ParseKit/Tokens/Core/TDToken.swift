//
//  TDToken.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

/// Indicates the type of a `TDToken`.
///
/// `TDTokenTypeEOF` indicates that the end of the stream has been read.
/// `TDTokenTypeNumber` represents a number, such as `3.14`.
/// `TDTokenTypeQuotedString` represents a quoted string, such as `"Launch Mi"`.
/// `TDTokenTypeSymbol` represents a symbol, such as `"<="`.
/// `TDTokenTypeWord` represents a word, such as `cat`.
/// `TDTokenTypeWhitespace` represents whitespace.
/// `TDTokenTypeComment` represents a comment.

/// A token represents a logical chunk of a string.
///
/// A tokenizer decides precisely how to divide the input into tokens.
@objc(TDToken)
open class TDToken: NSObject {

	@objc
	public private(set) var floatValue: CGFloat
	@objc
	public private(set) var stringValue: String
	@objc
	public private(set) var tokenType: TDTokenType
	@objc
	public private(set) var number = false
	@objc
	public private(set) var quotedString = false
	@objc
	public private(set) var symbol = false
	@objc
	public private(set) var word = false
	@objc
	public private(set) var whitespace = false
	@objc
	public private(set) var comment = false
	private var cachedValue: Any?
	nonisolated(unsafe) public static let eof = TDToken(tokenType: TDTokenTypeEOF, stringValue: "", floatValue: 0)

	@objc
	public class func EOFToken() -> TDToken {
		return eof
	}

	@objc(tokenWithTokenType:stringValue:floatValue:)
	public class func token(with tokenType: TDTokenType, stringValue: String?, floatValue: CGFloat) -> TDToken {
		return TDToken(tokenType: tokenType, stringValue: stringValue ?? "", floatValue: floatValue)
	}

	@objc(initWithTokenType:stringValue:floatValue:)
	public init(tokenType: TDTokenType, stringValue: String?, floatValue: CGFloat) {
		self.tokenType = tokenType
		self.stringValue = stringValue ?? ""
		self.floatValue = floatValue
		super.init()
		number = tokenType == TDTokenTypeNumber
		quotedString = tokenType == TDTokenTypeQuotedString
		symbol = tokenType == TDTokenTypeSymbol
		word = tokenType == TDTokenTypeWord
		whitespace = tokenType == TDTokenTypeWhitespace
		comment = tokenType == TDTokenTypeComment
	}

	@objc
	public func isEqualIgnoringCase(_ object: Any) -> Bool {
		return isEqual(to: object, ignoringCase: true)
	}

	private func isEqual(to object: Any, ignoringCase: Bool) -> Bool {
		guard
			let token = object as? TDToken,
			type(of: token) == TDToken.self,
			tokenType == token.tokenType
		else {
			return false
		}
		if number {
			return floatValue == token.floatValue
		}

		if ignoringCase {
			return stringValue.caseInsensitiveCompare(token.stringValue) == .orderedSame
		}

		return stringValue == token.stringValue
	}

	open override func isEqual(_ object: Any?) -> Bool {
		return object.map { isEqual(to: $0, ignoringCase: false) } ?? false
	}

	open override var hash: Int {
		return stringValue.hashValue
	}

	@objc
	public var value: Any {
		if let cachedValue {
			return cachedValue
		}

		let result: Any
		if number {
			result = NSNumber(value: Float(floatValue))
		} else {
			result = stringValue
		}

		cachedValue = result
		return result
	}

	@objc
	override open var debugDescription: String {
		return "<\(tokenType) «\(value)»>"
	}

	open override var description: String {
		return stringValue
	}
}
