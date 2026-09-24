//
//  MOUtilities.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/11/12.
//  Copyright 2012 Sunflower Softworks. All rights reserved.
//

import Foundation
import JavaScriptCore

public func MOJSValueToType(_ context: JSContextRef, _ object: JSObjectRef, _ type: JSType) -> JSValueRef? {
	guard let privatePointer = JSObjectGetPrivate(object) else {
		return nil
	}
	let box = Unmanaged<MOBox>.fromOpaque(privatePointer).takeUnretainedValue()
	guard let representedObject = box.representedObject else {
		return nil
	}

	if let string = representedObject as? String {
		let jsString = JSStringCreateWithCFString(string as CFString)
		defer {
			JSStringRelease(jsString)
		}
		return JSValueMakeString(context, jsString)
	}
	if let number = representedObject as? NSNumber {
		return JSValueMakeNumber(context, number.doubleValue)
	}
	let description = String(describing: representedObject)
	let jsString = JSStringCreateWithCFString(description as CFString)
	defer {
		JSStringRelease(jsString)
	}
	return JSValueMakeString(context, jsString)
}

public func MOJSValueToString(_ context: JSContextRef, _ value: JSValueRef?) -> String? {
	guard let value, !JSValueIsNull(context, value) else {
		return nil
	}
	var exception: JSValueRef?
	guard let string = JSValueToStringCopy(context, value, &exception) else {
		return nil
	}
	defer {
		JSStringRelease(string)
	}
	let length = JSStringGetMaximumUTF8CStringSize(string)
	var buffer = [CChar](repeating: 0, count: length)
	_ = JSStringGetUTF8CString(string, &buffer, length)
	let bytes = buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
	return String(decoding: bytes, as: UTF8.self)
}

public func MOSelectorFromPropertyName(_ propertyName: String) -> Selector {
	return NSSelectorFromString(propertyName)
}

public func MOSelectorToPropertyName(_ selector: Selector) -> String {
	return NSStringFromSelector(selector)
}

public func MOPropertyNameToSetterName(_ propertyName: String) -> String {
	guard let first = propertyName.first else {
		return "set:"
	}
	return "set\(String(first).uppercased())\(propertyName.dropFirst()):"
}

public func MOFunctionArgumentForTypeEncoding(_ typeEncoding: String) -> MOFunctionArgument {
	let argument = MOFunctionArgument()
	guard let encoding = typeEncoding.utf8.first else {
		return argument
	}
	argument.setTypeEncoding(Int8(bitPattern: encoding), withCustomStorage: nil)
	return argument
}

public func MOParseObjCMethodEncoding(_ typeEncoding: UnsafePointer<CChar>) -> [MOFunctionArgument] {
	let encoding = String(cString: typeEncoding)
	var result = [MOFunctionArgument]()
	var index = encoding.startIndex

	while index < encoding.endIndex {
		let character = encoding[index]
		if character.isNumber || character == "r" || character == "n" || character == "N" || character == "o" || character == "O" || character == "R" || character == "V" {
			index = encoding.index(after: index)
			continue
		}
		let argument = MOFunctionArgumentForTypeEncoding(String(character))
		result.append(argument)
		index = encoding.index(after: index)
	}

	return result
}

public func MOSelectorIsVariadic(_ objectClass: AnyClass, _ selector: Selector) -> Bool {
	return false
}

public func MOInvocationGetObjCCallAddressForArguments(_ arguments: [MOFunctionArgument]) -> UnsafeMutableRawPointer? {
	return nil
}

public func MOFunctionInvoke(
	_ function: Any,
	_ context: JSContextRef,
	_ argumentCount: Int,
	_ arguments: UnsafePointer<JSValueRef?>?,
	_ exception: UnsafeMutablePointer<JSValueRef?>?
) -> JSValueRef? {
	guard
		let function = function as? MOJavaScriptObject,
		let object = function.JSObject
	else {
		return nil
	}
	return JSObjectCallAsFunction(context, object, nil, argumentCount, arguments, exception)
}
