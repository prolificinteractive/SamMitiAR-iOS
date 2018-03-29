//
//  Symbol.swift
//  Marker
//
//  Created by Htin Linn on 4/28/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// A `Symbol` is a one or two character `String` used for marking up text.
struct Symbol: RawRepresentable, Equatable {
    
    typealias RawValue = String
    
    /// Underlying `String` representation.
    let rawValue: String
    
    /// Length of the symbol.
    var length: Int {
        return rawValue.count
    }

    // MARK: - Private properties

    private let symbolCharacterOne: Character?
    private let symbolCharacterTwo: Character?
    
    // MARK: - Init/deinit
    
    /// Creates a new instance with the specified raw value.
    ///
    /// If the character count of the `rawValue` isn't either one or zero, this intializer returns `nil`.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    /// - Returns: A new `Symbol` instance.
    init?(rawValue: String) {
        guard rawValue.count > 0 && rawValue.count <= 2 else {
            return nil
        }
        
        self.rawValue = rawValue
        symbolCharacterOne = rawValue.first
        symbolCharacterTwo = rawValue.count >= 2 ?
            rawValue[self.rawValue.index(after: self.rawValue.startIndex)] : nil
    }
    
    /// Creates a new instance with specified character.
    ///
    /// - Parameter character: `Character` to be used as `rawValue`.
    /// - Returns: A new `Symbol` instance.
    init(character: Character) {
        self.rawValue = String(character)
        symbolCharacterOne = character
        symbolCharacterTwo = nil
    }

    // MARK: - Instance functions

    /// Returns a boolean indicating whether the symbol matches given characters.
    /// This function currently requires three characters. 
    /// Preceding and succeeding characters are used to check if the matched character is surrounded by a space.
    /// Succeeding character is also used to matching two character symbols.
    ///
    /// - Parameters:
    ///   - precedingCharacter: Character preceding the character to match.
    ///   - character: Character to match.
    ///   - succeedingCharacter: Character succeeding the chracter to match.
    /// - Returns: Boolean indicating whether the symbol matches given characters.
    func matches(precedingCharacter: Character?, character: Character?, succeedingCharacter: Character?) -> Bool {
        guard let symbolCharacterOne = self.symbolCharacterOne else {
            return false
        }

        if length == 1 {
            switch (precedingCharacter, character, succeedingCharacter) {
            case (.some(" "), .some(symbolCharacterOne), .some(" ")):
                // If the symbol is only one character and is surrounded by empty spaces, treat it like a literal.
                break
            case (_, .some(symbolCharacterOne), _):
                return true
            default:
                break
            }
        } else if length == 2, let symbolCharacterTwo = self.symbolCharacterTwo {
            switch (precedingCharacter, character, succeedingCharacter) {
            case (_, .some(symbolCharacterOne), .some(symbolCharacterTwo)):
                return true
            default:
                break
            }
        }
        
        return false
    }
    
}

// MARK: - Protocol conformance

// MARK: - Hashable

extension Symbol: Hashable {

    var hashValue: Int {
        return rawValue.hashValue
    }

}
