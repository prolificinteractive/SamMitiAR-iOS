//
//  UIColor+Extensions.swift
//  Kumi
//
//  Created by Htin Linn on 11/3/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

internal extension UIColor {

    /// Blend the receiver with specified color using given weight.
    ///
    /// - Parameters:
    ///   - blendColor: Color to blend with.
    ///   - weight: Proportional weight that should be given to blend color, specified as value from 0.0 to 1.0.
    /// - Returns: Blended color.
    func blend(with blendColor: UIColor, weight: CGFloat) -> UIColor {
        var rgbaValues = Array(repeating: CGFloat(0.0), count: 4)
        var blendRgbaValues = Array(repeating: CGFloat(0.0), count: 4)

        var red = rgbaValues[0]
        var green = rgbaValues[1]
        var blue = rgbaValues[2]
        var alpha = rgbaValues[3]

        var blendRed = blendRgbaValues[0]
        var blendGreen = blendRgbaValues[1]
        var blendBlue = blendRgbaValues[2]
        var blendAlpha = blendRgbaValues[3]

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        blendColor.getRed(&blendRed, green: &blendGreen, blue: &blendBlue, alpha: &blendAlpha)

        let invertWeight = 1 - weight

        return UIColor(
            red: (red * invertWeight + blendRed * weight) / 1,
            green: (green * invertWeight + blendGreen * weight) / 1,
            blue: (blue * invertWeight + blendBlue * weight) / 1,
            alpha: (alpha * invertWeight + blendAlpha * weight) / 1
        )
    }

    /// Darkens the reciever color by blending it with black color using given weight.
    ///
    /// - Parameter weight: Proportional weight that should be given to blend color, specified as value from 0.0 to 1.0.
    /// - Returns: Darkened color.
    func darken(by weight: CGFloat) -> UIColor {
        return blend(with: .black, weight: weight)
    }

    /// Brightens the receiver color by blending it with white color using given weight.
    ///
    /// - Parameter weight: Proportional weight that should be given to blend color, specified as value from 0.0 to 1.0.
    /// - Returns: Brightened color.
    func brighten(by weight: CGFloat) -> UIColor {
        return blend(with: .white, weight: weight)
    }

    /// Checks the underlying values of RGB of a color using the formula
    /// ((RedVal * 299) + (GreenVal * 587) + (BlueVal * 114)) / 1,000 to get the color brightness.
    ///
    /// - Returns: true if the value from above formula is greater than 155. false if it is lower than 155 or the color is invalid.
    func isLightColor() -> Bool {
        // Reference: https://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CGColor/
        guard let componentColors = cgColor.components else {
            return false
        }

        let count = cgColor.numberOfComponents
        var darknessScore: CGFloat = 0

        let maxByte = CGFloat(UInt8.max)

        if count == 2 {
            let darknessScore1 = (componentColors[0] * maxByte) * 299
            let darknessScore2 = (componentColors[0] * maxByte) * 587
            let darknessScore3 = (componentColors[0] * maxByte) * 114

            darknessScore = (darknessScore1 + darknessScore2 + darknessScore3) / CGFloat(1000.0)
        } else if count == 4 {
            let darknessScore1 = (componentColors[0] * maxByte) * 299
            let darknessScore2 = (componentColors[1] * maxByte) * 587
            let darknessScore3 = (componentColors[2] * maxByte) * 114

            darknessScore = (darknessScore1 + darknessScore2 + darknessScore3) / CGFloat(1000.0)
        }

        // Value of 155 is used to account for non-RGB colors such as whiteColor, grayColor, blackColor.
        // Traditional RGB color value would be 125.
        let middleDarknessScore: CGFloat = 155.0
        return darknessScore > middleDarknessScore
    }

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(netHex: Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }

}
