//
//  Color.swift
//  Marker
//
//  Created by Michael Campbell on 5/24/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
    public typealias Color = UIColor
#elseif os(macOS)
    import AppKit
    public typealias Color = NSColor
#endif
