// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "CocoaScript",
	platforms: [
		.macOS(.v15)
	],
	products: [
		.library(
			name: "CocoaScript",
			targets: [
				"CocoaScript",
				"CocoaScriptParseKitSwift"
			]
		)
	],
	targets: [
		.target(
			name: "CocoaScriptParseKitSwift",
			dependencies: [],
			path: "Sources/ParseKit",
			sources: [
				"Core/Parser/TDAlternation.swift",
				"Core/Exceptions/TDTrackException.swift",
				"Core/Parser/TDEmpty.swift",
				"Core/Parser/TDParser.swift",
				"Core/Parser/TDCollectionParser.swift",
				"Core/Assembly/TDAssembly.swift",
				"Core/Assembly/TDCharacterAssembly.swift",
				"Core/Assembly/TDTokenAssembly.swift",
				"Core/Sequence/TDSequence.swift",
				"Core/Sequence/TDRepetition.swift",
				"Core/Sequence/TDTrack.swift",
				"Core/Reader/TDTokenArraySource.swift",
				"Core/Reader/TDReader.swift",
				"Tokens/Core/TDToken.swift",
				"Tokens/Core/TDTokenType.swift",
				"States/Tokenizer/TDTokenizerState.swift",
				"States/Tokenizer/TDTokenizer.swift",
				"States/Terminals/TDTerminal.swift",
				"Tokens/Characters/Basic/TDAny.swift",
				"Tokens/Characters/Basic/TDChar.swift",
				"Tokens/Characters/Basic/TDDigit.swift",
				"Tokens/Characters/Basic/TDLetter.swift",
				"Tokens/Characters/Basic/TDSpecificChar.swift",
				"Tokens/Core/TDNum.swift",
				"Tokens/Literals/TDLiteral.swift",
				"Tokens/Literals/TDCaseInsensitiveLiteral.swift",
				"Tokens/Literals/TDQuotedString.swift",
				"Tokens/Symbols/TDComment.swift",
				"Tokens/Symbols/TDSymbol.swift",
				"Tokens/Words/Basic/TDWord.swift",
				"Tokens/Words/Basic/TDLowercaseWord.swift",
				"Tokens/Words/Basic/TDUppercaseWord.swift",
				"Tokens/Words/Reserved/TDReservedWord.swift",
				"Tokens/Words/Reserved/TDNonReservedWord.swift",
				"States/Tokenizer/TDWhitespaceState.swift",
				"States/Terminals/TDQuoteState.swift",
				"States/Numbers/TDNumberState.swift",
				"States/Numbers/TDScientificNumberState.swift",
				"States/Comments/TDSingleLineCommentState.swift",
				"States/Comments/TDMultiLineCommentState.swift",
				"States/Comments/TDCommentState.swift",
				"States/Symbols/TDSymbolState.swift",
				"States/Symbols/TDSymbolNode.swift",
				"States/Symbols/TDSymbolRootNode.swift",
				"States/Words/TDWordState.swift",
				"States/Words/TDWordOrReservedState.swift"
			]
		),
		.target(
			name: "CocoaScript",
			dependencies: ["CocoaScriptParseKitSwift"],
			path: "Sources",
			exclude: ["ParseKit"],
			sources: [
				"Mocha/Pointer/MOPointer.swift",
				"Mocha/Pointer/MOPointerValue.swift",
				"Mocha/Collections/NSArray/NSArray+MochaAdditions.swift",
				"Mocha/Collections/NSDictionary/NSDictionary+MochaAdditions.swift",
				"Mocha/Collections/NSOrderedSet/NSOrderedSet+MochaAdditions.swift",
				"Mocha/Collections/NSObject/NSObject+MochaAdditions.swift",
				"Mocha/Utilities/MOAllocator.swift",
				"Mocha/Utilities/MOStruct.swift",
				"Mocha/Utilities/MOUtilities.swift",
				"Mocha/Runtime/Mocha.swift",
				"Mocha/Objects/Core/MOUndefined.swift",
				"Mocha/Objects/Core/MOBox.swift",
				"Mocha/Objects/Core/MOJavaScriptObject.swift",
				"Mocha/Objects/Closures/MOClosure.swift",
				"Mocha/Objects/Closures/MOFunctionArgument.swift",
				"Mocha/Reflection/Methods/MOMethod.swift",
				"Mocha/Reflection/Methods/MOMethodDescription.swift",
				"Mocha/Reflection/Classes/MOInstanceVariableDescription.swift",
				"Mocha/Reflection/Classes/MOClassDescription.swift",
				"Mocha/Reflection/Protocols/MOPropertyDescription.swift",
				"Mocha/Reflection/Protocols/MOProtocolDescription.swift",
				"Mocha/Reflection/Runtime/MOObjCRuntime.swift",
				"Mocha/BridgeSupport/Core/MOBridgeSupportSymbol.swift",
				"Mocha/BridgeSupport/Core/MOBridgeSupportLibrary.swift",
				"Mocha/BridgeSupport/Parser/MOBridgeSupportParser.swift",
				"Mocha/BridgeSupport/Core/MOBridgeSupportController.swift",
				"Runtime/Preprocessing/COSPreprocessor.swift",
				"Runtime/Fiber/COSFiber.swift",
				"Runtime/Fiber/COSInterval.swift",
				"Runtime/Fiber/COScriptFiber.swift",
				"Runtime/Fiber/COScriptInterval.swift",
				"Runtime/Script/COScript.swift",
				"Runtime/System/COSTarget.swift",
				"Runtime/System/COSExtras.swift",
				"Runtime/System/COSListener.swift"
			]
		)
	]
)
