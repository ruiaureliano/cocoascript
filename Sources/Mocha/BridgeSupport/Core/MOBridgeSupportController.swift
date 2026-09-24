//
//  MOBridgeSupportController.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/11/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

@objc(MOBridgeSupportController)
public final class MOBridgeSupportController: NSObject {

	@objc
	nonisolated(unsafe) public static let sharedController = MOBridgeSupportController()

	private var loadedURLs: Set<URL> = []
	private var loadedLibraries: [MOBridgeSupportLibrary] = []
	private var mutableSymbols: [String: MOBridgeSupportSymbol] = [:]
	private let parser = MOBridgeSupportParser()

	@objc
	public var symbols: [String: MOBridgeSupportSymbol] {
		return mutableSymbols
	}

	@objc
	public func isBridgeSupportLoaded(for url: URL) -> Bool {
		return loadedURLs.contains(url)
	}

	public func loadBridgeSupport(at url: URL) throws -> Bool {
		if isBridgeSupportLoaded(for: url) {
			return true
		}

		let library = try parser.library(withBridgeSupportURL: url)
		loadedURLs.insert(url)
		loadedLibraries.append(library)
		for (name, symbol) in library.symbols {
			mutableSymbols[name] = symbol
		}
		return true
	}

	public func performQuery(forSymbolsOfType classes: [AnyClass]) -> [String: MOBridgeSupportSymbol] {
		var result: [String: MOBridgeSupportSymbol] = [:]
		for (name, symbol) in mutableSymbols where classes.contains(where: { symbol.isKind(of: $0) }) {
			result[name] = symbol
		}
		return result
	}

	@objc
	public func performQuery(forSymbolName name: String) -> MOBridgeSupportSymbol? {
		return mutableSymbols[name]
	}

	public func performQuery(forSymbolName name: String, ofType type: AnyClass) -> MOBridgeSupportSymbol? {
		guard
			let symbol = mutableSymbols[name],
			symbol.isKind(of: type)
		else {
			return nil
		}
		return symbol
	}
}
