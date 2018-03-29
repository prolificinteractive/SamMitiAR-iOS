//
//  TextAttributes.swift
//  Marker
//
//  Created by Htin Linn on 9/20/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS) || os(OSX)
    import AppKit
#endif

#if swift(>=4.0)
    /// Text attributes.
    public typealias TextAttributes = [NSAttributedStringKey: Any]

    struct AttributedStringKey {

        static let font = NSAttributedStringKey.font
        static let foregroundColor = NSAttributedStringKey.foregroundColor
        static let kern = NSAttributedStringKey.kern
        static let link = NSAttributedStringKey.link
        static let paragraphStyle = NSAttributedStringKey.paragraphStyle
        static let strikethroughStyle = NSAttributedStringKey.strikethroughStyle
        static let strikethroughColor = NSAttributedStringKey.strikethroughColor
        static let underlineStyle = NSAttributedStringKey.underlineStyle
        static let underlineColor = NSAttributedStringKey.underlineColor

    }
#else
    /// Text attributes.
    public typealias TextAttributes = [String: Any]

    internal struct AttributedStringKey {

        static let font = NSFontAttributeName
        static let foregroundColor = NSForegroundColorAttributeName
        static let kern = NSKernAttributeName
        static let link = NSLinkAttributeName
        static let paragraphStyle = NSParagraphStyleAttributeName
        static let strikethroughStyle = NSStrikethroughStyleAttributeName
        static let strikethroughColor = NSStrikethroughColorAttributeName
        static let underlineStyle = NSUnderlineStyleAttributeName
        static let underlineColor = NSUnderlineColorAttributeName
        
    }
#endif
