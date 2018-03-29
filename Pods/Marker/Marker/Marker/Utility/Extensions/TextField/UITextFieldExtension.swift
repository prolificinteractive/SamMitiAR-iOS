//
//  UITextFieldExtension.swift
//  Marker
//
//  Created by Htin Linn on 5/4/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

public extension UITextField {

    /// Sets the text field text to an attributed string created from the specified string and text style.
    ///
    /// - Parameters:
    ///   - text: The text to be displayed in the text field.
    ///   - textStyle: Text style object containing style information.
    ///   - markups: Custom markup if there is any. Defaults to zero custom markup.
    func setText(_ text: String, using textStyle: TextStyle, customMarkup markups: Markup = [:]) {
        attributedText = attributedMarkupString(from: text, using: textStyle, customMarkup: markups)
    }

    /// Sets the text field text to an attributed string created from the specified string and text style.
    /// This function treats the specified string as a Markdown formatted string and applies appropriate styling to it.
    /// Refer to MarkerdownElement for a list of supported Markdown tags.
    ///
    /// - Parameters:
    ///   - markdownText: The Markdown text to be displayed in the text field.
    ///   - textStyle: Text style object containing style information.
    func setMarkdownText(_ markdownText: String, using textStyle: TextStyle) {
        attributedText = attributedMarkdownString(from: markdownText, using: textStyle)
    }

}
