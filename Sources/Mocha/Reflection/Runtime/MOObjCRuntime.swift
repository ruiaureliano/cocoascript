//
//  MOObjCRuntime.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/16/12.
//  Copyright (c) 2012 Logan Collins. All rights reserved.
//

import Foundation
import ObjectiveC.runtime

@objc(MOObjCRuntime)
public final class MOObjCRuntime: NSObject {

	@objc
	nonisolated(unsafe) public static let sharedRuntime = MOObjCRuntime()

	@objc
	public var classes: [String] {
		var count: UInt32 = 0
		guard let classList = objc_copyClassList(&count) else {
			return []
		}
		defer { free(UnsafeMutableRawPointer(classList)) }

		return (0..<Int(count)).compactMap { index in
			let name = String(cString: class_getName(classList[index]))
			return name.hasPrefix("_") ? nil : name
		}.sorted { $0.caseInsensitiveCompare($1) == .orderedAscending }
	}

	@objc
	public var protocols: [String] {
		var count: UInt32 = 0
		guard let protocolList = objc_copyProtocolList(&count) else {
			return []
		}
		defer { free(UnsafeMutableRawPointer(protocolList)) }

		return (0..<Int(count)).compactMap { index in
			let protocolName = protocol_getName(protocolList[index])
			let name = String(cString: protocolName)
			return name.hasPrefix("_") ? nil : name
		}.sorted { $0.caseInsensitiveCompare($1) == .orderedAscending }
	}
}
