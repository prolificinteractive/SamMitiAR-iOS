//
//  ColorSet+JSON.swift
//  Kumi
//
//  Created by Nattawut Singhchai on 17/11/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation
import SwiftyJSON

extension ColorSet {
    
    public init?(json: JSON) {
        self.init(normal: UIColor(json: json["normal"]) ?? .black,
                  dark: UIColor(json: json["dark"]),
                  light: UIColor(json: json["light"]),
                  faded: UIColor(json: json["faded"]))
    }
    
    public init?(json: JSON, defaultColor: UIColor) {
        self.init(normal: UIColor(json: json["normal"]) ?? defaultColor,
                  dark: UIColor(json: json["dark"]),
                  light: UIColor(json: json["light"]),
                  faded: UIColor(json: json["faded"]))
    }
}
