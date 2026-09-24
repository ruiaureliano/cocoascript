//
//  TDRepetition.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDRepetition)
public final class TDRepetition: TDParser {

	@objc
	public let subparser: TDParser?
	@objc
	public var preassembler: Any?
	@objc
	public var preassemblerSelector: Selector?

	@objc
	public static func repetition(withSubparser parser: TDParser) -> TDRepetition {
		return TDRepetition(subparser: parser)
	}
	@objc(initWithSubparser:)
	public init(subparser: TDParser?) {
		self.subparser = subparser
		super.init()
	}
	@objc
	public override init() {
		subparser = nil
		super.init()
	}

	@objc public func setPreassembler(_ assembler: Any?, selector: Selector) {
		preassembler = assembler
		preassemblerSelector = selector
	}

	public override func allMatches(for assemblies: Set<AnyHashable>?) -> Set<AnyHashable>? {
		var result = assemblies ?? []
		if let preassembler, let selector = preassemblerSelector {
			let object = preassembler as AnyObject
			for value in result {
				if let assembly = value as? TDAssembly {
					_ = object.perform(selector, with: assembly)
				}
			}
		}

		guard let subparser else {
			return result
		}
		var matches = result
		while !matches.isEmpty {
			matches = subparser.matchAndAssemble(matches)
			result.formUnion(matches)
		}
		return result
	}
}
