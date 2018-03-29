//
//  Rule.swift
//  Marker
//
//  Created by Htin Linn on 10/25/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// A parser "rule". Contains opening and closing symbols for matching.
struct Rule {

    /// A set of character(s) that an element starts with.
    let openingSymbol: Symbol

    /// A set of character(s) that an element ends with.
    let closingSymbol: Symbol

    /// Initializes a `Rule` with given symbols.
    ///
    /// - Parameters:
    ///   - openingSymbol: Opening symbol.
    ///   - closingSymbol: Closing symbol.
    init(openingSymbol: Symbol, closingSymbol: Symbol) {
        self.openingSymbol = openingSymbol
        self.closingSymbol = closingSymbol
    }

    /// Initialize a `Rule` with given symbol as both opening and ending symbols.
    ///
    /// - Parameter symbol: Symbol.
    init(symbol: Symbol) {
        self.init(openingSymbol: symbol, closingSymbol: symbol)
    }

}

// MARK: - Protocol conformance

// MARK: Equatable

extension Rule: Equatable {

    static func ==(lhs: Rule, rhs: Rule) -> Bool {
        return lhs.openingSymbol == rhs.openingSymbol && lhs.closingSymbol == rhs.closingSymbol
    }

}

// MARK: Hashable

extension Rule: Hashable {

    var hashValue: Int {
        return openingSymbol.hashValue ^ closingSymbol.hashValue
    }

}
