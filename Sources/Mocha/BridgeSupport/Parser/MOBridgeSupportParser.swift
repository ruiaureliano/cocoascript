//
//  MOBridgeSupportParser.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: Mocha, created by Logan Collins on 5/11/12.
//  Copyright (c) 2012 Logan Collins. All rights reserved.
//

import Foundation

@objc(MOBridgeSupportParser)
public final class MOBridgeSupportParser: NSObject, XMLParserDelegate {

	private var library: MOBridgeSupportLibrary?
	private var symbolStack: [AnyObject] = []

	public func library(withBridgeSupportURL url: URL) throws -> MOBridgeSupportLibrary {
		let parser = XMLParser(contentsOf: url)
		guard let parser else {
			throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadUnknownError)
		}
		parser.delegate = self
		guard
			parser.parse(),
			let library
		else {
			throw parser.parserError ?? NSError(domain: NSCocoaErrorDomain, code: 1)
		}
		return library
	}

	public func parserDidStartDocument(_ parser: XMLParser) {
		library = MOBridgeSupportLibrary()
		symbolStack.removeAll(keepingCapacity: true)
	}

	public func parser(
		_ parser: XMLParser, didStartElement elementName: String,
		namespaceURI: String?, qualifiedName qName: String?,
		attributes attributeDict: [String: String] = [:]
	) {
		guard let library else {
			return
		}
		switch elementName {
		case "depends_on":
			if let path = attributeDict["path"] {
				library.addDependency(path)
			}
		case "struct":
			let symbol = MOBridgeSupportStruct()
			symbol.name = attributeDict["name"]
			symbol.type = attributeDict["type"]
			symbol.type64 = attributeDict["type64"]
			symbol.isOpaque = bool(attributeDict["opaque"])
			library.setSymbol(symbol, forName: symbol.name ?? "")
		case "cftype":
			let symbol = MOBridgeSupportCFType()
			symbol.name = attributeDict["name"]
			symbol.type = attributeDict["type"]
			symbol.type64 = attributeDict["type64"]
			symbol.tollFreeBridgedClassName = attributeDict["tollfree"]
			symbol.getTypeIDFunctionName = attributeDict["gettypeid_func"]
			library.setSymbol(symbol, forName: symbol.name ?? "")
		case "opaque":
			let symbol = MOBridgeSupportOpaque()
			symbol.name = attributeDict["name"]
			symbol.type = attributeDict["type"]
			symbol.type64 = attributeDict["type64"]
			library.setSymbol(symbol, forName: symbol.name ?? "")
		case "constant":
			let symbol = MOBridgeSupportConstant()
			symbol.name = attributeDict["name"]
			symbol.type = attributeDict["type"]
			symbol.type64 = attributeDict["type64"]
			symbol.hasMagicCookie = bool(attributeDict["magic_cookie"])
			library.setSymbol(symbol, forName: symbol.name ?? "")
		case "string_constant":
			let symbol = MOBridgeSupportStringConstant()
			symbol.name = attributeDict["name"]
			symbol.value = attributeDict["value"]
			symbol.hasNSString = bool(attributeDict["nsstring"])
			library.setSymbol(symbol, forName: symbol.name ?? "")
		case "enum":
			let symbol = MOBridgeSupportEnum()
			symbol.name = attributeDict["name"]
			if let value = attributeDict["value"].flatMap(Int.init) {
				symbol.value = NSNumber(value: value)
			}
			if let value = attributeDict["value64"].flatMap(Int.init) {
				symbol.value64 = NSNumber(value: value)
			}
			symbol.isIgnored = bool(attributeDict["ignore"])
			symbol.suggestion = attributeDict["suggestion"]
			library.setSymbol(symbol, forName: symbol.name ?? "")
		case "function":
			let symbol = MOBridgeSupportFunction()
			symbol.name = attributeDict["name"]
			symbol.isVariadic = bool(attributeDict["variadic"])
			if let value = attributeDict["sentinel"].flatMap(Int.init) {
				symbol.sentinel = NSNumber(value: value)
			}
			symbol.isInlineFunction = bool(attributeDict["inline"])
			library.setSymbol(symbol, forName: symbol.name ?? "")
			symbolStack.append(symbol)
		case "function_alias":
			let symbol = MOBridgeSupportFunctionAlias()
			symbol.name = attributeDict["name"]
			symbol.original = attributeDict["original"]
			library.setSymbol(symbol, forName: symbol.name ?? "")
		case "class":
			let symbol = MOBridgeSupportClass()
			symbol.name = attributeDict["name"]
			library.setSymbol(symbol, forName: symbol.name ?? "")
			symbolStack.append(symbol)
		case "informal_protocol":
			let symbol = MOBridgeSupportInformalProtocol()
			symbol.name = attributeDict["name"]
			library.setSymbol(symbol, forName: symbol.name ?? "")
			symbolStack.append(symbol)
		case "method":
			let symbol = MOBridgeSupportMethod()
			symbol.name = attributeDict["name"]
			if let selector = attributeDict["selector"] {
				symbol.selector = NSSelectorFromString(selector)
			}
			symbol.type = attributeDict["type"]
			symbol.type64 = attributeDict["type64"]
			symbol.isClassMethod = bool(attributeDict["class_method"])
			symbol.isVariadic = bool(attributeDict["variadic"])
			if let value = attributeDict["sentinel"].flatMap(Int.init) {
				symbol.sentinel = NSNumber(value: value)
			}
			symbol.isIgnored = bool(attributeDict["ignore"])
			symbol.suggestion = attributeDict["suggestion"]
			if let parent = symbolStack.last as? MOBridgeSupportClass {
				parent.addMethod(symbol)
			}
			symbolStack.append(symbol)
		case "arg":
			let argument = makeArgument(attributeDict)
			attachArgument(argument, asReturnValue: false)
			symbolStack.append(argument)
		case "retval":
			let argument = makeArgument(attributeDict)
			attachArgument(argument, asReturnValue: true)
			symbolStack.append(argument)
		default:
			break
		}
	}

	public func parser(
		_ parser: XMLParser, didEndElement elementName: String,
		namespaceURI: String?, qualifiedName qName: String?
	) {
		switch elementName {
		case "class", "informal_protocol", "method", "function", "arg", "retval":
			if !symbolStack.isEmpty {
				symbolStack.removeLast()
			}
		default:
			break
		}
	}

	private func bool(_ value: String?) -> Bool {
		return value == "true"
	}

	private func makeArgument(_ attributes: [String: String]) -> MOBridgeSupportArgument {
		let argument = MOBridgeSupportArgument()
		argument.cArrayLengthInArg = attributes["c_array_length_in_arg"]
		argument.isCArrayOfFixedLength = bool(attributes["c_array_of_fixed_length"])
		argument.isCArrayDelimitedByNull = bool(attributes["c_array_delimited_by_null"])
		argument.isCArrayOfVariableLength = bool(attributes["c_array_of_variable_length"])
		argument.isFunctionPointer = bool(attributes["function_pointer"])
		argument.signature = attributes["sel_of_type"]
		argument.signature64 = attributes["sel_of_type64"]
		argument.isCArrayLengthInReturnValue = bool(attributes["c_array_length_in_retval"])
		argument.acceptsNull = attributes["null_accepted"] != "false"
		argument.acceptsPrintfFormat = bool(attributes["printf_format"])
		argument.isAlreadyRetained = bool(attributes["already_retained"])
		argument.type = attributes["type"]
		argument.type64 = attributes["type64"]
		argument.index = UInt(attributes["index"] ?? "0") ?? 0
		return argument
	}

	private func attachArgument(_ argument: MOBridgeSupportArgument, asReturnValue: Bool) {
		guard let parent = symbolStack.last else {
			return
		}
		if let function = parent as? MOBridgeSupportFunction {
			if asReturnValue {
				function.returnValue = argument
			} else {
				function.addArgument(argument)
			}
		} else if let method = parent as? MOBridgeSupportMethod {
			if asReturnValue {
				method.returnValue = argument
			} else {
				method.addArgument(argument)
			}
		} else if let parentArgument = parent as? MOBridgeSupportArgument, asReturnValue {
			parentArgument.returnValue = argument
		} else if let parentArgument = parent as? MOBridgeSupportArgument {
			parentArgument.addArgument(argument)
		}
	}
}
