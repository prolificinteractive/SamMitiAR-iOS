//
//  TextStyle.swift
//  Marker
//
//  Created by Htin Linn on 5/4/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS) || os(OSX)
    import AppKit
#endif

/// Encapsulates style information to be applied when displaying text.
public struct TextStyle {
    
    // MARK: - Properties

    /// Font for displaying regular text.
    public var font: Font
    
    /// Font for displaying emphasized text.
    public var emFont: Font
    
    /// Font for displaying important text.
    public var strongFont: Font
    
    /// Text color.
    public var textColor: Color?
    
    /// Character spacing/kerning.
    public var characterSpacing: CGFloat?

    /// Line spacing.
    public var lineSpacing: CGFloat?

    /// Line height multiple.
    public var lineHeightMultiple: CGFloat?
    
    /// Minimum line height.
    public var minimumLineHeight: CGFloat?
    
    /// Maximum line height.
    public var maximumLineHeight: CGFloat?
    
    /// Indentation of the first line of a paragraph.
    public var firstLineHeadIndent: CGFloat?
    
    /// Indentation of the lines of the paragraph other than the first line.
    public var headIndent: CGFloat?
    
    /// Paragraph spacing.
    public var paragraphSpacing: CGFloat?

    /// Paragraph spacing before.
    public var paragraphSpacingBefore: CGFloat?
    
    /// Text alignment.
    public var textAlignment: NSTextAlignment?
    
    /// Line break mode.
    public var lineBreakMode: LineBreakMode?
    
    /// Underline style for strikethrough text.
    public var strikethroughStyle: NSUnderlineStyle?
    
    /// Stroke color for strikethough text.
    public var strikethroughColor: Color?

    /// Underline style for underlined text.
    public var underlineStyle: NSUnderlineStyle?

    /// Stroke color for underlined text.
    public var underlineColor: Color?

    /// Font for displaying links.
    public var linkFont: Font?

    /// Text color for links.
    public var linkColor: Color?
    
    /// Text transform.
    public var textTransform: TextTransform
    
    // MARK: - Computed properties
    
    /// Text attribute dictionary representation of the receiver.
    /// NOTE: This variable does not include attributes that only apply to ranges such as `emFont`, `strikethroughStyle`, etc.
    public var attributes: TextAttributes {
        var attributes: TextAttributes = [:]
        

        attributes[AttributedStringKey.font] = font
        attributes[AttributedStringKey.foregroundColor] = textColor
        attributes[AttributedStringKey.kern] = characterSpacing as NSObject?
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        if let lineSpacing = lineSpacing {
            paragraphStyle.lineSpacing = lineSpacing
        }
        if let lineHeightMultiple = lineHeightMultiple {
            paragraphStyle.lineHeightMultiple = lineHeightMultiple
        }
        if let minimumLineHeight = minimumLineHeight {
            paragraphStyle.minimumLineHeight = minimumLineHeight
        }
        if let maximumLineHeight = maximumLineHeight {
            paragraphStyle.maximumLineHeight = maximumLineHeight
        }
        
        if let firstLineHeadIndent = firstLineHeadIndent {
            paragraphStyle.firstLineHeadIndent = firstLineHeadIndent
        }
        if let headIndent = headIndent {
            paragraphStyle.headIndent = headIndent
        }
        
        if let paragraphSpacing = paragraphSpacing {
            paragraphStyle.paragraphSpacing = paragraphSpacing
        }
        if let paragraphSpacingBefore = paragraphSpacingBefore {
            paragraphStyle.paragraphSpacingBefore = paragraphSpacingBefore
        }
        
        if let alignment = textAlignment {
            paragraphStyle.alignment = alignment
        }
        
        if let lineBreakMode = lineBreakMode {
            paragraphStyle.lineBreakMode = lineBreakMode
        }
        
        attributes[AttributedStringKey.paragraphStyle] = paragraphStyle
        
        return attributes
    }
    
    // MARK: - Init/Deinit

    /// Initializes and returns a text style object with given parameters.
    ///
    /// - Parameters:
    ///   - font: Regualar font.
    ///   - emFont: Emphasis font.
    ///   - strongFont: Strong font.
    ///   - textColor: Text color.
    ///   - characterSpacing: Character spacing (kerning).
    ///   - lineSpacing: Line spacing.
    ///   - lineHeightMultiple: Line height mulitple.
    ///   - minimumLineHeight: Minimum line height.
    ///   - maximumLineHeight: Maximum line height.
    ///   - firstLineHeadIndent: First line head indent.
    ///   - headIndent: Head indent.
    ///   - paragraphSpacing: Paragraph spacing.
    ///   - paragraphSpacingBefore: Paragraph spacing before.
    ///   - textAlignment: Text alignment.
    ///   - lineBreakMode: Line break mode.
    ///   - strikethroughStyle: Strikethrough style.
    ///   - strikethroughColor: Strikethrough color.
    ///   - underlineStyle: Underline style.
    ///   - underlineColor: Underline color.
    ///   - linkFont: Link style.
    ///   - linkColor: Link color.
    ///   - textTransform: Text transform option.
    public init(font: Font,
                emFont: Font? = nil,
                strongFont: Font? = nil,
                textColor: Color? = nil,
                characterSpacing: CGFloat? = nil,
                lineSpacing: CGFloat? = nil,
                lineHeightMultiple: CGFloat? = nil,
                minimumLineHeight: CGFloat? = nil,
                maximumLineHeight: CGFloat? = nil,
                firstLineHeadIndent: CGFloat? = nil,
                headIndent: CGFloat? = nil,
                paragraphSpacing: CGFloat? = nil,
                paragraphSpacingBefore: CGFloat? = nil,
                textAlignment: NSTextAlignment? = nil,
                lineBreakMode: LineBreakMode? = nil,
                strikethroughStyle: NSUnderlineStyle? = nil,
                strikethroughColor: Color? = nil,
                underlineStyle: NSUnderlineStyle? = nil,
                underlineColor: Color? = nil,
                linkFont: Font? = nil,
                linkColor: Color? = nil,
                textTransform: TextTransform = .none) {
        self.font = font
        self.emFont = (emFont == nil) ? font : emFont!
        self.strongFont = (strongFont == nil) ? font : strongFont!
        self.textColor = textColor
        self.characterSpacing = characterSpacing
        self.lineSpacing = lineSpacing
        self.firstLineHeadIndent = firstLineHeadIndent
        self.headIndent = headIndent
        self.lineHeightMultiple = lineHeightMultiple
        self.minimumLineHeight = minimumLineHeight
        self.maximumLineHeight = maximumLineHeight
        self.paragraphSpacing = paragraphSpacing
        self.paragraphSpacingBefore = paragraphSpacingBefore
        self.textAlignment = textAlignment
        self.lineBreakMode = lineBreakMode
        self.strikethroughStyle = strikethroughStyle
        self.strikethroughColor = strikethroughColor
        self.underlineStyle = underlineStyle
        self.underlineColor = underlineColor
        self.linkFont = linkFont
        self.linkColor = linkColor
        self.textTransform = textTransform
    }
}
