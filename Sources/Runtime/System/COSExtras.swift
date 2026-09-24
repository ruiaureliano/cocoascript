//
//  COSExtras.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: CocoaScript, created by August Mueller.
//

import AppKit
import Foundation
import ScriptingBridge

extension NSApplication {

	@nonobjc public func open(_ pathToFile: String) -> Any? {
		let url = URL(fileURLWithPath: pathToFile)
		return NSWorkspace.shared.open(url) ? url : nil
	}

	@nonobjc public func sharedDocumentController() -> NSDocumentController {
		return NSDocumentController.shared
	}

	@nonobjc public func standardUserDefaults() -> UserDefaults {
		return .standard
	}
}

extension NSData {

	@nonobjc public func write(toFile path: String) -> Bool {
		return write(to: URL(fileURLWithPath: path), atomically: true)
	}
}

extension NSObject {

	@nonobjc public var ojbcClass: AnyClass {
		return type(of: self)
	}
}

extension NSString {

	@nonobjc public var fileURL: URL {
		return URL(fileURLWithPath: String(self))
	}

	@nonobjc public class func stringWithUUID() -> String {
		return UUID().uuidString.lowercased()
	}
}

extension SBApplication {

	@nonobjc public class func application(named appName: String) -> SBApplication? {
		guard
			let url = NSWorkspace.shared.urlForApplication(toOpen: URL(fileURLWithPath: appName)),
			let bundleIdentifier = Bundle(url: url)?.bundleIdentifier
		else {
			return nil
		}
		return SBApplication(bundleIdentifier: bundleIdentifier)
	}
}
