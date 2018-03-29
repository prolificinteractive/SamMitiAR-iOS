//
//  TagParser.swift
//  Marker
//
//  Created by Htin Linn on 4/28/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// Type for parsing symbols.
struct TagParser {
    
    /// Symbols to parse.
    let symbols: [Symbol]
    
    // MARK: - Init/deinit
    
    /// Initializes parser with specified set of symbols.
    ///
    /// - Parameter symbols: Set of symbols.
    init(symbols: Set<Symbol>) {
        // It's important that longer character symbols come before shorter character symbols
        // because of the way that parser matches characters.
        self.symbols = symbols.sorted { (lhs, rhs) in
            return lhs.length > rhs.length
        }
    }
        
    // MARK: - Internal functions
    
    /// Parses and returns a list of tags containing the symbols in the receiver.
    ///
    /// - Parameter string: String to parse.
    /// - Returns: List of tags.
    func parse(_ string: String) -> [Tag] {
        var tags: [Tag] = []
        
        var i = 0
        var offset = 0
        var previousIndex = string.startIndex
        
        while i < string.count {
            let index = string.index(previousIndex, offsetBy: offset)

            let character: Character? = string[index]
            let precedingCharacter: Character? = (i > 0) ? string[string.index(before: index)] : nil
            let succeedingCharacter: Character? = (i + 1 < string.count) ?
                string[string.index(after: index)] : nil
            
            offset = 1
            for symbol in symbols {
                if symbol.matches(precedingCharacter: precedingCharacter,
                                  character: character,
                                  succeedingCharacter: succeedingCharacter) {
                    tags.append(Tag(symbol: symbol, index: index))
                    
                    offset = symbol.length
                    break
                }
            }
            
            i = i + offset
            previousIndex = index
        }
        
        return tags
    }
    
}
