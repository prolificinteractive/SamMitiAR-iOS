//
//  LayerStyle.swift
//  Kumi
//
//  Created by Prolific Interactive on 3/14/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// Kumi layer style to encapsulate style information to be applied when displaying or animating CALayer.
public struct LayerStyle {

    // MARK: - Properties

    /// The opacity of the layer. Animatable.
    public var opacity: Float

    /// A Boolean indicating whether sublayers are clipped to the layer’s bounds. Animatable.
    public var masksToBounds: Bool

    /// An optional layer whose alpha channel is used to mask the layer’s content.
    public var mask: CALayer?

    /// A Boolean indicating whether the layer displays its content when facing away from the viewer. Animatable.
    public var isDoubleSided: Bool

    /// The corner radius of the layer’s background. Animatable.
    public var cornerRadius: CGFloat

    /// The width of the layer’s border. Animatable.
    public var borderWidth: CGFloat

    /// The color of the layer’s border. Animatable.
    public var borderColor: CGColor?

    /// The background color of the receiver. Animatable.
    public var backgroundColor: CGColor?

    /// The shape of the layer’s shadow. Animatable.
    public var shadowPath: CGPath?

    /// The shadow style indicating how the layer’s shadow looks like. Animatable.
    public var shadowStyle: ShadowStyle

    /// The color of the layer’s shadow. Animatable.
    public var shadowColor: CGColor?

    /// The transform applied to the layer’s contents. Animatable.
    public var transform: CATransform3D

    /// NOTE: this value indicating if the layer need live shadow-casting or the shadow will only be ractangle
    public var isRectangularShadow: Bool

    // MARK: - Init/Deinit

    /**
     Initializes a text style object with given parameters.

     - parameter opacity:               The opacity of the layer. Animatable.
     - parameter masksToBounds:         A Boolean indicating whether sublayers are clipped to the layer’s bounds. Animatable.
     - parameter mask:                  An optional layer whose alpha channel is used to mask the layer’s content.
     - parameter isDoubleSided:         A Boolean indicating whether the layer displays its content when facing away from the viewer. Animatable.
     - parameter cornerRadius:          The corner radius of the layer. Animatable.
     - parameter borderWidth:           The width of the layer’s border. Animatable.
     - parameter borderColor:           The color of the layer’s border. Animatable.
     - parameter backgroundColor:       The background color. Animatable.
     - parameter shadowPath:            The shape of the layer’s shadow. Animatable.
     - parameter shadowStyle:           The shadow style indicating how the layer’s shadow looks like. Animatable.
     - parameter shadowColor:           The color of the layer’s shadow. Animatable.
     - parameter transform:             The transform applied to the layer’s contents. Animatable.
     - parameter isRectangularShadow:   A Boolean indicating if the layer's shadow will only be ractangle.

     - returns: An initialized layer style object.
     */
    public init(opacity: Float              = 1,
                masksToBounds: Bool         = false,
                mask: CALayer?              = nil,
                isDoubleSided: Bool         = true,
                cornerRadius: CGFloat       = 0,
                borderWidth: CGFloat        = 0,
                borderColor: CGColor?       = nil,
                backgroundColor: CGColor?   = nil,
                shadowPath: CGPath?         = nil,
                shadowStyle: ShadowStyle?   = nil,
                shadowColor: CGColor?       = nil,
                transform: CATransform3D    = CATransform3DIdentity,
                isRectangularShadow: Bool         = false) {

        self.opacity            = opacity
        self.masksToBounds      = masksToBounds
        self.mask               = mask
        self.isDoubleSided      = isDoubleSided
        self.cornerRadius       = cornerRadius
        self.borderWidth        = borderWidth
        self.borderColor        = borderColor
        self.backgroundColor    = backgroundColor
        self.shadowPath         = shadowPath
        if let layerShadowStyle = shadowStyle {

            self.shadowStyle    = layerShadowStyle

        } else {

            self.shadowStyle    = ShadowStyle(shadowOpacity: 0,
                                              shadowRadius: 0,
                                              shadowOffset: CGSize(width: 0,
                                                                   height: 0),
                                              shadowColor: UIColor.clear.cgColor)

        }

        self.shadowColor        = shadowColor
        self.transform          = transform
        self.isRectangularShadow      = isRectangularShadow

    }

    // MARK: - Modifier Functions

    // Returns a layer style in the same style as the receiver with the specified corner radius.
    public func withCornerRadius(_ cornerRadius: CGFloat) -> LayerStyle {
        var layerStyle = self
        layerStyle.cornerRadius = cornerRadius
        return layerStyle
    }

    // Returns a layer style in the same style as the receiver with the specified border witdth.
    public func withMasksToBounds(_ masksToBounds: Bool) -> LayerStyle {
        var layerStyle = self
        layerStyle.masksToBounds = masksToBounds
        return layerStyle
    }

    // Returns a layer style in the same style as the receiver with the specified border witdth.
    public func withMask(_ mask: CALayer) -> LayerStyle {
        var layerStyle = self
        layerStyle.mask = mask
        return layerStyle
    }

    // Returns a layer style in the same style as the receiver with the specified boolean indicating isDoubleSided value .
    public func withDoubleSided(_ isDoubleSided: Bool) -> LayerStyle {
        var layerStyle = self
        layerStyle.isDoubleSided = isDoubleSided
        return layerStyle
    }

    // Returns a layer style in the same style as the receiver with the specified border width.
    public func withBorderWidth(_ borderWidth: CGFloat) -> LayerStyle {
        var layerStyle = self
        layerStyle.borderWidth = borderWidth
        return layerStyle
    }

    // Returns a layer style in the same style as the receiver with the specified border color.
    public func withBorderColor(_ borderColor: CGColor) -> LayerStyle {
        var layerStyle = self
        layerStyle.borderColor = borderColor
        return layerStyle
    }

    public func withBackgroundColor(_ color: CGColor) -> LayerStyle {
        var layerStyle = self
        layerStyle.backgroundColor = color
        return layerStyle
    }

    public func withBackgroundColorAlphaComponent(_ alphaComponent: CGFloat) -> LayerStyle {
        var layerStyle = self
        if let backgroundColor = layerStyle.backgroundColor {
            layerStyle.backgroundColor = UIColor(cgColor: backgroundColor).withAlphaComponent(alphaComponent).cgColor

        }
        return layerStyle

    }

    public func withShadowPath(_ shadowPath: CGPath) -> LayerStyle {
        var layerStyle = self
        layerStyle.shadowPath = shadowPath
        return layerStyle
    }

    public func withShadowStyle(_ shadowStyle: ShadowStyle) -> LayerStyle {
        var layerStyle = self
        layerStyle.shadowStyle = shadowStyle
        return layerStyle
    }

    public func withShadowColor(_ shadowColor: CGColor) -> LayerStyle {
        var layerStyle = self
        layerStyle.shadowColor = shadowColor
        return layerStyle
    }

    public func withTransform(_ transform: CATransform3D) -> LayerStyle {
        var layerStyle = self
        layerStyle.transform = transform
        return layerStyle
    }

    public func withRectangularShadow(_ isRectangularShadow: Bool) -> LayerStyle {
        var layerStyle = self
        layerStyle.isRectangularShadow = isRectangularShadow
        return layerStyle
    }

}
