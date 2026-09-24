//
//  MOProtocolDescription.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/18/12.
//  Copyright (c) 2012 Logan Collins. All rights reserved.
//

import Foundation
import ObjectiveC.runtime

@objc(MOProtocolDescription)
public final class MOProtocolDescription: NSObject {

	private let objectProtocol: Protocol

	internal var objectProtocolReference: Protocol {
		return objectProtocol
	}

	@objc
	public static func description(for objectProtocol: Protocol) -> MOProtocolDescription {
		return MOProtocolDescription(objectProtocol: objectProtocol)
	}

	@objc
	public static func description(forProtocolWithName name: String) -> MOProtocolDescription? {
		guard let objectProtocol = NSProtocolFromString(name) else {
			return nil
		}
		return MOProtocolDescription(objectProtocol: objectProtocol)
	}

	@objc
	public static func allocateDescription(forProtocolWithName name: String) -> MOProtocolDescription? {
		guard
			NSProtocolFromString(name) == nil,
			let objectProtocol = objc_allocateProtocol(name)
		else {
			return nil
		}
		return MOProtocolDescription(objectProtocol: objectProtocol)
	}

	@objc
	public init(objectProtocol: Protocol) {
		self.objectProtocol = objectProtocol
		super.init()
	}

	@objc
	public var name: String {
		return String(cString: protocol_getName(objectProtocol))
	}

	@objc
	public var requiredClassMethods: [MOMethodDescription] {
		return methodDescriptions(required: true, instance: false)
	}

	@objc
	public var optionalClassMethods: [MOMethodDescription] {
		return methodDescriptions(required: false, instance: false)
	}

	@objc
	public var requiredInstanceMethods: [MOMethodDescription] {
		return methodDescriptions(required: true, instance: true)
	}

	@objc
	public var optionalInstanceMethods: [MOMethodDescription] {
		return methodDescriptions(required: false, instance: true)
	}

	@objc
	public var properties: [MOPropertyDescription] {
		var count: UInt32 = 0
		guard let propertyList = protocol_copyPropertyList(objectProtocol, &count) else {
			return []
		}
		defer {
			free(UnsafeMutableRawPointer(propertyList))
		}

		return (0..<Int(count)).map { index in
			let property = MOPropertyDescription()
			let objcProperty = propertyList[index]
			property.name = String(cString: property_getName(objcProperty))
			return property
		}
	}

	@objc
	public var protocols: [MOProtocolDescription] {
		var count: UInt32 = 0
		guard let protocolList = protocol_copyProtocolList(objectProtocol, &count) else {
			return []
		}
		defer {
			free(UnsafeMutableRawPointer(protocolList))
		}

		return (0..<Int(count)).map { index in
			return MOProtocolDescription(objectProtocol: protocolList[index])
		}
	}

	@objc
	public func addClassMethod(_ method: MOMethodDescription, required: Bool) {
		protocol_addMethodDescription(objectProtocol, method.selector, method.typeEncoding, required, false)
	}

	@objc
	public func addInstanceMethod(_ method: MOMethodDescription, required: Bool) {
		protocol_addMethodDescription(objectProtocol, method.selector, method.typeEncoding, required, true)
	}

	@objc
	public func addProtocol(_ protocolDescription: MOProtocolDescription) {
		protocol_addProtocol(objectProtocol, protocolDescription.objectProtocol)
	}

	public override var description: String {
		return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque()) : name=\(name)>"
	}

	private func methodDescriptions(required: Bool, instance: Bool) -> [MOMethodDescription] {
		var count: UInt32 = 0
		guard let methodList = protocol_copyMethodDescriptionList(objectProtocol, required, instance, &count) else {
			return []
		}
		defer {
			free(UnsafeMutableRawPointer(methodList))
		}

		return (0..<Int(count)).compactMap { index in
			let method = methodList[index]
			guard let selector = method.name else {
				return nil
			}
			return MOMethodDescription(selector: selector, typeEncoding: string(from: method.types))
		}
	}

	private func string(from pointer: UnsafeMutablePointer<CChar>?) -> String {
		guard let pointer else {
			return ""
		}
		return String(cString: pointer)
	}
}
