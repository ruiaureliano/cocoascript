//
//  Mocha.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/10/12.
//  Copyright 2012 Logan Collins. All rights reserved.
//

import Foundation
import JavaScriptCore

public final class Mocha: NSObject {

	public weak var delegate: AnyObject?
	public var frameworkSearchPaths: [String] = [
		"/System/Library/Frameworks",
		"/Library/Frameworks"
	]

	private let jsContext: JSContext

	nonisolated(unsafe) public static let sharedRuntime = Mocha()

	public override init() {
		jsContext = JSContext()!
		super.init()
		jsContext.exceptionHandler = { _, exception in
			if let exception {
				NSLog("Mocha JavaScript exception: %@", String(describing: exception))
			}
		}
		installBuiltins()
	}

	public static func runtimeWithContext(_ context: JSContextRef) -> Mocha {
		return sharedRuntime
	}

	public func context() -> JSGlobalContextRef {
		return jsContext.jsGlobalContextRef
	}

	public func evalString(_ string: String) -> Any? {
		return jsContext.evaluateScript(string)?.toObject()
	}

	public func evalString(_ string: String, atURL url: URL) -> Any? {
		return jsContext.evaluateScript(string, withSourceURL: url)?.toObject()
	}

	public func evalString(_ string: String, atURL url: URL?) -> Any? {
		guard let url else {
			return evalString(string)
		}
		return evalString(string, atURL: url)
	}

	public func callFunction(withName name: String) -> Any? {
		return callFunction(withName: name, arguments: [])
	}

	public func callFunction(withName name: String, arguments: [Any]) -> Any? {
		return jsContext.objectForKeyedSubscript(name)?.call(withArguments: arguments)?.toObject()
	}

	public func isSyntaxValid(for string: String) -> Bool {
		let script = "try { new Function(\(String(reflecting: string))); true } catch (_) { false }"
		return (jsContext.evaluateScript(script)?.toBool()) ?? false
	}

	public func loadFramework(withName name: String) -> Bool {
		let candidates = frameworkSearchPaths.map { URL(fileURLWithPath: $0).appendingPathComponent("\(name).framework") }
		return candidates.contains { FileManager.default.fileExists(atPath: $0.path) }
	}

	public func loadFramework(withName name: String, inDirectory directory: String) -> Bool {
		let path = URL(fileURLWithPath: directory).appendingPathComponent("\(name).framework").path
		return FileManager.default.fileExists(atPath: path)
	}

	public func addFrameworkSearchPath(_ path: String) {
		guard !frameworkSearchPaths.contains(path) else {
			return
		}
		frameworkSearchPaths.append(path)
	}

	public func insertFrameworkSearchPath(_ path: String, at index: Int) {
		guard !frameworkSearchPaths.contains(path) else {
			return
		}
		let safeIndex = min(max(index, 0), frameworkSearchPaths.count)
		frameworkSearchPaths.insert(path, at: safeIndex)
	}

	public func removeFrameworkSearchPath(at index: Int) {
		guard frameworkSearchPaths.indices.contains(index) else {
			return
		}
		frameworkSearchPaths.remove(at: index)
	}

	@discardableResult
	public func setObject(_ object: Any?, withName name: String) -> JSValue? {
		jsContext.setObject(object, forKeyedSubscript: name as NSString)
		return jsContext.objectForKeyedSubscript(name)
	}

	public func object(withName name: String) -> Any? {
		return jsContext.objectForKeyedSubscript(name)?.toObject()
	}

	public func jsValue(for object: Any?) -> JSValueRef {
		return JSValue(object: object, in: jsContext).jsValueRef
	}

	public func object(forJSValue value: JSValueRef) -> Any? {
		return JSValue(jsValueRef: value, in: jsContext)?.toObject()
	}

	public func jsFunction(withName name: String) -> JSObjectRef? {
		guard
			let value = jsContext.objectForKeyedSubscript(name)?.jsValueRef,
			JSValueIsObject(context(), value)
		else {
			return nil
		}
		return JSValueToObject(context(), value, nil)
	}

	public func callJSFunction(_ function: JSObjectRef, withArguments arguments: [Any] = []) -> Any? {
		let values = arguments.map { JSValue(object: $0, in: jsContext).jsValueRef }
		return values.withUnsafeBufferPointer { buffer in
			guard
				let result = JSObjectCallAsFunction(context(), function, nil, buffer.count, buffer.baseAddress, nil)
			else {
				return nil
			}
			return object(forJSValue: result)
		}
	}

	public func evalJSString(_ string: String) -> JSValueRef? {
		return jsContext.evaluateScript(string)?.jsValueRef
	}

	@discardableResult
	public func removeObject(withName name: String) -> Bool {
		guard jsContext.objectForKeyedSubscript(name) != nil else {
			return false
		}
		jsContext.setObject(nil, forKeyedSubscript: name as NSString)
		return true
	}

	public func loadBridgeSupportFiles(atPath path: String) -> Bool {
		do {
			return try MOBridgeSupportController.sharedController.loadBridgeSupport(at: URL(fileURLWithPath: path))
		} catch {
			return false
		}
	}

	public var globalSymbolNames: [String] {
		return Array(MOBridgeSupportController.sharedController.symbols.keys).sorted()
	}

	public func garbageCollect() {
		JSGarbageCollect(context())
	}

	public func installBuiltins() {
		_ = jsContext.evaluateScript("var nil = null;")
	}

	public func print(_ value: Any?) {
		Swift.print(String(describing: value))
	}

	public func cleanUp() {
		let globalNames = globalSymbolNames
		for name in globalNames {
			removeObject(withName: name)
		}
	}

	public func shutdown() {
		cleanUp()
		garbageCollect()
	}
}
