//
//  LineBreakMode.swift
//  Marker
//
//  Created by Htin Linn on 8/9/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
    public typealias LineBreakMode = NSLineBreakMode
#elseif os(macOS)
    import AppKit
    public typealias LineBreakMode = NSParagraphStyle.LineBreakMode
#endif
