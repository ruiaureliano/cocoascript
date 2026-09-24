//
//  COSInterval.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: CocoaScript, created by August Mueller in 2013.
//

import Foundation

@objc(COSInterval)
public final class COSInterval: COSFiber {

	@objc public var jsfunc: MOJavaScriptObject?
	private var timer: Timer?
	private var oneShot = false

	@objc public class func schedule(withInterval interval: TimeInterval, cocoaScript cos: COScript, jsFunction: MOJavaScriptObject, repeat: Bool) -> COSInterval {
		let result = COSInterval.create(withCocoaScript: cos) as! COSInterval
		result.jsfunc = jsFunction
		result.oneShot = !`repeat`
		result.timer = Timer.scheduledTimer(timeInterval: interval, target: result, selector: #selector(timerHit(_:)), userInfo: nil, repeats: `repeat`)
		return result
	}

	@objc public func cancel() {
		timer?.invalidate()
		timer = nil
		cleanup()
	}

	@objc private func timerHit(_ timer: Timer) {
		if let jsfunc, let coscript, let object = jsfunc.JSObject {
			_ = coscript.callJSFunction(object, withArgumentsIn: [self])
		}
		if oneShot {
			cancel()
		}
	}

	public override func cleanup() {
		super.cleanup()
		jsfunc = nil
	}
}
