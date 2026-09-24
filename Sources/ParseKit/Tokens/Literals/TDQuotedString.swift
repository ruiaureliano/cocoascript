//
//  TDQuotedString.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDQuotedString)
public final class TDQuotedString: TDTerminal {

	@objc
	public static func quotedString() -> TDQuotedString {
		return TDQuotedString(string: nil)
	}

	@objc
	public override init(string: String?) {
		super.init(string: string)
	}

	@objc(qualifies:)
	public override func qualifies(_ object: Any) -> Bool {
		return (object as? TDToken)?.quotedString ?? false
	}
}
