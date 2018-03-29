//
//  LayerStyleSet+JSON.swift
//  Kumi
//
//  Created by Nattawut Singhchai on 17/11/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation
import SwiftyJSON

public extension LayerStyleSet {
    
    init?(json: JSON) {

        self.init(normal: LayerStyle(json: json["normal"])!,
                  highlighted: LayerStyle(json: json["highlighted"]),
                  focused: LayerStyle(json: json["focused"]),
                  selected: LayerStyle(json: json["selected"]),
                  disabled: LayerStyle(json: json["disabled"]))
    }
    
    init?(json: JSON, defaultLayerStyle: LayerStyle) {
        let layerNormal = LayerStyle(json: json["normal"]) ?? defaultLayerStyle
        self.init(normal: layerNormal,
                  highlighted: LayerStyle(json: json["highlighted"]),
                  focused: LayerStyle(json: json["focused"]),
                  selected: LayerStyle(json: json["selected"]),
                  disabled: LayerStyle(json: json["disabled"]))
    }
    
}

