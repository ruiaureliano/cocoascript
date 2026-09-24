//
//  MOBox.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc(MOBox)
public final class MOBox: NSObject {

	@objc
	public var representedObject: Any?
	@objc
	public var JSObject: JSObjectRef?
	@objc
	public weak var runtime: AnyObject?

	public override init() {
		JSObject = nil
		super.init()
	}
}
