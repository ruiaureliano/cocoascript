//
//  TDWord.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDWord)
public class TDWord: TDTerminal {

	@objc
	public class func word() -> TDWord {
		return TDWord(string: nil)
	}

	@objc
	public override init(string: String?) {
		super.init(string: string)
	}

	@objc(qualifies:)
	public override func qualifies(_ object: Any) -> Bool { (object as? TDToken)?.word ?? false }
}
