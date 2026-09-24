//
//  MOPointer.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 7/31/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

@objc(MOPointer)
public final class MOPointer: NSObject {

	@objc
	public private(set) var value: Any?

	@objc
	public init(value: Any?) {
		self.value = value
		super.init()
	}
}
