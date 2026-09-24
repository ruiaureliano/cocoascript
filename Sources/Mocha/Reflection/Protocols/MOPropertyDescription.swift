//
//  MOPropertyDescription.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/26/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

@objc
public enum MOObjCOwnershipRule: UInt {

	case assign = 0
	case retain
	case copy
}

@objc(MOPropertyDescription)
public final class MOPropertyDescription: NSObject {

	@objc
	public var name: String?
	@objc
	public var typeEncoding: String?
	@objc
	public var ivarName: String?
	@objc
	public var getterSelector: Selector?
	@objc
	public var setterSelector: Selector?
	@objc
	public var ownershipRule: MOObjCOwnershipRule = .assign
	@objc
	public var isDynamic = false
	@objc
	public var isNonAtomic = false
	@objc
	public var isReadOnly = false
	@objc
	public var isWeak = false

	public override var description: String {
		var attributes: [String] = []
		switch ownershipRule {
		case .assign:
			attributes.append("assign")
		case .retain:
			attributes.append("retain")
		case .copy:
			attributes.append("copy")
		}
		if isDynamic {
			attributes.append("dynamic")
		}
		if isNonAtomic {
			attributes.append("nonatomic")
		}
		if isReadOnly {
			attributes.append("readonly")
		}
		if isWeak {
			attributes.append("weak")
		}
		if let getterSelector {
			attributes.append("getter=\(NSStringFromSelector(getterSelector))")
		}
		if let setterSelector {
			attributes.append("setter=\(NSStringFromSelector(setterSelector))")
		}

		return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque()) : name=\(String(describing: name)), typeEncoding=\(String(describing: typeEncoding)), ivar=\(String(describing: ivarName)), attributes=(\(attributes.joined(separator: ",")))>"
	}
}
