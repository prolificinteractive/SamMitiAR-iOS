//
//  Tag.swift
//  Marker
//
//  Created by Htin Linn on 4/28/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// A tag represents a parser result containing a symbol and the index location of the symbol.
struct Tag {
    
    /// Symbol.
    let symbol: Symbol
    
    /// Index where symbol was found.
    let index: Index
    
}
