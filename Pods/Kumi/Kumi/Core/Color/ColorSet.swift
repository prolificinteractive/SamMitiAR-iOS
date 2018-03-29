//
//  ColorSet.swift
//  Kumi
//
//  Created by Nattawut Singhchai on 17/11/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct ColorSet {
    
    public var normal: UIColor!
    public var dark: UIColor!
    public var light: UIColor!
    public var faded: UIColor!
    
    public init(normal: UIColor, dark: UIColor?, light: UIColor?, faded: UIColor?) {
        self.normal = normal
        self.dark = dark ?? normal
        self.light = light ?? normal
        self.faded = faded ?? normal
    }

}
