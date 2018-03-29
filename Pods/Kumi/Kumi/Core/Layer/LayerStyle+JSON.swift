//
//  LayerStyle+JSON.swift
//  Kumi
//
//  Created by VIRAKRI JINANGKUL on 6/3/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation
import SwiftyJSON

extension LayerStyle {

    public init?(json: JSON) {
        var opacity: Float = 1
        var masksToBounds: Bool = false
        var isDoubleSided: Bool = true
        var cornerRadius: CGFloat = 0
        var borderWidth: CGFloat = 0
        var borderColor: CGColor?
        var backgroundColor: CGColor?
        var shadowStyle: ShadowStyle?
        var shadowColor: CGColor?
        var transform: CATransform3D = CATransform3DIdentity

        if let opacityValue = json["opacity"].double {
            opacity = Float(opacityValue)
        }

        if let masksToBoundsValue = json["masksToBounds"].bool {
            masksToBounds = masksToBoundsValue
        }

        if let isDoubleSidedValue = json["isDoubleSided"].bool {
            isDoubleSided = isDoubleSidedValue
        }

        if let cornerRadiusValue = json["cornerRadius"].cgFloat {
            cornerRadius = cornerRadiusValue
        }

        if let borderWidthValue = json["borderWidth"].cgFloat {
            borderWidth = borderWidthValue
        }

        
        borderColor = UIColor(json: json["borderColor"])?.cgColor
        

        backgroundColor = UIColor(json: json["backgroundColor"])?.cgColor
        

        shadowStyle = ShadowStyle(json: json["shadowStyle"])
        
        
        shadowColor = UIColor(json: json["shadowColor"])?.cgColor
        

        if let transformValue = CATransform3D(json: json["transform"]) {
            transform = transformValue
        }
    

        self.init(opacity: opacity,
                  masksToBounds: masksToBounds,
                  isDoubleSided: isDoubleSided,
                  cornerRadius: cornerRadius,
                  borderWidth: borderWidth,
                  borderColor: borderColor,
                  backgroundColor: backgroundColor,
                  shadowStyle: shadowStyle,
                  shadowColor: shadowColor,
                  transform: transform)
    }
}
