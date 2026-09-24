//
//  MOUndefined.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/15/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

@objc(MOUndefined)
public final class MOUndefined: NSObject, @unchecked Sendable {

	@objc
	public static let undefined = MOUndefined()

	private override init() {
		super.init()
	}
}
