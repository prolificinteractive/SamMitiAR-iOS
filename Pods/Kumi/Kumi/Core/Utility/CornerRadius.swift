//
//  CornerRadius.swift
//  Prolific Design System
//
//  Created by Prolific Interactive on 3/14/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import UIKit

/// Defines an interface for fonts used in the app.
public protocol CornerRadius {

    var none: CGFloat { get }

    var extraSmall: CGFloat { get }

    var small: CGFloat { get }

    var regular: CGFloat { get }

    var large: CGFloat { get }

    var extraLarge: CGFloat { get }

    var rounded: CGFloat { get }

}
