//
//  TDLiteral.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

open class TDLiteral: TDTerminal {

	internal var literalToken: TDToken?

	@objc(literalWithString:)
	public class func literalWithString(_ string: String) -> TDLiteral {
		return TDLiteral(string: string)
	}

	@objc
	public override init(string: String?) {
		super.init(string: string)
		if let string {
			literalToken = TDToken.token(with: TDTokenTypeWord, stringValue: string, floatValue: 0)
		}
	}

	@objc(qualifies:)
	public override func qualifies(_ object: Any) -> Bool {
		guard
			let literalToken,
			let token = object as? TDToken
		else {
			return false
		}
		return literalToken.stringValue == token.stringValue
	}

	public override var description: String {
		let className = String(describing: type(of: self)).dropFirst(2)
		if let name, !name.isEmpty {
			return "\(className) (\(name)) \(literalToken?.stringValue ?? "")"
		}
		return "\(className) \(literalToken?.stringValue ?? "")"
	}
}
