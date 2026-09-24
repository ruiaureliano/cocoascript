//
//  NSOrderedSet+MochaAdditions.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/17/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

extension NSOrderedSet {

	@objc(mo_objectForIndexedSubscript:)
	public func mo_objectForIndexedSubscript(_ index: UInt) -> Any? {
		return object(at: Int(index))
	}
}

extension NSMutableOrderedSet {

	@objc(mo_setObject:forIndexedSubscript:)
	public func mo_setObject(_ object: Any?, forIndexedSubscript index: UInt) {
		let index = Int(index)
		if index < count, let object {
			replaceObject(at: index, with: object)
		} else if index == count, let object {
			add(object)
		} else if object == nil, index < count {
			removeObject(at: index)
		}
	}
}
