//
//  TDTrackException.swift
//  CocoaScript
//
//  Swift migration by Rui Aureliano, 2026.
//  Original source: TDParseKit, created by Todd Ditchendorf on 10/14/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

import Foundation

/// Signals that a parser could not match text after a specific point.
///
/// Original TDParseKit API preserved in Swift for incremental migration.
@objc(TDTrackException)
public final class TDTrackException: NSException {}
