//
//  CGSize+JSON.swift
//  Kumi
//
//  Created by VIRAKRI JINANGKUL on 6/4/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import SwiftyJSON

extension CGSize {

    init?(json: JSON) {
        guard let width = json["width"].cgFloat,
            let height = json["height"].cgFloat else {
                return nil
        }

        self.init(width: width, height: height)
    }

}
