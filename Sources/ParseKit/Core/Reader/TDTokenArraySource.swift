//
//  TDTokenArraySource.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

@objc(TDTokenArraySource)
public final class TDTokenArraySource: NSObject {

	private let tokenizer: TDTokenizer
	private let delimiter: String
	private var bufferedToken: TDToken?

	@objc(initWithTokenizer:delimiter:)
	public init(tokenizer: TDTokenizer, delimiter: String) {
		self.tokenizer = tokenizer
		self.delimiter = delimiter
		super.init()
	}

	@objc
	public func hasMore() -> Bool {
		if bufferedToken == nil {
			bufferedToken = tokenizer.nextToken()
		}

		return bufferedToken !== TDToken.eof
	}

	@objc public func nextTokenArray() -> [TDToken]? {
		guard
			hasMore(),
			let first = bufferedToken
		else {
			return nil
		}
		bufferedToken = nil
		var result = [first]
		while let token = tokenizer.nextToken(), token !== TDToken.eof {
			if token.stringValue == delimiter {
				break
			}
			result.append(token)
		}
		return result
	}
}
