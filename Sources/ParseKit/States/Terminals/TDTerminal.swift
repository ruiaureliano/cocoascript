//
//  TDTerminal.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDTerminal)
open class TDTerminal: TDParser {

	@objc
	public private(set) var string: String?
	private var discardFlag = false

	@objc
	public override init() {
		super.init()
	}
	@objc(initWithString:)
	public init(string: String?) {
		self.string = string
		super.init()
	}

	public override func allMatches(for assemblies: Set<AnyHashable>?) -> Set<AnyHashable>? {
		var result = Set<AnyHashable>()
		for value in assemblies ?? [] {
			guard
				let assembly = value as? TDAssembly,
				assembly.hasMore(),
				qualifies(assembly.peek() as Any)
			else {
				continue
			}
			guard let copy = assembly.copy() as? TDAssembly else {
				continue
			}
			let object = copy.next()
			if !discardFlag, let object {
				copy.push(object)
			}
			result.insert(copy)
		}
		return result
	}

	@objc(qualifies:)
	open func qualifies(_ object: Any) -> Bool {
		fatalError("TDTerminal.qualifies must be overridden")
	}

	@objc
	public func discard() -> TDTerminal {
		discardFlag = true
		return self
	}
}
