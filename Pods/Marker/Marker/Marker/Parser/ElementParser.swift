//
//  ElementParser.swift
//  Marker
//
//  Created by Htin Linn on 5/8/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// Bare bones parser that strips `string` for symbols defined in `rules`.
struct ElementParser {
        
    // MARK: - Static functions
    
    /// Parses specified string of symbols defined in `rules` and returns a tuple containing string stripped of matching characters and a list of matched elements.
    ///
    /// - Parameters:
    ///   - string: String to be parsed.
    ///   - rules: Rules with symbols to parse for.
    /// - Returns: Tuple containing string stripped of matching characters and a list of matched elements.
    /// - Throws: Parser error.
    static func parse(_ string: String, using rules: [Rule]) throws -> (strippedString: String, elements: [Element]) {
        let tokens = try TokenParser.parse(string, using: rules)

        guard tokens.count > 0 else {
            return (string, [])
        }

        var strippedString = ""
        var elements: [Element] = []

        for token in tokens {
            let range = strippedString.append(contentOf: token)
            
            if let rule = token.rule {
                elements.append(Element(rule: rule, range: range))
            }
        }

        return (strippedString, elements)
    }
    
}
