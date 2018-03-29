//
//  MarkdownParser.swift
//  Marker
//
//  Created by Htin Linn on 5/4/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

/// Markdown parser.
struct MarkdownParser {
    
    /// Parser error.
    ///
    /// - invalidTagSymbol: Tag symbol is not a Markdown symbol.
    enum ParserError: LocalizedError {
        case invalidTagSymbol

        var errorDescription: String? {
            return "Invalid Markdown tag."
        }
    }
    
    // MARK: - Private properties
    
    private static let underscoreEmSymbol = Symbol(character: "_")
    private static let asteriskEmSymbol = Symbol(character: "*")
    private static let underscoreStrongSymbol = Symbol(rawValue: "__")
    private static let asteriskStrongSymbol = Symbol(rawValue: "**")
    private static let tildeStrikethroughSymbol = Symbol(rawValue: "~~")
    private static let equalUnderlineSymbol = Symbol(rawValue: "==")
    private static let linkTextOpeningSymbol = Symbol(character: "[")
    private static let linkTextClosingSymbol = Symbol(character: "]")
    private static let linkURLOpeningSymbol = Symbol(character: "(")
    private static let linkURLClosingSymbol = Symbol(character: ")")
    
    // MARK: - Static functions
    
    /// Parses specified string and returns a tuple containing string stripped of symbols and an array of Markdown elements.
    ///
    /// - Parameter string: String to be parsed.
    /// - Returns: Tuple containing string stripped of tag characters and an array of Markdown elements.
    /// - Throws: Parser error.
    static func parse(_ string: String) throws -> (strippedString: String, elements: [MarkdownElement]) {
        guard
            let underscoreStrongSymbol = underscoreStrongSymbol,
            let asteriskStrongSymbol = asteriskStrongSymbol,
            let tildeStrikethroughSymbol = tildeStrikethroughSymbol,
            let equalUnderlineSymbol = equalUnderlineSymbol else {
                return (string, [])
        }

        let underscoreEmRule = Rule(symbol: underscoreEmSymbol)
        let asteriskEmRule = Rule(symbol: asteriskEmSymbol)
        let underscoreStrongRule = Rule(symbol: underscoreStrongSymbol)
        let asteriskStrongRule = Rule(symbol: asteriskStrongSymbol)
        let tildeStrikethroughRule = Rule(symbol: tildeStrikethroughSymbol)
        let equalUnderlineRule = Rule(symbol: equalUnderlineSymbol)
        let linkTextRule = Rule(openingSymbol: linkTextOpeningSymbol, closingSymbol: linkTextClosingSymbol)
        let linkURLRule = Rule(openingSymbol: linkURLOpeningSymbol, closingSymbol: linkURLClosingSymbol)

        let tokens = try TokenParser.parse(string,
                                           using: [underscoreEmRule,
                                                   asteriskEmRule,
                                                   underscoreStrongRule,
                                                   asteriskStrongRule,
                                                   tildeStrikethroughRule,
                                                   equalUnderlineRule,
                                                   linkTextRule,
                                                   linkURLRule])

        guard tokens.count > 0 else {
            return (string, [])
        }

        var strippedString = ""
        var elements: [MarkdownElement] = []

        var i = 0
        while i < tokens.count {
            let token = tokens[i]

            // For `em`, `strong`, and other single token rules,
            // it's just a matter of appending the content of matched token and storing the new range.
            // But, for links, look for the square brackets and make sure that it's followed by parentheses directly.
            // For everything else including parentheses by themseleves should be ignored.
            switch token.rule {
            case .some(underscoreEmRule), .some(asteriskEmRule):
                let range = strippedString.append(contentOf: token)
                elements.append(.em(range: range))
            case .some(underscoreStrongRule), .some(asteriskStrongRule):
                let range = strippedString.append(contentOf: token)
                elements.append(.strong(range: range))
            case .some(tildeStrikethroughRule):
                let range = strippedString.append(contentOf: token)
                elements.append(.strikethrough(range: range))
            case .some(equalUnderlineRule):
                let range = strippedString.append(contentOf: token)
                elements.append(.underline(range: range))
            case .some(linkTextRule):
                guard i + 1 < tokens.count, tokens[i + 1].rule == linkURLRule else {
                    fallthrough
                }

                let range = strippedString.append(contentOf: token)
                elements.append(.link(range: range,urlString: tokens[i + 1].string))

                i += 1
            default:
                strippedString += token.stringWithRuleSymbols
            }

            i += 1
        }

        return (strippedString, elements)
    }
    
}
