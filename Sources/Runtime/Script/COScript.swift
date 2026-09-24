//
//  COScript.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: CocoaScript, created by August Mueller.
//

import Foundation
import JavaScriptCore

public final class COScript: NSObject {

	private static let currentStackKey = "CocoaScript.currentCOScriptStack"

	public weak var printController: AnyObject?
	public weak var errorController: AnyObject?
	public var env = NSMutableDictionary()
	public var shouldPreprocess = true
	public var shouldKeepAround = false

	private let jsContext: JSContext

	public override init() {
		jsContext = JSContext()!
		super.init()
		jsContext.exceptionHandler = { [weak self] _, exception in
			if let exception {
				self?.print("JavaScript exception: \(exception)")
			}
		}
		pushObject(self, withName: "jstalk")
		pushObject(self, withName: "coscript")
		jsContext.evaluateScript("var nil = null;")
	}

	public func cleanup() {
		deleteObject(withName: "jstalk")
		deleteObject(withName: "coscript")
		cleanupFibers()
	}

	public func garbageCollect() {
		JSGarbageCollect(context())
	}

	public func shouldKeepRunning() -> Bool {
		return shouldKeepAround || hasActiveFibers()
	}

	public func context() -> JSGlobalContextRef {
		return jsContext.jsGlobalContextRef
	}

	public func executeString(_ string: String) -> Any? {
		return executeString(string, baseURL: nil)
	}

	public func executeString(_ string: String, baseURL: URL?) -> Any? {
		let resolvedBaseURL = baseURL ?? env["scriptURL"] as? URL
		let source: String
		if shouldPreprocess {
			source = COSPreprocessor.preprocessCode(string, withBaseURL: resolvedBaseURL)
		} else {
			source = string
		}
		pushAsCurrentCOScript()
		defer { popAsCurrentCOScript() }
		return jsContext.evaluateScript(source)?.toObject()
	}

	public func pushObject(_ object: Any, withName name: String) {
		jsContext.setObject(object, forKeyedSubscript: name as NSString)
	}

	public func deleteObject(withName name: String) {
		jsContext.setObject(nil, forKeyedSubscript: name as NSString)
	}

	public func hasFunctionNamed(_ name: String) -> Bool {
		return jsContext.objectForKeyedSubscript(name)?.isObject == true
	}

	public func callFunctionNamed(_ name: String, withArguments arguments: [Any] = []) -> Any? {
		pushAsCurrentCOScript()
		defer { popAsCurrentCOScript() }
		return jsContext.objectForKeyedSubscript(name)?.call(withArguments: arguments)?.toObject()
	}

	public func callJSFunction(_ function: JSObjectRef, withArgumentsIn arguments: [Any]) -> Any? {
		pushAsCurrentCOScript()
		defer { popAsCurrentCOScript() }
		let values = arguments.map { JSValue(object: $0, in: jsContext).jsValueRef }
		return values.withUnsafeBufferPointer { buffer in
			guard let result = JSObjectCallAsFunction(context(), function, nil, buffer.count, buffer.baseAddress, nil) else {
				return nil
			}
			return JSValue(jsValueRef: result, in: jsContext)?.toObject()
		}
	}

	public func print(_ string: String) {
		if let printController, printController.responds(to: NSSelectorFromString("print:")) {
			_ = printController.perform(NSSelectorFromString("print:"), with: string)
		} else {
			Swift.print(string)
		}
	}

	public func include(_ fileName: String) {
		let resolvedURL: URL
		if fileName.hasPrefix("/") {
			resolvedURL = URL(fileURLWithPath: fileName)
		} else if let scriptURL = env["scriptURL"] as? URL {
			resolvedURL = scriptURL.deletingLastPathComponent().appendingPathComponent(fileName)
		} else {
			resolvedURL = URL(fileURLWithPath: fileName)
		}

		do {
			var source = try String(contentsOf: resolvedURL, encoding: .utf8)
			if shouldPreprocess {
				source = COSPreprocessor.preprocessCode(source, withBaseURL: resolvedURL)
			}
			_ = jsContext.evaluateScript(source, withSourceURL: resolvedURL)
		} catch {
			print("Could not include '\(resolvedURL.path)': \(error)")
		}
	}

	public func printException(_ exception: Error) {
		print(String(describing: exception))
	}

	public static func current() -> COScript {
		if let script = currentCOSThreadStack().lastObject as? COScript {
			return script
		}
		let script = COScript()
		script.pushAsCurrentCOScript()
		return script
	}

	public class func currentCOSThreadStack() -> NSMutableArray {
		if let stack = Thread.current.threadDictionary[currentStackKey] as? NSMutableArray {
			return stack
		}
		let stack = NSMutableArray()
		Thread.current.threadDictionary[currentStackKey] = stack
		return stack
	}

	public func pushAsCurrentCOScript() {
		Self.currentCOSThreadStack().add(self)
	}

	public func popAsCurrentCOScript() {
		let stack = Self.currentCOSThreadStack()
		guard stack.lastObject != nil else {
			return
		}
		stack.removeLastObject()
	}
}
