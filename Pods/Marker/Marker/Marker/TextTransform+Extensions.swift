//
//  TextTransform+Extensions.swift
//  Marker
//
//  Created by Harlan Kellaway on 7/7/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

// MARK: - Protocol conformance

// MARK: Equatable

extension TextTransform: Equatable { }

/// Returns a Boolean value indicating whether two TextTransform are equal.
/// NOTE: This function always returns false if one of the transforms are `custom` 
/// since there is no good way to compare the associated functions.
///
/// - Parameters:
///   - lhs: A TextTransform to compare.
///   - rhs: Another TextTransform to compare.
/// - Returns: true if the two transforms are equal. false otherwise.
public func ==(lhs: TextTransform, rhs: TextTransform) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none):
        return true
    case (.lowercased, .lowercased):
        return true
    case (.uppercased, .uppercased):
        return true
    case (.capitalized, .capitalized):
        return true
    default:
        return false
    }
}
