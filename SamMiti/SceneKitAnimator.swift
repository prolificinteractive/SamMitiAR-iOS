//
//  SceneKitAnimator.swift
//  Face-based Game Prototype
//
//  Created by VIRAKRI JINANGKUL on 10/27/17.
//  Copyright © 2017 VIRAKRI JINANGKUL. All rights reserved.
//

import SceneKit
import UIKit

public extension CAMediaTimingFunction {

    static let linear = CAMediaTimingFunction(controlPoints: 0, 0, 1, 1)

    static let easeIn = CAMediaTimingFunction(controlPoints: 0.9, 0, 0.9, 1)

    static let easeOut = CAMediaTimingFunction(controlPoints: 0.1, 0, 0.1, 1)

    static let easeInOut = CAMediaTimingFunction(controlPoints: 0.45, 0, 0.55, 1)
    
    static let easeInEaseOut = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

    static let explodingEaseOut = CAMediaTimingFunction(controlPoints: 0, 0, 0, 1)

    static let `default` = CAMediaTimingFunction(controlPoints: 0, 0, 0.2, 1)

}

public class SceneKitAnimator {

    var completed: (() -> Void)?

    @discardableResult
    public class func animateWithDuration(duration: TimeInterval,
                                        timingFunction: CAMediaTimingFunction = .default,
                                        animated: Bool = true,
                                        animations: (() -> Void),
                                        completion: (() -> Void)? = nil) -> SceneKitAnimator{
        let promise = SceneKitAnimator()
        SCNTransaction.begin()
        SCNTransaction.completionBlock = {
            completion?()
            promise.completed?()
        }
        SCNTransaction.animationTimingFunction = timingFunction
        SCNTransaction.animationDuration = duration
        animations()
        SCNTransaction.commit()
        return promise
    }

    @discardableResult
    public func thenAnimateWithDuration(duration: TimeInterval,
                                    timingFunction: CAMediaTimingFunction = .default,
                                    animated: Bool = true,
                                    animations: @escaping (() -> Void),
                                    completion: (() -> Void)? = nil) -> SceneKitAnimator {
        let animator = SceneKitAnimator()
        completed = {
            SceneKitAnimator.animateWithDuration(duration: duration,
                                                 timingFunction: timingFunction,
                                                 animated: animated,
                                                 animations: animations,
                                                 completion: {
                                                    completion?()
                                                    animator.completed?()
            })
        }
        return animator
    }

}
