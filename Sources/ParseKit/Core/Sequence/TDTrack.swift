//
//  TDTrack.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDTrack)
public final class TDTrack: TDSequence {

	@objc
	public static func track() -> TDTrack {
		return TDTrack()
	}

	public override func allMatches(for assemblies: Set<AnyHashable>?) -> Set<AnyHashable>? {
		var inTrack = false
		var last = assemblies ?? []
		var result = last
		for value in subparsers {
			guard let parser = value as? TDParser else {
				continue
			}
			result = parser.matchAndAssemble(result)
			if result.isEmpty {
				if inTrack {
					throwTrackException(previous: last, parser: parser)
				}
				break
			}
			inTrack = true
			last = result
		}
		return result
	}

	private func throwTrackException(previous assemblies: Set<AnyHashable>, parser: TDParser) -> Never {
		guard let best = best(assemblies) else {
			fatalError("TDTrack has no assembly")
		}
		let after = best.consumedObjectsJoined(by: " ").isEmpty ? "-nothing-" : best.consumedObjectsJoined(by: " ")
		let expected = String(describing: parser)
		let found = best.peek().map(String.init(describing:)) ?? "-nothing-"
		let reason = "\n\nAfter : \(after)\nExpected : \(expected)\nFound : \(found)\n\n"
		TDTrackException(name: NSExceptionName("Track Exception"), reason: reason, userInfo: ["after": after, "expected": expected, "found": found]).raise()
		fatalError("TDTrackException raised")
	}
}
