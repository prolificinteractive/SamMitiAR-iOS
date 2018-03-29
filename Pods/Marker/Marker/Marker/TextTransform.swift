//
//  TextTransform.swift
//  Marker
//
//  Created by Htin Linn on 1/26/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// Text transform options that can be applied to a string.
///
/// - none: No transformation.
/// - lowercased: Transform given string into lowercased string.
/// - uppercased: Transform given string into uppercased string.
/// - capitalized: Transform given string into capitalized string.
/// - custom: Transform given string using custom transform function.
public enum TextTransform {
    
    case none
    case lowercased
    case uppercased
    case capitalized
    case custom((String) -> String)
    
    /// Returns argument string with transformation applied
    ///
    /// - Parameter string: String to be transformed.
    /// - Returns: Transformed string.
    func applied(to string: String) -> String {
        switch self {
        case .none:
            return string
        case .lowercased:
            return string.lowercased()
        case .uppercased:
            return string.uppercased()
        case .capitalized:
            return string.capitalized
        case .custom(let transform):
            return transform(string)
        }
    }
    
}
