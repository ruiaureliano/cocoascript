//
//  MOMethodDescription.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/26/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

@objc(MOMethodDescription)
public final class MOMethodDescription: NSObject {

	@objc
	public let selector: Selector
	@objc
	public let typeEncoding: String

	@objc
	public static func method(withSelector selector: Selector, typeEncoding: String) -> MOMethodDescription {
		return MOMethodDescription(selector: selector, typeEncoding: typeEncoding)
	}

	@objc public init(selector: Selector, typeEncoding: String) {
		self.selector = selector
		self.typeEncoding = typeEncoding
		super.init()
	}

	public override var description: String {
		return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque()) : selector=\(NSStringFromSelector(selector)), typeEncoding=\(typeEncoding)>"
	}
}
