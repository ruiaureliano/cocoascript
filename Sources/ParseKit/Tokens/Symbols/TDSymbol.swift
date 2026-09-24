//
//  TDSymbol.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDSymbol)
public final class TDSymbol: TDTerminal {

	private var symbolToken: TDToken?

	@objc
	public static func symbol() -> TDSymbol {
		return TDSymbol(string: nil)
	}

	@objc(symbolWithString:)
	public static func symbolWithString(_ string: String) -> TDSymbol {

		TDSymbol(string: string)
	}

	@objc
	public override init(string: String?) {
		super.init(string: string)
		if let string, !string.isEmpty {
			symbolToken = TDToken.token(with: TDTokenTypeSymbol, stringValue: string, floatValue: 0)
		}
	}

	@objc(qualifies:)
	public override func qualifies(_ object: Any) -> Bool {
		if let symbolToken {
			return symbolToken.isEqual(object)
		}
		return (object as? TDToken)?.symbol ?? false
	}
}
