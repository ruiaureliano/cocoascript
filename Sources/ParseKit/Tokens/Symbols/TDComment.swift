//
//  TDComment.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDComment)
public final class TDComment: TDTerminal {

	@objc
	public static func comment() -> TDComment {
		return TDComment(string: nil)
	}

	@objc
	public override init(string: String?) {
		super.init(string: string)
	}

	@objc(qualifies:)
	public override func qualifies(_ object: Any) -> Bool {
		return (object as? TDToken)?.comment ?? false
	}
}
