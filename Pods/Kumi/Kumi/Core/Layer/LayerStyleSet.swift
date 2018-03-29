//
//  LayerStyleSet.swift
//  Kumi
//
//  Created by Nattawut Singhchai on 17/11/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

public struct LayerStyleSet {
    
    public var normal: LayerStyle
    
    public var highlighted: LayerStyle
    
    public var focused: LayerStyle
    
    public var selected: LayerStyle
    
    public var disabled: LayerStyle
    
    init(normal: LayerStyle, highlighted: LayerStyle?, focused: LayerStyle?, selected: LayerStyle?, disabled: LayerStyle?) {
        self.normal = normal
        let _highlighted = highlighted ?? normal
        self.highlighted = _highlighted
        self.focused = focused ?? _highlighted
        self.selected = selected ?? _highlighted
        self.disabled = disabled ?? normal
    }
}
