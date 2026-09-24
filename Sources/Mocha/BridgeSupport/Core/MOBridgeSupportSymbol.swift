//
//  MOBridgeSupportSymbol.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/11/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

@objc(MOBridgeSupportSymbol)
open class MOBridgeSupportSymbol: NSObject {

	@objc
	public var name: String?
}

@objc(MOBridgeSupportStruct)
public final class MOBridgeSupportStruct: MOBridgeSupportSymbol {

	@objc
	public var type: String?
	@objc
	public var type64: String?
	@objc
	public var isOpaque = false
}

@objc(MOBridgeSupportCFType)
public final class MOBridgeSupportCFType: MOBridgeSupportSymbol {

	@objc
	public var type: String?
	@objc
	public var type64: String?
	@objc
	public var tollFreeBridgedClassName: String?
	@objc
	public var getTypeIDFunctionName: String?
}

@objc(MOBridgeSupportOpaque)
public final class MOBridgeSupportOpaque: MOBridgeSupportSymbol {

	@objc
	public var type: String?
	@objc
	public var type64: String?
	@objc
	public var hasMagicCookie = false
}

@objc(MOBridgeSupportConstant)
public final class MOBridgeSupportConstant: MOBridgeSupportSymbol {

	@objc
	public var type: String?
	@objc
	public var type64: String?
	@objc
	public var hasMagicCookie = false
}

@objc(MOBridgeSupportStringConstant)
public final class MOBridgeSupportStringConstant: MOBridgeSupportSymbol {

	@objc
	public var value: String?
	@objc
	public var hasNSString = false
}

@objc(MOBridgeSupportEnum)
public final class MOBridgeSupportEnum: MOBridgeSupportSymbol {

	@objc
	public var value: NSNumber?
	@objc
	public var value64: NSNumber?
	@objc
	public var isIgnored = false
	@objc
	public var suggestion: String?
}

@objc(MOBridgeSupportFunction)
public final class MOBridgeSupportFunction: MOBridgeSupportSymbol {

	@objc
	public var isVariadic = false
	@objc
	public var sentinel: NSNumber?
	@objc
	public var isInlineFunction = false
	@objc
	public var arguments: [MOBridgeSupportArgument] = []
	@objc
	public var returnValue: MOBridgeSupportArgument?

	@objc public func addArgument(_ argument: MOBridgeSupportArgument) {
		if !arguments.contains(where: { $0 === argument }) {
			arguments.append(argument)
		}
	}

	@objc public func removeArgument(_ argument: MOBridgeSupportArgument) {
		arguments.removeAll { $0 === argument }
	}
}

@objc(MOBridgeSupportFunctionAlias)
public final class MOBridgeSupportFunctionAlias: MOBridgeSupportSymbol {

	@objc
	public var original: String?
}

@objc(MOBridgeSupportClass)
public class MOBridgeSupportClass: MOBridgeSupportSymbol {

	@objc
	public var methods: [MOBridgeSupportMethod] = []

	@objc public func addMethod(_ method: MOBridgeSupportMethod) {
		if !methods.contains(where: { $0 === method }) {
			methods.append(method)
		}
	}

	@objc public func removeMethod(_ method: MOBridgeSupportMethod) {
		methods.removeAll { $0 === method }
	}

	@objc
	public func method(withSelector selector: Selector) -> MOBridgeSupportMethod? {
		return methods.first { $0.selector == selector }
	}
}

@objc(MOBridgeSupportInformalProtocol)
public final class MOBridgeSupportInformalProtocol: MOBridgeSupportClass {}

@objc(MOBridgeSupportMethod)
public final class MOBridgeSupportMethod: MOBridgeSupportSymbol {

	@objc public var selector: Selector = #selector(NSObject.init)
	@objc public var type: String?
	@objc public var type64: String?
	@objc public var arguments: [MOBridgeSupportArgument] = []
	@objc public var returnValue: MOBridgeSupportArgument?
	@objc public var isClassMethod = false
	@objc public var isVariadic = false
	@objc public var sentinel: NSNumber?
	@objc public var isIgnored = false
	@objc public var suggestion: String?

	@objc public func addArgument(_ argument: MOBridgeSupportArgument) {
		if !arguments.contains(where: { $0 === argument }) {
			arguments.append(argument)
		}
	}

	@objc public func removeArgument(_ argument: MOBridgeSupportArgument) {
		arguments.removeAll { $0 === argument }
	}
}

@objc(MOBridgeSupportArgument)
public final class MOBridgeSupportArgument: NSObject {

	@objc public var type: String?
	@objc public var type64: String?
	@objc public var typeModifier: String?
	@objc public var signature: String?
	@objc public var signature64: String?
	@objc public var cArrayLengthInArg: String?
	@objc public var isCArrayOfFixedLength = false
	@objc public var isCArrayDelimitedByNull = false
	@objc public var isCArrayOfVariableLength = false
	@objc public var isCArrayLengthInReturnValue = false
	@objc public var index: UInt = 0
	@objc public var acceptsNull = false
	@objc public var acceptsPrintfFormat = false
	@objc public var isAlreadyRetained = false
	@objc public var isFunctionPointer = false
	@objc public var arguments: [MOBridgeSupportArgument] = []
	@objc public var returnValue: MOBridgeSupportArgument?

	@objc public func addArgument(_ argument: MOBridgeSupportArgument) {
		if !arguments.contains(where: { $0 === argument }) {
			arguments.append(argument)
		}
	}

	@objc public func removeArgument(_ argument: MOBridgeSupportArgument) {
		arguments.removeAll { $0 === argument }
	}
}
