//
//  TDSequence.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDSequence)
open class TDSequence: TDCollectionParser {

	@objc
	public class func sequence() -> TDSequence {
		return TDSequence()
	}

	public override func allMatches(for assemblies: Set<AnyHashable>?) -> Set<AnyHashable>? {
		var result = assemblies ?? []
		for value in subparsers {
			guard let parser = value as? TDParser else {
				continue
			}
			result = parser.matchAndAssemble(result)
			if result.isEmpty {
				break
			}
		}
		return result
	}
}
