//
//  COSListener.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: jstalk, created by August Mueller on 1/14/09.
//  Copyright 2009 Flying Meat Inc. All rights reserved.
//

import Foundation

public final class COSListener: NSObject {

	public weak var rootObject: AnyObject?

	nonisolated(unsafe) public static let sharedListener = COSListener()

	public class func listen() {
		sharedListener.startListening()
	}

	public class func listen(withRootObject rootObject: AnyObject) {
		sharedListener.rootObject = rootObject
		listen()
	}

	private func startListening() {
		return
	}
}
