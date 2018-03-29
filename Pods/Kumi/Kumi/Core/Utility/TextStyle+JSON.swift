//
//  TextStyle+JSON.swift
//  Kumi
//
//  Created by Thibault Klein on 4/28/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation
import Marker
import SwiftyJSON

private extension TextTransform {

    init(string: String) {
        switch string {
        case "none":
            self = .none
        case "lowercased":
            self = .lowercased
        case "uppercased":
            self = .uppercased
        case "capitalized":
            self = .capitalized
        default:
            self = .none
        }
    }

}

private extension NSTextAlignment {

    static func fromString(string: String) -> NSTextAlignment? {
        switch string {
        case "left":
            return NSTextAlignment.left
        case "center":
            return NSTextAlignment.center
        case "right":
            return NSTextAlignment.right
        default:
            return nil
        }
    }

}

private extension NSLineBreakMode {

    static func fromString(string: String) -> NSLineBreakMode? {
        switch string {
        case "byWordWrapping":
            return NSLineBreakMode.byWordWrapping
        case "byCharWrapping":
            return NSLineBreakMode.byCharWrapping
        case "byClipping":
            return NSLineBreakMode.byClipping
        case "byTruncatingHead":
            return NSLineBreakMode.byTruncatingHead
        case "​​byTruncatingTail":
            return NSLineBreakMode.byTruncatingTail
        case "byTruncatingMiddle":
            return NSLineBreakMode.byTruncatingMiddle
        default:
            return nil
        }
    }
}

private extension NSUnderlineStyle {

    static func fromString(string: String) -> NSUnderlineStyle? {
        switch string {
        case "none":
            return NSUnderlineStyle.styleNone
        case "single":
            return NSUnderlineStyle.styleSingle
        case "thick":
            return NSUnderlineStyle.styleThick
        case "double":
            return NSUnderlineStyle.styleDouble
        case "patternSolid":
            return NSUnderlineStyle.patternSolid
        case "patternDot":
            return NSUnderlineStyle.patternDot
        case "patternDash":
            return NSUnderlineStyle.patternDash
        case "patternDashDot":
            return NSUnderlineStyle.patternDashDot
        case "patternDashDotDot":
            return NSUnderlineStyle.patternDashDotDot
        case "byWord":
            return NSUnderlineStyle.byWord
        default:
            return nil
        }
    }
}

extension TextStyleSet {
    
    init?(json: JSON) {
        guard let normal = TextStyle(json: json["regular"]) else {
            return nil
        }
        self.init(normal: normal,
                  strong: TextStyle(json: json["strong"]),
                  emphasis: TextStyle(json: json["emphasis"]))
    }
    
    init(json: JSON, defaultStyle: TextStyle) {
        self.init(normal: TextStyle(json: json["regular"]) ?? defaultStyle,
                  strong: TextStyle(json: json["strong"]),
                  emphasis: TextStyle(json: json["emphasis"]))
    }
    
}

extension TextStyle {

    init?(json: JSON) {
        
        guard let fontNameJSON = json["font"].string else {
            return nil
        }
        let textSize = json["textSize"].cgFloat ?? 14

        var font = Font(name: fontNameJSON, size: textSize)
        if font == nil {
            print("WARNING Missing font : \(fontNameJSON)")
            font = Font.systemFont(ofSize: textSize)
        }
        
        let emFont = font
        let strongFont = font
        var textColor: UIColor?
        var characterSpacing: CGFloat?
        var lineSpacing: CGFloat?
        var lineHeightMultiple: CGFloat?
        var minimumLineHeight: CGFloat?
        var maximumLineHeight: CGFloat?
        var paragraphSpacing: CGFloat?
        var paragraphSpacingBefore: CGFloat?
        var textAlignment: NSTextAlignment?
        var lineBreakMode: NSLineBreakMode?
        var strikethroughStyle: NSUnderlineStyle?
        var strikethroughColor: UIColor?
        var textTransform: TextTransform = .none


        
        textColor = UIColor(json: json["color"])
        
        characterSpacing = json["letterSpacing"].cgFloat
        
        lineSpacing = json["lineSpacing"].cgFloat

        lineHeightMultiple = json["lineHeightMultiple"].cgFloat

        minimumLineHeight = json["minimumLineHeight"].cgFloat
        
        maximumLineHeight = json["maximumLineHeight"].cgFloat

        paragraphSpacing = json["paragraphSpacing"].cgFloat
        
        paragraphSpacingBefore = json["paragraphSpacingBefore"].cgFloat
        
        if let textAlignmentString = json["textAlign"].string {
            textAlignment = NSTextAlignment.fromString(string: textAlignmentString)
        }

        if let lineBreakModeString = json["lineBreakMode"].string {
            lineBreakMode = NSLineBreakMode.fromString(string: lineBreakModeString)
        }

        if let strikethroughStyleString = json["strikethroughStyle"].string {
            strikethroughStyle = NSUnderlineStyle.fromString(string: strikethroughStyleString)
        }

        if let transform = json["textTransform"].string {
            textTransform = TextTransform(string: transform)
        }

        strikethroughColor = UIColor(json: json["textDecorationColor"] )
        
        self.init(font: font!,
                  emFont: emFont,
                  strongFont: strongFont,
                  textColor: textColor,
                  characterSpacing: characterSpacing,
                  lineSpacing: lineSpacing,
                  lineHeightMultiple: lineHeightMultiple,
                  minimumLineHeight: minimumLineHeight,
                  maximumLineHeight: maximumLineHeight,
                  paragraphSpacing: paragraphSpacing,
                  paragraphSpacingBefore: paragraphSpacingBefore,
                  textAlignment: textAlignment,
                  lineBreakMode: lineBreakMode,
                  strikethroughStyle: strikethroughStyle,
                  strikethroughColor: strikethroughColor,
                  textTransform: textTransform)
    }

}
