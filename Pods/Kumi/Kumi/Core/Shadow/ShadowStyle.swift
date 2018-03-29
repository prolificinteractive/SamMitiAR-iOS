//
//  ShadowStyle.Swift
//  Kumi
//
//  Created by Prolific Interactive on 3/14/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// Encapsulates style information to be applied when displaying or animating CALayer's shadow.
public struct ShadowStyle {

    /// Font for displaying regular text.
    public var shadowOpacity: Float

    /// Font for displaying regular text.
    public var shadowRadius: CGFloat

    /// Font for displaying regular text.
    public var shadowOffset: CGSize

    /// Font for displaying regular text.
    public var shadowColor: CGColor?

    /// Initializes the shadow style.
    ///
    /// - Parameters:
    ///   - shadowOpacity: The opacity to use.
    ///   - shadowRadius: The radius to use.
    ///   - shadowOffset: The offset to use.
    ///   - shadowColor: The color to use.
    public init(shadowOpacity: Float = 1.0,
                shadowRadius: CGFloat,
                shadowOffset: CGSize,
                shadowColor: CGColor? = nil) {
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.shadowColor = shadowColor
    }

}
