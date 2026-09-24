//
//  NSObject+MochaAdditions.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/17/12.
//  Copyright 2012 Sunflower Softworks. All rights reserved.
//

import Foundation
import ObjectiveC.runtime

extension NSObject {

	@objc
	public class func mo_swizzleAdditions() {
		let mochaSelector = NSSelectorFromString("mocha")
		guard !class_respondsToSelector(self, mochaSelector) else {
			return
		}
		guard
			let metaclass = object_getClass(self),
			let implementation = class_getMethodImplementation(metaclass, #selector(mo_mocha))
		else {
			return
		}
		class_addMethod(metaclass, mochaSelector, implementation, "@@:")
	}

	@objc public class func mo_mocha() -> MOClassDescription {
		return MOClassDescription.description(forClass: self)
	}
}
