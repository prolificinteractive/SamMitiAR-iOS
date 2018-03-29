//
//  UIViewAnimationStyle.Swift
//  Kumi
//
//  Created by Prolific Interactive on 3/14/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import UIKit

/// Kumi UIView animation style that encapsulates animation style information to be applied when animating UIView.
public struct UIViewAnimationStyle {

    /// The view animation duration.
    public let duration: TimeInterval

    /// The view animation delay.
    public let delay: TimeInterval

    /// The view animation damping ratio.
    public let dampingRatio: CGFloat

    /// The view animation velocity.
    public let velocity: CGFloat

    /// The view animation options.
    public let options: UIViewAnimationOptions

    /// Initializes the view animation style.
    ///
    /// - Parameters:
    ///   - duration: The duration to use.
    ///   - delay: The delay to use.
    ///   - dampingRatio: The damping ratio to use.
    ///   - velocity: The velocity to use.
    ///   - options: The options to use.
    public init(duration: TimeInterval,
                delay: TimeInterval = 0,
                dampingRatio: CGFloat = 1,
                velocity: CGFloat = 0,
                options: UIViewAnimationOptions = [.allowUserInteraction]) {
        self.duration = duration
        self.delay = delay
        self.dampingRatio = dampingRatio
        self.velocity = velocity
        self.options = options
    }

}
