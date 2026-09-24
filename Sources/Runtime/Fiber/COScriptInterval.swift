//
//  COScriptInterval.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: CocoaScript, created by August Mueller in 2013.
//

import Foundation

extension COScript {

	@nonobjc
	public func schedule(withRepeatingInterval interval: TimeInterval, jsFunction: MOJavaScriptObject) -> COSInterval {
		let fiber = COSInterval.schedule(withInterval: interval, cocoaScript: self, jsFunction: jsFunction, repeat: true)
		addFiber(fiber)
		return fiber
	}

	@nonobjc
	public func schedule(withInterval interval: TimeInterval, jsFunction: MOJavaScriptObject) -> COSInterval {
		let fiber = COSInterval.schedule(withInterval: interval, cocoaScript: self, jsFunction: jsFunction, repeat: false)
		addFiber(fiber)
		return fiber
	}
}
