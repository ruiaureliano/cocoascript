//
//  TDAssembly.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDAssembly)
open class TDAssembly: NSObject, NSCopying {

	@objc
	public private(set) var stack = NSMutableArray()

	@objc
	public var target: Any?

	internal var index = 0
	internal var string: String?

	@objc
	public var defaultDelimiter: String?

	@objc(assemblyWithString:)
	public class func assembly(with string: String?) -> TDAssembly {
		return TDAssembly(string: string)
	}
	@objc
	public override init() {
		super.init()
	}

	@objc(initWithString:)
	public init(string: String?) {
		self.string = string
		super.init()
	}

	open func peek() -> Any? {
		fatalError("TDAssembly.peek must be overridden")
	}

	open func next() -> Any? {
		fatalError("TDAssembly.next must be overridden")
	}

	open func hasMore() -> Bool {
		fatalError("TDAssembly.hasMore must be overridden")
	}

	open func consumedObjectsJoined(by delimiter: String) -> String {
		fatalError("TDAssembly must be overridden")
	}

	open func remainingObjectsJoined(by delimiter: String) -> String {
		fatalError("TDAssembly must be overridden")
	}

	@objc
	public var length: UInt {
		fatalError("TDAssembly.length must be overridden")
	}

	@objc
	public var objectsConsumed: UInt {
		fatalError("TDAssembly.objectsConsumed must be overridden")
	}

	@objc
	public var objectsRemaining: UInt {
		fatalError("TDAssembly.objectsRemaining must be overridden")
	}

	@objc
	public func pop() -> Any? {
		guard let value = stack.lastObject else {
			return nil
		}

		stack.removeLastObject()
		return value
	}

	@objc
	public func push(_ object: Any) {
		stack.add(object)
	}

	@objc
	public func isStackEmpty() -> Bool {
		return stack.count == 0
	}

	@objc
	public func objectsAbove(_ fence: Any) -> [Any] {
		var result = [Any]()
		while let object = pop() {
			if (object as AnyObject).isEqual(fence) {
				push(object)
				break
			}
			result.append(object)
		}
		return result
	}

	open func copy(with zone: NSZone? = nil) -> Any {
		return self
	}

	open override var description: String {
		let values = stack.map { String(describing: $0) }.joined(separator: ", ")
		let delimiter = defaultDelimiter ?? "/"
		return "[\(values)]\(consumedObjectsJoined(by: delimiter))^\(remainingObjectsJoined(by: delimiter))"
	}
}
