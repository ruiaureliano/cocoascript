//
//  TDReader.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDReader)
public final class TDReader: NSObject {

	@objc
	public var string: String? {
		didSet {
			cursor = 0
		}
	}
	private var cursor = 0

	@objc
	public override init() {
		string = nil
		super.init()
	}

	@objc(initWithString:)
	public init(string: String?) {
		self.string = string
		super.init()
	}

	@objc
	public func read() -> Int {
		guard
			let string,
			cursor < string.utf16.count
		else {
			return -1
		}
		defer { cursor += 1 }
		return Int(string.utf16[string.utf16.index(string.utf16.startIndex, offsetBy: cursor)])
	}

	@objc
	public func unread() {
		if cursor > 0 {
			cursor -= 1
		}
	}
}
