//
//  TDSymbolRootNode.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDSymbolRootNode)
public final class TDSymbolRootNode: TDSymbolNode {

	@objc
	public init() {
		super.init(parent: nil, character: -1)
	}

	@objc
	public func add(_ symbol: String) {
		guard symbol.utf16.count >= 2 else {
			return
		}

		add(symbol.utf16.map(Int.init), parent: self)
	}

	private func add(_ characters: [Int], parent: TDSymbolNode) {
		guard let first = characters.first else {
			return
		}

		let child =
			parent.children[first]
			?? {
				let node = TDSymbolNode(parent: parent, character: first)
				parent.children[first] = node
				return node
			}()
		if characters.count > 1 {
			add(Array(characters.dropFirst()), parent: child)
		}
	}

	@objc
	public func remove(_ symbol: String) {
		guard symbol.utf16.count >= 2 else {
			return
		}

		remove(symbol.utf16.map(Int.init), parent: self)
	}

	@discardableResult
	private func remove(_ characters: [Int], parent: TDSymbolNode) -> Bool {
		guard
			let first = characters.first,
			let child = parent.children[first]
		else {
			return false
		}
		if characters.count > 1 {
			_ = remove(Array(characters.dropFirst()), parent: child)
		}

		if characters.count == 1 || child.children.isEmpty {
			parent.children.removeValue(forKey: first)
		}

		return true
	}

	@objc
	public func nextSymbol(_ reader: TDReader, startingWith character: Int) -> String? {
		return nextSymbol(character, reader: reader, parent: self)
	}

	private func nextSymbol(_ character: Int, reader: TDReader, parent: TDSymbolNode) -> String {
		let result = String(UnicodeScalar(character) ?? UnicodeScalar(0))
		guard let child = parent.children[character] else {
			if parent !== self {
				reader.unread()
				return ""
			}
			return result
		}
		let next = reader.read()
		if next == -1 {
			return result
		}

		return result + nextSymbol(next, reader: reader, parent: child)
	}

	public override var description: String {
		return "<TDSymbolRootNode>"
	}
}
