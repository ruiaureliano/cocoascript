//
//  MOJavaScriptObject.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/28/12.
//  Copyright (c) 2012 Logan Collins. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc(MOJavaScriptObject)
public final class MOJavaScriptObject: NSObject {

	@objc
	public private(set) var JSObject: JSObjectRef?
	@objc
	public private(set) var JSContext: JSContextRef?

	@objc
	public static func object(withJSObject jsObject: JSObjectRef, context: JSContextRef) -> MOJavaScriptObject {
		let object = MOJavaScriptObject()
		object.setJSObject(jsObject, context: context)
		return object
	}

	deinit {
		if let JSObject, let JSContext {
			JSValueUnprotect(JSContext, JSObject)
		}
		if let JSContext {
			JSGlobalContextRelease(JSContext)
		}
	}

	private func setJSObject(_ object: JSObjectRef, context: JSContextRef) {
		if let JSObject, let JSContext {
			JSValueUnprotect(JSContext, JSObject)
		}
		if let JSContext {
			JSGlobalContextRelease(JSContext)
		}

		JSObject = object
		JSContext = JSGlobalContextRetain(context)
		if let JSObject, let JSContext {
			JSValueProtect(JSContext, JSObject)
		}
	}
}
