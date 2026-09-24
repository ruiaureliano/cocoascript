//
//  MOInstanceVariableDescription.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/26/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

@objc(MOInstanceVariableDescription)
public final class MOInstanceVariableDescription: NSObject {

	@objc
	public let name: String
	@objc
	public let typeEncoding: String

	@objc
	public static func instanceVariable(withName name: String, typeEncoding: String) -> MOInstanceVariableDescription {
		return MOInstanceVariableDescription(name: name, typeEncoding: typeEncoding)
	}

	@objc public init(name: String, typeEncoding: String) {
		self.name = name
		self.typeEncoding = typeEncoding
		super.init()
	}

	public override var description: String {
		return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque()) : name=\(name), typeEncoding=\(typeEncoding)>"
	}
}
