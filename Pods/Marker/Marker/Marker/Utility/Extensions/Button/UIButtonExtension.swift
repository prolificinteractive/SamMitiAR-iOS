//
//  UIButtonExtension.swift
//  Marker
//
//  Created by Htin Linn on 11/14/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

public extension UIButton {
    
    /// Sets the button's title to an attributed string created from the specified string and text style.
    ///
    /// - Parameters:
    ///   - text: The text to be displayed in the label.
    ///   - textStyle: Text style object containing style information.
    ///   - markups: Custom markup if there is any. Defaults to zero custom markup.
    ///   - state: The button state to set.
    func setTitleText(_ text: String,
                      using textStyle: TextStyle,
                      customMarkup markups: Markup = [:],
                      forState state: UIControlState = .normal) {
        setAttributedTitle(attributedMarkupString(from: text, using: textStyle, customMarkup: markups), for: state)
    }
    
    /// Sets the button's title text to an attributed string created from the specified string and text style.
    /// This function treats the specified string as a Markdown formatted string and applies appropriate styling to it.
    /// Refer to MarkerdownParser.Tag for a list of supported Markdown tags.
    ///
    /// - Parameters:
    ///   - markdownText: The Markdown text to be displayed in the label.
    ///   - textStyle: Text style object containing style information.
    ///   - state: The button state to set.
    func setMarkdownTitleText(_ markdownText: String,
                              using textStyle: TextStyle,
                              forState state: UIControlState = .normal) {
        setAttributedTitle(attributedMarkdownString(from: markdownText, using: textStyle), for: state)
    }
    
}
