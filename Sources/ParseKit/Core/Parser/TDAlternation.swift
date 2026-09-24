//
//  TDAlternation.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDAlternation)
public final class TDAlternation: TDCollectionParser {

	@objc
	public static func alternation() -> TDAlternation {
		return TDAlternation()
	}

	public override init() {
		super.init()
	}

	public override func allMatches(for assemblies: Set<AnyHashable>?) -> Set<AnyHashable>? {
		let matches = NSMutableSet()
		for parser in subparsers {
			guard let parser = parser as? TDParser else {
				continue
			}

			if let parserMatches = parser.allMatches(for: assemblies) {
				matches.union(parserMatches)
			}
		}
		return Set(matches.compactMap { $0 as? AnyHashable })
	}
}
