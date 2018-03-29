//
//  Token.swift
//  Marker
//
//  Created by Htin Linn on 10/25/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// An entity that the token parser outputs that contains a `String` and a matching rule.
/// A token with an empty `rule` denotes subparts of the `String` that matches no rule.
struct Token {

    /// Content of the token.
    let string: String

    /// Matching rule.
    let rule: Rule?

    /// Content of the token with opening and closing symbols.
    var stringWithRuleSymbols: String {
        return (rule?.openingSymbol.rawValue ?? "") + string + (rule?.closingSymbol.rawValue ?? "")
    }

}
