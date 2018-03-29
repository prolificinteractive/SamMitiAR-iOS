//
//  Font.swift
//  Marker
//
//  Created by Michael Campbell on 5/24/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
    public typealias Font = UIFont
#elseif os(macOS)
    import AppKit
    public typealias Font = NSFont
#endif
