//
//  TDParser.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDParser)
open class TDParser: NSObject {

	@objc
	public var assembler: Any?
	@objc
	public var selector: Selector?
	@objc
	public var name: String?

	@objc
	public class func parser() -> TDParser {
		return TDParser()
	}

	@objc public func setAssembler(_ assembler: Any?, selector: Selector) {
		self.assembler = assembler
		self.selector = selector
	}

	@objc(allMatchesFor:)
	open func allMatches(for assemblies: Set<AnyHashable>?) -> Set<AnyHashable>? {
		return nil
	}

	@objc public func bestMatch(for assembly: TDAssembly) -> TDAssembly? {
		return best(matchAndAssemble([assembly]))
	}

	@objc public func completeMatch(for assembly: TDAssembly) -> TDAssembly? {
		guard
			let result = bestMatch(for: assembly),
			!result.hasMore()
		else {
			return nil
		}
		return result
	}

	internal func matchAndAssemble(_ assemblies: Set<AnyHashable>) -> Set<AnyHashable> {
		let results = allMatches(for: assemblies) ?? []
		if let assembler, let selector {
			let object = assembler as AnyObject
			for value in results {
				if let assembly = value as? TDAssembly {
					_ = object.perform(selector, with: assembly)
				}
			}
		}
		return results
	}

	internal func best(_ assemblies: Set<AnyHashable>) -> TDAssembly? {
		var result: TDAssembly?
		for value in assemblies {
			guard let assembly = value as? TDAssembly else {
				continue
			}

			if !assembly.hasMore() {
				return assembly
			}

			if result == nil || assembly.objectsConsumed > result!.objectsConsumed {
				result = assembly
			}
		}
		return result
	}

	open override var description: String {
		let className = String(describing: type(of: self)).dropFirst(2)
		return name?.isEmpty == false ? "\(className) (\(name!))" : String(className)
	}
}
