//
//  UIColor+JSON.swift
//  Kumi
//
//  Created by Thibault Klein on 4/28/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import SwiftyJSON

extension UIColor {

    convenience init?(json: JSON) {
        guard let red = json["red"].cgFloat,
        let green = json["green"].cgFloat,
        let blue = json["blue"].cgFloat else {
                return nil
        }
        let alpha: CGFloat = json["alpha"].cgFloat ?? 1
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

}
