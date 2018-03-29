//
//  Element.swift
//  Marker
//
//  Created by Htin Linn on 5/8/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// Markup element. Contains a symbol and the range it applies to.
struct Element {
    
    /// Markup rule.
    let rule: Rule
    
    /// Range that the receiver applies to.
    let range: Range<Index>
    
}
