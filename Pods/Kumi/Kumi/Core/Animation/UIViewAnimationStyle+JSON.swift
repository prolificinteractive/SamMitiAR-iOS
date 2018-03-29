//
//  UIViewAnimationStyle+JSON.swift
//  Kumi
//
//  Created by VIRAKRI JINANGKUL on 6/4/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//
import SwiftyJSON

extension UIViewAnimationStyle {

    public init?(json: JSON) {

        var duration: TimeInterval = 0.35
        var delay: TimeInterval = 0
        var dampingRatio: CGFloat = 1
        var velocity: CGFloat = 0

        if let durationValue = json["duration"].double {
            duration = durationValue
        }

        if let delayValue = json["delay"].double {
            delay = delayValue
        }

        if let dampingRatioValue = json["dampingRatio"].cgFloat {
            dampingRatio = dampingRatioValue
        }

        if let velocityValue = json["velocity"].cgFloat {
            velocity = velocityValue
        }

        self.init(duration: duration,
                  delay: delay,
                  dampingRatio: dampingRatio,
                  velocity: velocity)
    }

}
