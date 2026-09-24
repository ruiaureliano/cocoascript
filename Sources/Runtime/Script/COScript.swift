//
//  COScript.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: CocoaScript, created by August Mueller.
//

import AppKit
import Darwin
import Foundation
import JavaScriptCore

private typealias COScriptMessageSend = @convention(c) (AnyObject?, Selector, NSString, AnyObject?) -> AnyObject?

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

	@objc(application:)
	public class func application(_ app: String) -> Any? {
		let applicationURL = applicationURL(for: app)
		guard
			let url = applicationURL,
			let bundleIdentifier = Bundle(url: url)?.bundleIdentifier
		else {
			return NSNumber(value: false)
		}

		let isRunning = NSWorkspace.shared.runningApplications.contains {
			$0.bundleIdentifier == bundleIdentifier
		}

		if !isRunning {
			let configuration = NSWorkspace.OpenConfiguration()
			configuration.activates = false
			configuration.hides = true
			NSWorkspace.shared.openApplication(at: url, configuration: configuration)
		}

		return applicationOnPort("\(bundleIdentifier).JSTalk")
	}

	private class func applicationURL(for app: String) -> URL? {
		if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app) {
			return url
		}

		let fileManager = FileManager.default
		let explicitURL = URL(fileURLWithPath: app)
		if fileManager.fileExists(atPath: explicitURL.path) {
			return explicitURL
		}

		let applicationDirectories = [
			URL(fileURLWithPath: "/Applications"),
			URL(fileURLWithPath: "/System/Applications"),
			fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Applications")
		]

		for directory in applicationDirectories {
			guard
				let applications = try? fileManager.contentsOfDirectory(
					at: directory,
					includingPropertiesForKeys: nil,
					options: .skipsHiddenFiles
				)
			else {
				continue
			}

			if let application = applications.first(where: { application in
				guard application.pathExtension == "app" else {
					return false
				}

				let bundle = Bundle(url: application)
				let name = bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String
				let displayName = bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
				return application.deletingPathExtension().lastPathComponent == app
					|| name == app
					|| displayName == app
			}) {
				return application
			}
		}

		return nil
	}

	@objc(app:)
	public class func app(_ app: String) -> Any? {
		return application(app)
	}

	@objc(proxyForApp:)
	public class func proxyForApp(_ app: String) -> Any? {
		return application(app)
	}

	private class func applicationOnPort(_ port: String) -> AnyObject? {
		guard let messageSendPointer = dlsym(dlopen(nil, RTLD_NOW), "objc_msgSend") else {
			return nil
		}
		let messageSend = unsafeBitCast(messageSendPointer, to: COScriptMessageSend.self)

		guard
			let connectionClass = NSClassFromString("NSConnection") as AnyObject?,
			let factorySelector = NSSelectorFromString("connectionWithRegisteredName:host:") as Selector?
		else {
			return nil
		}

		for _ in 0..<10 {
			if let connection = messageSend(
				connectionClass,
				factorySelector,
				port as NSString,
				nil
			) {
				let rootProxySelector = NSSelectorFromString("rootProxy")
				return messageSend(connection, rootProxySelector, "" as NSString, nil)
			}

			Thread.sleep(forTimeInterval: 1)
		}

		return nil
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
