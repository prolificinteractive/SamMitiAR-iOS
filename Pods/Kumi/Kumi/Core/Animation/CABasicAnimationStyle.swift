//
//  CABasicAnimationStyle.Swift
//  Kumi
//
//  Created by Prolific Interactive on 3/14/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import UIKit

/// Kumi CALayer animation style that encapsulates animation style information to be applied when animating CALayer.
public struct CABasicAnimationStyle {

    /// The basic animation duration.
    public let duration: TimeInterval

    /// The basic animation delay.
    public let delay: TimeInterval

    /// The basic animation timing function.
    public let timingFunction: CAMediaTimingFunction

    /// `true` if the animation is removed on completion. `false` if not.
    public let isRemovedOnCompletion: Bool

    /// Initializes the basic animation style.
    ///
    /// - Parameters:
    ///   - duration: The duration to use.
    ///   - delay: The delay to use.
    ///   - timingFunction: The timing function to use.
    ///   - isRemovedOnCompletion: Indicates if the system should remove the animation on completion.
    public init(duration: TimeInterval,
                delay: TimeInterval = 0,
                timingFunction: CAMediaTimingFunction,
                isRemovedOnCompletion: Bool = false) {
        self.duration = duration
        self.delay = delay
        self.timingFunction = timingFunction
        self.isRemovedOnCompletion = isRemovedOnCompletion

    }

}
