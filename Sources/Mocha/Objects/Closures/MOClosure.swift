//
//  MOClosure.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/19/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

@objc(MOClosure)
public final class MOClosure: NSObject {

	@objc
	public let block: AnyObject

	@objc
	public static func closure(withBlock block: AnyObject) -> MOClosure {
		return MOClosure(block: block)
	}

	@objc public init(block: AnyObject) {
		self.block = block
		super.init()
	}

	/// The block's invocation function, matching the original Objective-C API.
	public var callAddress: UnsafeRawPointer? {
		let blockPointer = Unmanaged.passUnretained(block).toOpaque()
		return blockPointer.load(fromByteOffset: 16, as: UnsafeRawPointer?.self)
	}

	/// The block signature stored in its descriptor, when available.
	public var typeEncoding: UnsafePointer<CChar>? {
		let blockPointer = Unmanaged.passUnretained(block).toOpaque()
		let flags = blockPointer.load(fromByteOffset: 8, as: Int32.self)
		let descriptor = blockPointer.load(fromByteOffset: 24, as: UnsafeMutableRawPointer?.self)
		guard let descriptor else {
			return nil
		}

		let signatureFlag: Int32 = 1 << 30
		guard flags & signatureFlag != 0 else {
			return nil
		}

		let copyDisposeFlag: Int32 = 1 << 25
		let index = flags & copyDisposeFlag != 0 ? 2 : 0
		return descriptor.load(fromByteOffset: 16 + (index * MemoryLayout<UnsafeRawPointer>.size), as: UnsafePointer<CChar>?.self)
	}
}
