//
//  TextStyle+Extensions.swift
//  Marker
//
//  Created by Harlan Kellaway on 7/7/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS) || os(OSX)
    import AppKit
#endif

/// Adds factory functions producing new TextStyle from existing TextStyle.
public extension TextStyle {
    
    /// Creates new TextStyle from existing TextStyle, updating with provided values.
    ///
    /// - Parameters:
    ///   - newFont: New font.
    ///   - newEmFont: New emphasis font.
    ///   - newStrongFont: New strong font.
    ///   - newTextColor: New text color.
    ///   - newCharacterSpacing: New character spacing.
    ///   - newLineSpacing: New line spacing.
    ///   - newLineHeightMultiple: New line height multiple.
    ///   - newMinimumLineHeight: New minimum line height.
    ///   - newMaximumLineHeight: New maximum line height.
    ///   - newFirstLineHeadIndent: New first line head indent.
    ///   - newHeadIndent: New head indent.
    ///   - newParagraphSpacing: New paragraph spacing.
    ///   - newParagraphSpacingBefore: New paragraph spacing before.
    ///   - newTextAlignment: New text alignment.
    ///   - newLineBreakMode: New line break mode.
    ///   - newStrikethroughStyle: New strikethrough style.
    ///   - newStrikethroughColor: New strikethrough color.
    ///   - newUnderlineStyle: New underline style.
    ///   - newUnderlineColor: New underline color.
    ///   - newTextTransform: New text transform.
    /// - Returns: New Text Style with updated value(s).
    public func with(newFont: Font? = nil,
                     newEmFont: Font? = nil,
                     newStrongFont: Font? = nil,
                     newTextColor: Color? = nil,
                     newCharacterSpacing: CGFloat? = nil,
                     newLineSpacing: CGFloat? = nil,
                     newLineHeightMultiple: CGFloat? = nil,
                     newMinimumLineHeight: CGFloat? = nil,
                     newMaximumLineHeight: CGFloat? = nil,
                     newFirstLineHeadIndent: CGFloat? = nil,
                     newHeadIndent: CGFloat? = nil,
                     newParagraphSpacing: CGFloat? = nil,
                     newParagraphSpacingBefore: CGFloat? = nil,
                     newTextAlignment: NSTextAlignment? = nil,
                     newLineBreakMode: LineBreakMode? = nil,
                     newStrikethroughStyle: NSUnderlineStyle? = nil,
                     newStrikethroughColor: Color? = nil,
                     newUnderlineStyle: NSUnderlineStyle? = nil,
                     newUnderlineColor: Color? = nil,
                     newLinkFont: Font? = nil,
                     newLinkColor: Color? = nil,
                     newTextTransform: TextTransform? = nil) -> TextStyle {
        let fontToUse = newFont ?? font
        let emFontToUse = newEmFont ?? emFont
        let strongFontToUse = newStrongFont ?? strongFont
        let textColorToUse = newTextColor ?? textColor
        let characterSpacingToUse = newCharacterSpacing ?? characterSpacing
        let lineSpacingToUse = newLineSpacing ?? lineSpacing
        let lineHeightMultipleToUse = newLineHeightMultiple ?? lineHeightMultiple
        let minimumLineHeightToUse = newMinimumLineHeight ?? minimumLineHeight
        let maximumLineHeightToUse = newMaximumLineHeight ?? maximumLineHeight
        let firstLineHeadIndentToUse = newFirstLineHeadIndent ?? firstLineHeadIndent
        let headIndentToUse = newHeadIndent ?? headIndent
        let paragraphSpacingToUse = newParagraphSpacing ?? paragraphSpacing
        let paragraphSpacingBeforeToUse = newParagraphSpacingBefore ?? paragraphSpacingBefore
        let textAlignmentToUse = newTextAlignment ?? textAlignment
        let lineBreakModeToUse = newLineBreakMode ?? lineBreakMode
        let strikethroughStyleToUse = newStrikethroughStyle ?? strikethroughStyle
        let strikethroughColorToUse = newStrikethroughColor ?? strikethroughColor
        let underlineStyleToUse = newUnderlineStyle ?? underlineStyle
        let underlineColorToUse = newUnderlineColor ?? underlineColor
        let linkFontToUse = newLinkFont ?? linkFont
        let linkColorToUse = newLinkColor ?? linkColor
        let textTransformToUse = newTextTransform ?? textTransform
        
        return TextStyle(
            font: fontToUse,
            emFont: emFontToUse,
            strongFont: strongFontToUse,
            textColor: textColorToUse,
            characterSpacing: characterSpacingToUse,
            lineSpacing: lineSpacingToUse,
            lineHeightMultiple: lineHeightMultipleToUse,
            minimumLineHeight: minimumLineHeightToUse,
            maximumLineHeight: maximumLineHeightToUse,
            firstLineHeadIndent: firstLineHeadIndentToUse,
            headIndent: headIndentToUse,
            paragraphSpacing: paragraphSpacingToUse,
            paragraphSpacingBefore: paragraphSpacingBeforeToUse,
            textAlignment: textAlignmentToUse,
            lineBreakMode: lineBreakModeToUse,
            strikethroughStyle: strikethroughStyleToUse,
            strikethroughColor: strikethroughColorToUse,
            underlineStyle: underlineStyleToUse,
            underlineColor: underlineColorToUse,
            linkFont: linkFontToUse,
            linkColor: linkColorToUse,
            textTransform: textTransformToUse
        )
    }

    /// Creates new TextStyle from existing TextStyle, with strikethrough.
    ///
    /// - Parameters:
    ///   - color: Strikethrough color. Defaults to textColor.
    ///   - style: Strikethrough style. Defaults to single line.
    /// - Returns: New TextStyle with strikethrough.
    public func strikethrough(color: Color? = nil, style: NSUnderlineStyle = .styleSingle) -> TextStyle {
        return self.with(
            newStrikethroughStyle: style,
            newStrikethroughColor: color ?? textColor
        )
    }

    /// Creates new TextStyle from existing TextStyle, with underline.
    ///
    /// - Parameter color: Underline color. Defaults to textColor.
    /// - Parameter style: Underline style. Defaults to single line.
    /// - Returns: New TextStyle with underline.
    public func underlined(color: Color? = nil, style: NSUnderlineStyle = .styleSingle) -> TextStyle {
        return self.with(
            newUnderlineStyle: style,
            newUnderlineColor: color ?? textColor
        )
    }

}

// MARK: - Protocol conformance

// MARK: Equatable

extension TextStyle: Equatable { }

public func ==(lhs: TextStyle, rhs: TextStyle) -> Bool {
    guard lhs.font == rhs.font,
        lhs.emFont == rhs.emFont,
        lhs.strongFont == rhs.strongFont,
        lhs.textColor == rhs.textColor,
        lhs.characterSpacing == rhs.characterSpacing,
        lhs.lineSpacing == rhs.lineSpacing,
        lhs.lineHeightMultiple == rhs.lineHeightMultiple,
        lhs.minimumLineHeight == rhs.minimumLineHeight,
        lhs.maximumLineHeight == rhs.maximumLineHeight,
        lhs.firstLineHeadIndent == rhs.firstLineHeadIndent,
        lhs.headIndent == rhs.headIndent,
        lhs.paragraphSpacing == rhs.paragraphSpacing,
        lhs.paragraphSpacingBefore == rhs.paragraphSpacingBefore,
        lhs.textAlignment == rhs.textAlignment,
        lhs.lineBreakMode == rhs.lineBreakMode,
        lhs.strikethroughStyle == rhs.strikethroughStyle,
        lhs.strikethroughColor == rhs.strikethroughColor,
        lhs.underlineStyle == rhs.underlineStyle,
        lhs.underlineColor == rhs.underlineColor,
        lhs.linkFont == rhs.linkFont,
        lhs.linkColor == rhs.linkColor,
        lhs.textTransform == rhs.textTransform else {
        return false
    }
    
    return true
}
