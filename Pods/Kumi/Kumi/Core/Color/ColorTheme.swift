//
//  ColorTheme.Swift
//  Kumi
//
//  Created by Prolific Interactive on 3/14/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Kumi color theme.
public final class ColorTheme {

    /// Primary color.
    public var regularPrimary: ColorSet!

    /// Secondary color.
    public var regularSecondary: ColorSet!

    /// Tertiary color.
    public var regularTertiary: ColorSet!
    
    /// Invert Primary color.
    public var invertPrimary: ColorSet!

    /// Invert Secondary color.
    public var invertSecondary: ColorSet!

    /// Invert Tertiary color.
    public var invertTertiary: ColorSet!

    /// Emphasis Primary color.
    public var emphasisPrimary: ColorSet!

    /// Emphasis Secondary color.
    public var emphasisSecondary: ColorSet!

    /// Emphasis Tertiary color.
    public var emphasisTertiary: ColorSet!

    /// Invert Emphasis Primary color.
    public var invertEmphasisPrimary: ColorSet!

    /// Invert Emphasis Secondary color.
    public var invertEmphasisSecondary: ColorSet!

    /// Invert Emphasis Tertiary color.
    public var invertEmphasisTertiary: ColorSet!

    /// Grayout color.
    public var grayout: ColorSet!

    /// Destructive color.
    public var destructive: ColorSet!


    public init?(json: JSON) {
        regularPrimary = ColorSet(json: json["regularPrimary"])
        regularSecondary = ColorSet(json: json["regularSecondary"], defaultColor: regularPrimary.normal) ?? regularPrimary
        regularTertiary = ColorSet(json: json["regularTertiary"], defaultColor: regularSecondary.normal) ?? regularSecondary
        invertPrimary = ColorSet(json: json["invertPrimary"], defaultColor: regularPrimary.normal) ?? regularPrimary
        invertSecondary = ColorSet(json: json["invertSecondary"], defaultColor: invertPrimary.normal) ?? invertPrimary
        invertTertiary = ColorSet(json: json["invertTertiary"], defaultColor: invertSecondary.normal) ?? invertSecondary
        emphasisPrimary = ColorSet(json: json["emphasisPrimary"], defaultColor: regularPrimary.normal) ?? regularPrimary
        emphasisSecondary = ColorSet(json: json["emphasisSecondary"], defaultColor: emphasisPrimary.normal) ?? emphasisPrimary
        emphasisTertiary = ColorSet(json: json["emphasisTertiary"], defaultColor: emphasisSecondary.normal) ?? emphasisSecondary
        invertEmphasisPrimary = ColorSet(json: json["invertEmphasisPrimary"], defaultColor: regularPrimary.normal) ?? regularPrimary
        invertEmphasisSecondary = ColorSet(json: json["invertEmphasisSecondary"], defaultColor: invertEmphasisPrimary.normal) ?? invertEmphasisPrimary
        invertEmphasisTertiary = ColorSet(json: json["invertEmphasisTertiary"], defaultColor: invertEmphasisSecondary.normal) ?? invertEmphasisSecondary
        grayout = ColorSet(json: json["grayout"], defaultColor: regularPrimary.normal) ?? regularPrimary
        destructive = ColorSet(json: json["destructive"], defaultColor: regularPrimary.normal) ?? regularPrimary
    }

}
