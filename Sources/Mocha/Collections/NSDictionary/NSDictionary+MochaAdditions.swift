//
//  NSDictionary+MochaAdditions.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

extension NSDictionary {

	@objc(mo_objectForKeyedSubscript:)
	public func mo_objectForKeyedSubscript(_ key: Any) -> Any? {
		return object(forKey: key)
	}
}

extension NSMutableDictionary {

	@objc(mo_setObject:forKeyedSubscript:)
	public func mo_setObject(_ object: Any?, forKeyedSubscript key: NSCopying) {
		if let object {
			setObject(object, forKey: key)
		} else {
			removeObject(forKey: key)
		}
	}
}
