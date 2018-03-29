//
//  AlphaValue.swift
//  Prolific Design System
//
//  Created by Prolific Interactive on 3/14/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import UIKit

public protocol AlphaValue {

    var opaque: CGFloat { get }

    var clear: CGFloat { get }

    var normal: CGFloat { get }

    var disabled: CGFloat { get }

    var darkOverlay: CGFloat { get }

    var lightOverlay: CGFloat { get }

    var shadow: CGFloat { get }

}
