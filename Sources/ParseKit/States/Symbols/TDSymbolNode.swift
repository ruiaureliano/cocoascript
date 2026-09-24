//
//  TDSymbolNode.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDSymbolNode)
open class TDSymbolNode: NSObject {

	internal weak var parentNode: TDSymbolNode?
	internal var character: Int
	internal var children = [Int: TDSymbolNode]()
	internal let string: String
	@objc
	public private(set) var ancestry: String

	@objc(initWithParent:character:)
	public init(parent: TDSymbolNode?, character: Int) {
		self.parentNode = parent
		self.character = character
		self.string = String(UnicodeScalar(character) ?? UnicodeScalar(0))
		if character == -1 {
			self.ancestry = ""
		} else if parent?.character == -1 {
			self.ancestry = self.string
		} else {
			var value = self.string
			var node = parent
			while let current = node, current.character != -1 {
				value = current.string + value
				node = current.parentNode
			}
			self.ancestry = value
		}
		super.init()
	}

	public override var description: String {
		return "<TDSymbolNode \(ancestry)>"
	}
}
