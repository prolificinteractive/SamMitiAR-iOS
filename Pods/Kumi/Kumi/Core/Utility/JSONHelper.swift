//
//  JSONHelper.swift
//  Kumi
//
//  Created by Nattawut Singhchai on 29/11/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct JSONHelper {
    
    public static func readJSON(path: String) -> JSON? {
        guard let data = FileManager.default.contents(atPath: path) else {
            return nil
        }
        return JSON(data)
    }
}
