//
//  NSAttributedString+Extensions.swift
//  Marker
//
//  Created by Htin Linn on 1/26/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

extension NSAttributedString {
    
    /// Initializes `NSAttributedString` instance with given string and text style.
    ///
    /// - Parameters:
    ///   - string: The string for the new attributed string.
    ///   - textStyle: Style that should be applied to the string.
    convenience init(string: String, textStyle: TextStyle) {
        self.init(string: textStyle.textTransform.applied(to: string), attributes: textStyle.attributes)
    }
    
}
