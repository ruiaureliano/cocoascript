//
//  COSPreprocessor.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: jstalk, created by August Mueller on 2/14/09.
//  Copyright 2009 Flying Meat Inc. All rights reserved.
//

import CocoaScriptParseKitSwift
import Foundation

@objc(COSPreprocessor)
public final class COSPreprocessor: NSObject {

	public static func preprocessCode(_ sourceString: String) -> String {
		return preprocessCode(sourceString, withBaseURL: nil)
	}

	public static func preprocessCode(_ sourceString: String, withBaseURL base: URL?) -> String {
		var importedURLs = [URL]()
		if let base {
			importedURLs.append(base)
		}

		var source = processImports(sourceString, withBaseURL: base, importedURLs: &importedURLs)
		source = processMultilineStrings(source)
		source = preprocessForObjCStrings(source)
		source = preprocessForObjCMessagesToJS(source)
		return source
	}

	private static func processMultilineStrings(_ sourceString: String) -> String {
		let token = "\"\"\""
		var result = ""
		var cursor = sourceString.startIndex

		while cursor < sourceString.endIndex {
			guard let start = sourceString[cursor...].range(of: token) else {
				result.append(contentsOf: sourceString[cursor...])
				break
			}

			result.append(contentsOf: sourceString[cursor..<start.lowerBound])
			let contentStart = start.upperBound
			guard let end = sourceString[contentStart...].range(of: token) else {
				result.append(contentsOf: sourceString[start.lowerBound...])
				break
			}

			let content = sourceString[contentStart..<end.lowerBound]
			if content.hasPrefix(token) {
				cursor = end.upperBound
				continue
			}

			let normalized =
				content
				.replacingOccurrences(of: "\r\n", with: "\n")
				.replacingOccurrences(of: "\r", with: "\n")

			let lines = normalized.split(separator: "\n", omittingEmptySubsequences: false)
			result.append("\"")
			for index in lines.indices {
				let line = lines[index].replacingOccurrences(of: "\"", with: "\\\"")
				result.append(contentsOf: line)
				if index != lines.index(before: lines.endIndex) {
					result.append("\\n")
				}
			}
			result.append("\"")
			cursor = end.upperBound
		}

		return result
	}

	private static func preprocessForObjCStrings(_ sourceString: String) -> String {
		let tokenizer = TDTokenizer(string: sourceString)
		tokenizer.whitespaceState.reportsWhitespaceTokens = true
		tokenizer.commentState.reportsCommentTokens = false
		let eof = TDToken.EOFToken()
		var result = ""

		while let token = tokenizer.nextToken(), token !== eof {
			if token.symbol, token.stringValue == "@", let next = tokenizer.nextToken() {
				if next.quotedString {
					result += "[NSString stringWithString:\(next.stringValue)]"
				} else {
					result += token.stringValue + next.stringValue
				}
			} else {
				result += token.stringValue
			}
		}

		return result
	}

	private static func isOpenSymbol(_ tag: String) -> Bool {
		return tag == "[" || tag == "("
	}

	private static func isCloseSymbol(_ tag: String) -> Bool {
		return tag == "]" || tag == ")"
	}

	private static func fixTypeToVar(_ type: String) -> String {
		let types = ["double", "float", "CGFloat", "long", "NSInteger", "NSUInteger", "id", "bool", "BOOL", "int"]
		return types.contains(type) ? "var" : type
	}

	private static func preprocessForObjCMessagesToJS(_ sourceString: String) -> String {
		let tokenizer = TDTokenizer(string: sourceString)
		tokenizer.whitespaceState.reportsWhitespaceTokens = true
		tokenizer.commentState.reportsCommentTokens = true
		let eof = TDToken.EOFToken()
		var result = ""
		var currentGroup: JSTPSymbolGroup?

		while let token = tokenizer.nextToken(), token !== eof {
			if token.symbol, isOpenSymbol(token.stringValue) {
				let group = JSTPSymbolGroup()
				group.parent = currentGroup
				currentGroup = group
			} else if token.symbol, isCloseSymbol(token.stringValue) {
				if let parent = currentGroup?.parent {
					parent.addSymbol(currentGroup as Any)
				} else if let currentGroup {
					result += currentGroup.description
				}
				currentGroup = currentGroup?.parent
				continue
			}

			if let currentGroup {
				currentGroup.addSymbol(token)
			} else {
				result += Self.fixTypeToVar(token.stringValue)
			}
		}

		return result
	}

	private static func processImports(_ sourceString: String, withBaseURL base: URL?, importedURLs: inout [URL]) -> String {
		let tokenizer = TDTokenizer(string: sourceString)
		tokenizer.whitespaceState.reportsWhitespaceTokens = true
		tokenizer.commentState.reportsCommentTokens = true
		let eof = TDToken.EOFToken()
		var result = ""
		var lastWasAtSymbol = false

		while let token = tokenizer.nextToken(), token !== eof {
			if token.symbol, token.stringValue == "@" {
				lastWasAtSymbol = true
				continue
			}

			if lastWasAtSymbol {
				lastWasAtSymbol = false
				if token.word, token.stringValue == "import" {
					_ = tokenizer.nextToken()
					guard let quotedPath = tokenizer.nextToken()?.stringValue, quotedPath.count >= 2 else {
						continue
					}
					let path = (String(quotedPath.dropFirst().dropLast()) as NSString).expandingTildeInPath
					let importURL: URL?
					if !path.hasPrefix("/"), let base {
						importURL = base.deletingLastPathComponent().appendingPathComponent(path)
					} else if base != nil {
						importURL = URL(fileURLWithPath: path)
					} else {
						result += "'Unable to import \(path) because we have no base url to import from'"
						importURL = nil
					}

					if let importURL {
						if importedURLs.contains(importURL) {
							result += "// skipping already imported file from \(importURL.path)\n"
						} else if let imported = try? String(contentsOf: importURL, encoding: .utf8) {
							importedURLs.append(importURL)
							result += "// imported from \(importURL.path)\n"
							result += processImports(imported, withBaseURL: base, importedURLs: &importedURLs)
						} else {
							result += "'Unable to import \(path)'"
						}
					}
					continue
				}
				result += "@"
			}

			result += token.stringValue
		}

		return result
	}
}

@objc(JSTPSymbolGroup)
public final class JSTPSymbolGroup: NSObject {

	private var openSymbol: Character?
	private var symbols = [Any]()
	@objc public weak var parent: JSTPSymbolGroup?

	@objc public func addSymbol(_ symbol: Any) {
		if openSymbol == nil, let token = symbol as? TDToken {
			openSymbol = token.stringValue.first
		} else {
			symbols.append(symbol)
		}
	}

	private func nonWhitespaceCount(in values: [String]) -> Int {
		return values.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
	}

	public override var description: String {
		guard let openSymbol else {
			return "Bad JSTPSymbolGroup! \(symbols)"
		}
		if openSymbol == "(" {
			return "(\(symbols.map { String(describing: $0) }.joined()))"
		}
		guard openSymbol == "[" else {
			return "Bad JSTPSymbolGroup! \(symbols)"
		}

		let firstIsWord = symbols.first as? TDToken
		let firstIsGroup = symbols.first is JSTPSymbolGroup
		guard firstIsWord?.word == true || firstIsGroup else {
			return "[\(symbols.map { String(describing: $0) }.joined())]"
		}

		let target = String(describing: symbols[0])
		var selector = ""
		var currentArguments = [String]()
		var methodArguments = [String]()
		var lastWord: String?
		var hadSymbolAsArgument = false

		for symbol in symbols.dropFirst() {
			let token = symbol as? TDToken
			let value = token?.stringValue ?? String(describing: symbol)
			if token?.whitespace == true {
				currentArguments.append(value)
				continue
			}
			if !hadSymbolAsArgument, token?.symbol == true {
				hadSymbolAsArgument = true
			}
			if value == ":" {
				if !currentArguments.isEmpty {
					currentArguments.removeLast()
				}
				if !currentArguments.isEmpty {
					methodArguments.append(currentArguments.joined(separator: " "))
					currentArguments.removeAll()
				}
				selector += (lastWord ?? "") + value
			} else {
				currentArguments.append(value.trimmingCharacters(in: .whitespacesAndNewlines))
			}
			lastWord = value
		}

		if !currentArguments.isEmpty {
			methodArguments.append(currentArguments.joined())
		}
		if selector.isEmpty, !hadSymbolAsArgument, methodArguments.count == 1 {
			selector = methodArguments.removeLast()
		}
		if selector.isEmpty, methodArguments.count == 1 {
			return "[\(target)\(methodArguments[0])]"
		}
		if methodArguments.isEmpty, selector.isEmpty {
			return "[\(target)]"
		}
		if selector.isEmpty, let lastWord {
			selector = lastWord
			if !methodArguments.isEmpty {
				methodArguments.removeLast()
			}
		}

		selector = selector.replacingOccurrences(of: ":", with: "_")
		var result = "\(target).\(selector)("
		if nonWhitespaceCount(in: methodArguments) > 0 {
			result += methodArguments.enumerated().map { _, argument in argument }.joined(separator: ",")
		}
		return result + ")"
	}
}
