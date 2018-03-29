//
//  SomethingLayer.swift
//  Prolific Design System
//
//  Created by Prolific Interactive on 3/17/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import UIKit

public extension CALayer {

    func setLayer(_ layerStyle: LayerStyle) {

        opacity = layerStyle.opacity

        cornerRadius = layerStyle.cornerRadius

        borderWidth = layerStyle.borderWidth

        borderColor = layerStyle.borderColor

        backgroundColor = layerStyle.backgroundColor

        if layerStyle.isRectangularShadow {
            shadowPath = CGPath(roundedRect: visibleRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        }

        shadowOpacity = layerStyle.shadowStyle.shadowOpacity

        shadowRadius = layerStyle.shadowStyle.shadowRadius

        shadowOffset.width = layerStyle.shadowStyle.shadowOffset.width

        shadowOffset.height = layerStyle.shadowStyle.shadowOffset.height

        if let layerStyleShadowColor = layerStyle.shadowColor {

            shadowColor = layerStyleShadowColor

        } else {

            shadowColor = layerStyle.shadowStyle.shadowColor

        }

        transform = layerStyle.transform

    }

    func setAnimatedLayer(_ layerStyle: LayerStyle,
                          using animationStyle: CABasicAnimationStyle,
                          completion: (() -> Swift.Void)? = nil) {

        let opacityAnimation            = createCABasicAnimation(keyPath: "opacity",
                                                                 fromValue: opacity,
                                                                 toValue: layerStyle.opacity)

        let cornerRadiusAnimation       = createCABasicAnimation(keyPath: "cornerRadius",
                                                                 fromValue: cornerRadius,
                                                                 toValue: layerStyle.cornerRadius)

        let borderWidthAnimation        = createCABasicAnimation(keyPath: "borderWidth",
                                                                 fromValue: borderWidth,
                                                                 toValue: layerStyle.borderWidth)

        let borderColorAnimation        = createCABasicAnimation(keyPath: "borderColor",
                                                                 fromValue: borderColor,
                                                                 toValue: layerStyle.borderColor)

        let backgroundColorAnimation    = createCABasicAnimation(keyPath: "backgroundColor",
                                                                 fromValue: backgroundColor,
                                                                 toValue: layerStyle.backgroundColor)

        var shadowPathAnimation         = CABasicAnimation()
        if layerStyle.isRectangularShadow {

            shadowPathAnimation         = createCABasicAnimation(keyPath: "shadowPath",
                                                                 fromValue: shadowPath,
                                                                 toValue: layerStyle.isRectangularShadow
                                                                    ? CGPath(roundedRect: visibleRect,
                                                                             cornerWidth: layerStyle.cornerRadius,
                                                                             cornerHeight: layerStyle.cornerRadius,
                                                                             transform: nil)
                                                                    : nil)
        }

        let shadowOpacityAnimation      = createCABasicAnimation(keyPath: "shadowOpacity",
                                                                 fromValue: shadowOpacity,
                                                                 toValue: layerStyle.shadowStyle.shadowOpacity)

        let shadowRadiusAnimation       = createCABasicAnimation(keyPath: "shadowRadius",
                                                                 fromValue: shadowRadius,
                                                                 toValue: layerStyle.shadowStyle.shadowRadius)

        let shadowOffsetWidthAnimation  = createCABasicAnimation(keyPath: "shadowOffset.width",
                                                                 fromValue: shadowOffset.width,
                                                                 toValue: layerStyle.shadowStyle.shadowOffset.width)

        let shadowOffsetHeightAnimation = createCABasicAnimation(keyPath: "shadowOffset.height",
                                                                 fromValue: shadowOffset.height,
                                                                 toValue: layerStyle.shadowStyle.shadowOffset.height)

        let shadowColorAnimation        = createCABasicAnimation(keyPath: "shadowColor",
                                                                 fromValue: shadowColor,
                                                                 toValue: layerStyle.shadowColor != nil ? layerStyle.shadowColor : layerStyle.shadowStyle.shadowColor)

        let transformAnimation          = createCABasicAnimation(keyPath: "transform",
                                                                 fromValue: transform,
                                                                 toValue: layerStyle.transform)

        let animationGroup = CAAnimationGroup()

        CATransaction.begin()

        CATransaction.setCompletionBlock(completion)

        animationGroup.duration = animationStyle.duration

        animationGroup.animations = [opacityAnimation,
                                     cornerRadiusAnimation,
                                     borderWidthAnimation,
                                     borderColorAnimation,
                                     backgroundColorAnimation,
                                     shadowPathAnimation,
                                     shadowOpacityAnimation,
                                     shadowRadiusAnimation,
                                     shadowOffsetWidthAnimation,
                                     shadowOffsetHeightAnimation,
                                     shadowColorAnimation,
                                     transformAnimation]

        animationGroup.beginTime = CACurrentMediaTime() + animationStyle.delay

        animationGroup.timingFunction = animationStyle.timingFunction

        animationGroup.isRemovedOnCompletion = animationStyle.isRemovedOnCompletion

        add(animationGroup, forKey: "layerAnimation")

        CATransaction.commit()

        setLayer(layerStyle)

    }

    func addColorOverlay(using color: UIColor, path: CGPath? = nil) {

        removeColorOverlay()

        let overlayLayer = CAShapeLayer()

        overlayLayer.name = "overlay"

        if let overlayPath = path {
            overlayLayer.path = overlayPath
        } else {
            overlayLayer.path = CGPath(rect: visibleRect, transform: nil)
        }

        overlayLayer.fillColor = color.cgColor

        overlayLayer.opacity = 1

        insertSublayer(overlayLayer, above: sublayers?.last)

    }

    func addAnimatedColorOverlay(using color: UIColor, path: CGPath? = nil, using animationStyle: CABasicAnimationStyle,
                                 completion: (() -> Swift.Void)? = nil) {

        removeColorOverlay()

        let overlayLayer = CAShapeLayer()

        overlayLayer.name = "overlay"

        if let overlayPath = path {
            overlayLayer.path = overlayPath
        } else {
            overlayLayer.path = CGPath(rect: visibleRect, transform: nil)
        }

        overlayLayer.fillColor = color.cgColor

        overlayLayer.opacity = 0

        insertSublayer(overlayLayer, above: sublayers?.last)

        setAnimatedColorOverlay(using: color, opacity: 1, path: path, using: animationStyle, completion: completion)

    }

    func setColorOverlay(using color: UIColor? = nil, opacity: Float, path: CGPath? = nil) {

        if let layers = sublayers {

            for layer in layers {

                if layer.name == "overlay" {

                    if let shapeLayer = layer as? CAShapeLayer {
                        let overlayColor = color != nil ? color! : UIColor(cgColor: shapeLayer.fillColor!)

                        shapeLayer.fillColor = overlayColor.cgColor

                        shapeLayer.opacity = opacity

                        shapeLayer.path = path != nil ? path : shapeLayer.path

                    }

                }

            }
        }

    }

    func setAnimatedColorOverlay(using color: UIColor? = nil,
                                 opacity: Float, path: CGPath? = nil,
                                 using animationStyle: CABasicAnimationStyle,
                                 completion: (() -> Swift.Void)? = nil) {

        if let layers = sublayers {

            for layer in layers {

                if layer.name == "overlay" {

                    if let shapeLayer = layer as? CAShapeLayer {

                        let overlayColor = color != nil ? color! : UIColor(cgColor: shapeLayer.fillColor!)
                        let overlayColorAnimation = createCABasicAnimation(keyPath: "fillColor",
                                                                           fromValue: shapeLayer.fillColor ,
                                                                           toValue: overlayColor.cgColor)

                        let overlayOpacityAnimation = createCABasicAnimation(keyPath: "opacity",
                                                                             fromValue: shapeLayer.opacity ,
                                                                             toValue:opacity)

                        let overlayPathAnimation = createCABasicAnimation(keyPath: "path",
                                                                          fromValue: shapeLayer.path,
                                                                          toValue: path != nil ? path : shapeLayer.path)

                        let animationGroup = CAAnimationGroup()

                        CATransaction.begin()

                        CATransaction.setCompletionBlock(completion)

                        animationGroup.duration = animationStyle.duration

                        animationGroup.animations = [overlayColorAnimation, overlayOpacityAnimation, overlayPathAnimation]

                        animationGroup.timingFunction = animationStyle.timingFunction

                        animationGroup.isRemovedOnCompletion = animationStyle.isRemovedOnCompletion

                        shapeLayer.add(animationGroup, forKey: "overlayLayerAnimation")

                        CATransaction.commit()

                        setColorOverlay(using: overlayColor, opacity: opacity, path: path)

                    }

                }

            }
        }

    }

    func removeColorOverlay() {

        if let layers = sublayers {

            for layer in layers {

                if layer.name == "overlay" {
                    layer.removeFromSuperlayer()
                }

            }

        }
    }

    func removeAnimatedColorOverlay(path: CGPath? = nil, using animationStyle: CABasicAnimationStyle,
                                    completion: (() -> Swift.Void)? = nil) {

        if let layers = sublayers {

            for layer in layers {

                if layer.name == "overlay" {

                    CATransaction.begin()

                    CATransaction.setCompletionBlock({
                        layer.removeFromSuperlayer()
                    })

                    setAnimatedColorOverlay(using: nil, opacity: 0, using: animationStyle, completion: completion)

                    CATransaction.commit()

                }

            }

        }

    }

    private func createCABasicAnimation(keyPath: String,
                                        fromValue: Any?,
                                        toValue: Any?,
                                        isRemovedOnCompletion: Bool = false) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.isRemovedOnCompletion = isRemovedOnCompletion

        return animation

    }

}
