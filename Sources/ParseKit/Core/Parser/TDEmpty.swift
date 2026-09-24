//
//  TDEmpty.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDEmpty)
public final class TDEmpty: TDParser {

	@objc
	public static func empty() -> TDEmpty {
		return TDEmpty()
	}

	public override func allMatches(for assemblies: Set<AnyHashable>?) -> Set<AnyHashable>? {
		return assemblies
	}
}
