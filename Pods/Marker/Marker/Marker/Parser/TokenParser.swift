//
//  TokenParser.swift
//  Marker
//
//  Created by Htin Linn on 10/25/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// Tokenizer that breaks down a given string into tokens based on prescribed rules.
struct TokenParser {

    /// Parser error.
    ///
    /// - unclosedTags: A tag was left unclosed.
    enum Error: LocalizedError {

        case unclosedTags

        var errorDescription: String? {
            switch self {
            case .unclosedTags:
                return "A tag was left unclosed."
            }
        }

    }

    /// Parses given string based on specified rules and returns a list of tokens that match the rules.
    ///
    /// - Parameters:
    ///   - string: String to be parsed.
    ///   - rules: Rules
    /// - Returns: Rules with symbols to parse for.
    /// - Throws: Parser error.
    static func parse(_ string: String, using rules: [Rule]) throws -> [Token] {
        let parser = TagParser(symbols: Set(rules.flatMap{ [$0.openingSymbol, $0.closingSymbol] }))
        let tags = parser.parse(string)

        guard tags.count > 0 else {
            return []
        }

        var tokens: [Token] = []
        var lastTokenEndIndex: Index = string.startIndex
        var currentTokenRule: Rule? = nil
        var currentTokenOpeningTag: Tag? = nil
        var tagsToEscape: [Tag] = []

        // Checks if there is currently open token that hasn't been closed yet.
        // i.e. if the opening and closing symbols are "(" and ")" respectively, only "(" has been matched.
        func hasNoCurrentOpenToken() -> Bool {
            return currentTokenRule == nil && currentTokenOpeningTag == nil
        }

        // Add a text token (token with no rule) based on the end index of the last token.
        func addTextTokenIfNeeded(_ index: Index) {
            guard index > lastTokenEndIndex else {
                return
            }

            tokens.append(Token(string: escapedString(from: lastTokenEndIndex, to: index), rule: nil))
        }

        // Create a string that's clear of escaped characters based on the "tagsToEscape" that has been accumulated.
        func escapedString(from startIndex: Index, to endIndex: Index) -> String {
            var escapedString = ""

            var fromIndex = startIndex
            for tag in tagsToEscape {
                // Skip the index right before the tag's index here and exclude the "\".
                escapedString += string[fromIndex..<string.index(before: tag.index)]
                // Prepare the start index for the next iteration.
                fromIndex = tag.index
            }

            escapedString += string[fromIndex..<endIndex]
            tagsToEscape = [] // Reset this for subsequent tags.

            return escapedString
        }

        for tag in tags {
            // Try to start matching a new token using the current tag.
            func openNewToken() {
                currentTokenRule = rules.filter({ tag.symbol == $0.openingSymbol }).first
                // If the tag's symbol doesn't match any of the opening symbols, don't start a new token.
                currentTokenOpeningTag = (currentTokenRule != nil) ? tag : nil
            }

            // Try closing the currently opened token.
            func closeCurrentToken() {
                let closingTag = tag

                guard
                    let openingTag = currentTokenOpeningTag,
                    let rule = currentTokenRule,
                    closingTag.symbol == rule.closingSymbol else {
                        return
                }

                // Add the text between symbol-matched tokens as a text token.
                addTextTokenIfNeeded(openingTag.index)

                let startIndex = string.index(openingTag.index, offsetBy: openingTag.symbol.length)
                let endIndex = closingTag.index
                tokens.append(Token(string: escapedString(from: startIndex, to: endIndex), rule: rule))

                // Close out the current token and reset.
                currentTokenRule = nil
                currentTokenOpeningTag = nil

                // Update this index so that we can use it for adding text tokens.
                lastTokenEndIndex = string.index(tag.index, offsetBy: tag.symbol.length)
            }

            // If a "\" is found before the tag, skip it for escaping.
            if tag.index > string.startIndex && string[string.index(before: tag.index)] == "\\" {
                tagsToEscape.append(tag)
                continue
            }

            if hasNoCurrentOpenToken() {
                openNewToken()
            } else {
                closeCurrentToken()
            }
        }

        guard hasNoCurrentOpenToken() else {
            throw Error.unclosedTags
        }

        // Add the text between the last token and end of the string as a text token.
        addTextTokenIfNeeded(string.endIndex)

        return tokens
    }

}

