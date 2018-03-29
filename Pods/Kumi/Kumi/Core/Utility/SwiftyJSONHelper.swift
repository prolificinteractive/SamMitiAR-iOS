//
//  SwiftyJSONHelper.swift
//  Kumi
//
//  Created by Nattawut Singhchai on 29/11/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import SwiftyJSON

extension JSON {
    var cgFloat: CGFloat? {
        if let double = double {
            return CGFloat(double)
        }
        if let int = int {
            return CGFloat(int)
        }
        return nil
    }
    
    var cgFloatValue: CGFloat {
        return CGFloat(floatValue)
    }
}
