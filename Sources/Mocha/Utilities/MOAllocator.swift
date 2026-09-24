//
//  MOAllocator.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 7/25/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

@objc(MOAllocator)
public final class MOAllocator: NSObject {

	@objc
	public var objectClass: AnyClass?

	@objc public static func allocator() -> MOAllocator {
		return MOAllocator()
	}
}
