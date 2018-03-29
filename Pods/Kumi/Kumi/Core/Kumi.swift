//
//  Theme.swift
//  Kumi
//
//  Created by Thibault Klein on 4/28/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Kumi {
    
    // private section
    
    /// Color theme object.
    fileprivate static var _color: ColorTheme?
    
    /// Font theme object.
    fileprivate static var _font: FontTheme?
    
    /// Layer theme object.
    fileprivate static var _layer: LayerTheme?
    
    /// Animation theme object.
    fileprivate static var _animation: AnimationTheme?
    
    /// Shadow theme object.
    fileprivate static var _shadow: ShadowTheme?
    
    // public
    
    public static var color: ColorTheme? {
        return _color
    }
    
    public static var font: FontTheme? {
        return _font
    }
    
    public static var layer: LayerTheme? {
        return _layer
    }
    
    public static var animation: AnimationTheme? {
        return _animation
    }
    
    public static var shadow: ShadowTheme? {
        return _shadow
    }
    
    // Use `Kumi.setup()` at `AppDelegate` or before use.
    public static func setup() {
        setup(bundle: Bundle.main)
    }
    
    public static func setup(bundle: Bundle) {
        let files = bundle.paths(forResourcesOfType: "json", inDirectory: nil)
        let jsons = files.flatMap { JSONHelper.readJSON(path: $0) }.filter { !$0["kumi"].isEmpty }
        for json in jsons {
            switch json["kumi"]["type"].stringValue {
            case "color":
                _color = ColorTheme(json: json)
                break
            case "font":
                _font = FontTheme(json: json)
                break
            case "layer":
                _layer = LayerTheme(json: json)
                break
            case "animation":
                _animation = AnimationTheme(json: json)
                break
            case "shadow":
                _shadow = ShadowTheme(json: json)
                break
            default: break
            }
        }
    }
}
