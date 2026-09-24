//
//  COSFiber.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: CocoaScript, created by Mathieu Dutour in 2017.
//

import Foundation

@objc(COSFiber)
open class COSFiber: NSObject {

	@objc public weak var coscript: COScript?
	@objc public var cleanUpJSfunc: MOJavaScriptObject?

	@objc public required override init() {
		super.init()
	}

	@objc public class func create(withCocoaScript cos: COScript) -> COSFiber {
		let fiber = self.init()
		fiber.coscript = cos
		return fiber
	}

	@objc public func onCleanup(_ jsFunction: MOJavaScriptObject) {
		cleanUpJSfunc = jsFunction
	}

	@objc public func cleanup() {
		if let cleanUpJSfunc,
			let object = cleanUpJSfunc.JSObject
		{
			_ = coscript?.callJSFunction(object, withArgumentsIn: [])
		}
		coscript?.removeFiber(self)
		cleanUpJSfunc = nil
		coscript = nil
	}
}
