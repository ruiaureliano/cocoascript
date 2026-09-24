//
//  MOMethod.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

@objc(MOMethod)
public final class MOMethod: NSObject {

	@objc
	public private(set) var target: AnyObject?
	@objc
	public private(set) var selector: Selector = #selector(NSObject.init)
	public private(set) var block: AnyObject?

	@objc public static func method(withTarget target: AnyObject, selector: Selector) -> MOMethod {
		let method = MOMethod()
		method.target = target
		method.selector = selector
		return method
	}

	public static func method(withBlock block: AnyObject) -> MOMethod {
		let method = MOMethod()
		method.block = block
		return method
	}

	public override var description: String {
		"<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque()) : target=\(String(describing: target)), selector=\(NSStringFromSelector(selector))>"
	}
}
