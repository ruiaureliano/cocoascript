//
//  MOPointerValue.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 7/26/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

@objc(MOPointerValue)
public final class MOPointerValue: NSObject {

	@objc
	public private(set) var pointerValue: UnsafeMutableRawPointer?
	@objc
	public private(set) var typeEncoding: String

	@objc
	public init(pointerValue: UnsafeMutableRawPointer?, typeEncoding: String) {
		self.pointerValue = pointerValue
		self.typeEncoding = typeEncoding
		super.init()
	}

	public override var description: String {
		if typeEncoding.isEmpty {
			return "<\(String(describing: pointerValue))>"
		}
		return "<\(String(describing: pointerValue)) type=\(typeEncoding)>"
	}
}
