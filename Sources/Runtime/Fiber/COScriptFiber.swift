//
//  COScriptFiber.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: CocoaScript, created by Mathieu Dutour in 2017.
//

import Foundation
import ObjectiveC

private nonisolated(unsafe) var fibersKey: UInt8 = 0

private func fibers(for script: COScript) -> NSMutableArray {
	if let fibers = objc_getAssociatedObject(script, &fibersKey) as? NSMutableArray {
		return fibers
	}
	let fibers = NSMutableArray()
	objc_setAssociatedObject(script, &fibersKey, fibers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	return fibers
}

extension COScript {

	@nonobjc
	public func addFiber(_ fiber: COSFiber) {
		fibers(for: self).add(fiber)
	}

	@nonobjc
	public func cleanupFibers() {
		for fiber in fibers(for: self).compactMap({ $0 as? COSFiber }) {
			fiber.cleanup()
		}
		fibers(for: self).removeAllObjects()
	}

	@nonobjc
	public func removeFiber(_ fiber: COSFiber) {
		let activeFibers = fibers(for: self)
		guard activeFibers.contains(fiber) else {
			return
		}
		activeFibers.remove(fiber)
	}

	@nonobjc
	public func hasActiveFibers() -> Bool {
		return fibers(for: self).count > 0
	}

	@nonobjc
	public func createFiber() -> COSFiber {
		let fiber = COSFiber.create(withCocoaScript: self)
		addFiber(fiber)
		return fiber
	}
}
