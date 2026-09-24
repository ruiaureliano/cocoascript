//
//  MOStruct.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/15/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

import Foundation

@objc(MOStruct)
public final class MOStruct: NSObject {

	@objc
	public let name: String
	@objc
	public let memberNames: [String]
	private var memberValues: [String: Any] = [:]

	@objc
	public static func structure(withName name: String, memberNames: [String]) -> MOStruct {
		return MOStruct(name: name, memberNames: memberNames)
	}

	@objc public init(name: String, memberNames: [String]) {
		self.name = name
		self.memberNames = memberNames
		super.init()
	}

	@objc public func object(forMemberName memberName: String) -> Any? {
		guard memberNames.contains(memberName) else {
			NSException(
				name: NSExceptionName("MORuntimeException"),
				reason: "Struct \(name) has no member named \(memberName)",
				userInfo: nil
			).raise()
			return nil
		}
		return memberValues[memberName]
	}

	@objc public func setObject(_ object: Any?, forMemberName memberName: String) {
		guard memberNames.contains(memberName) else {
			NSException(
				name: NSExceptionName("MORuntimeException"),
				reason: "Struct \(name) has no member named \(memberName)",
				userInfo: nil
			).raise()
			return
		}
		memberValues[memberName] = object
	}

	public override var description: String {
		return description(withIndent: 0)
	}

	@objc(descriptionWithIndent:)
	public func description(withIndent indent: Int) -> String {
		let indentation = String(repeating: "    ", count: max(indent, 0))
		var lines = ["{"]
		for (index, memberName) in memberNames.enumerated() {
			let value = memberValues[memberName]
			let rendered: String
			if let value = value as? MOStruct {
				rendered = value.description(withIndent: indent + 1)
			} else {
				rendered = String(describing: value)
			}
			let comma = index == memberNames.count - 1 ? "" : ","
			lines.append("\(indentation)    \(memberName) = \(rendered)\(comma)")
		}
		lines.append("\(indentation)}")
		return "\(name) \(lines.joined(separator: "\n"))"
	}
}
