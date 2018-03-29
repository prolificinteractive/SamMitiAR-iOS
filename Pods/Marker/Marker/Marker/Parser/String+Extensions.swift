//
//  String+Extensions.swift
//  Marker
//
//  Created by Htin Linn on 10/27/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// Shorthand for `String.Index` used in parsing.
typealias Index = String.Index

extension String {

    /// Appends the characters (without the rule symbols) from the given token and returns the range of appended `String`.
    ///
    /// - Parameter token: Token whose content should be appended.
    /// - Returns: Range of appended `String`.
    mutating func append(contentOf token: Token) -> Range<Index> {
        let startIndex = self.endIndex

        self += token.string
        let endIndex = self.endIndex

        return startIndex..<endIndex
    }

}
