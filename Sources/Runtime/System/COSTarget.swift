//
//  COSTarget.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: CocoaScript, created by Abhi Beckert in 2013.
//

import Foundation
import JavaScriptCore
import ObjectiveC

@objc(COSTarget)
public final class COSTarget: NSObject {

	@objc public var jsFunction: MOJavaScriptObject
	@objc public var callCount = 0
	private weak var cosContext: COScript?

	@objc public class func target(withJSFunction jsFunction: MOJavaScriptObject) -> COSTarget {
		return COSTarget(jsFunction: jsFunction)
	}

	@objc public init(jsFunction: MOJavaScriptObject) {
		self.jsFunction = jsFunction
		cosContext = COScript.current()
		super.init()
	}

	@objc public func callAction(_ sender: Any?) {
		guard
			let cosContext,
			let object = jsFunction.JSObject
		else {
			return
		}
		callCount += 1
		_ = cosContext.callJSFunction(object, withArgumentsIn: [sender ?? NSNull()])
	}

	@objc public var action: Selector {
		return #selector(callAction(_:))
	}
}

extension NSObject {

	@nonobjc public func setCOSJSTargetFunction(_ jsFunction: MOJavaScriptObject) {
		guard
			responds(to: NSSelectorFromString("setTarget:")),
			responds(to: NSSelectorFromString("setAction:"))
		else {
			return
		}
		let target = COSTarget.target(withJSFunction: jsFunction)
		setValue(target, forKey: "target")
		setValue(target.action, forKey: "action")
		objc_setAssociatedObject(self, "COSTargetFunction", target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
}
