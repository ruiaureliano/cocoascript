//
//  MOBridgeSupportLibrary.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/11/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

@objc(MOBridgeSupportLibrary)
public final class MOBridgeSupportLibrary: NSObject {

	@objc
	public var name: String?
	@objc
	public var URL: URL?
	@objc
	public var dependencies: [String] = []
	@objc
	public var symbols: [String: MOBridgeSupportSymbol] = [:]

	@objc public func addDependency(_ dependency: String) {
		if !dependencies.contains(dependency) {
			dependencies.append(dependency)
		}
	}

	@objc public func removeDependency(_ dependency: String) {
		dependencies.removeAll { $0 == dependency }
	}

	@objc
	public func symbol(withName name: String) -> MOBridgeSupportSymbol? {
		return symbols[name]
	}

	@objc public func setSymbol(_ symbol: MOBridgeSupportSymbol, forName name: String) {
		symbols[name] = symbol
	}

	@objc public func removeSymbol(forName name: String) {
		symbols.removeValue(forKey: name)
	}
}
