//
//  TDCollectionParser.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDCollectionParser)
open class TDCollectionParser: TDParser {

	@objc
	public private(set) var subparsers = NSMutableArray()

	@objc
	public func add(_ parser: TDParser) {
		subparsers.add(parser)
	}
}
