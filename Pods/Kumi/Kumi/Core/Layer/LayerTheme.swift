//
//  LayerTheme.Swift
//  Kumi
//
//  Created by Prolific Interactive on 3/14/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

/// Kumi layer theme.
import SwiftyJSON

public final class LayerTheme {

    /// Text input tertiary Layer Style Set.
    public var textInputTertiary: LayerStyleSet!
    
    /// Text input secondary Layer Style Set.
    public var textInputSecondary: LayerStyleSet!
    
    /// Text input primary Layer Style Set.
    public var textInputPrimary: LayerStyleSet!
    
    /// Button tertiary Layer Style Set.
    public var buttonTertiary: LayerStyleSet!
    
    /// Button secondary Layer Style Set.
    public var buttonSecondary: LayerStyleSet!
    
    /// Button primary Layer Style Set.
    public var buttonPrimary: LayerStyleSet!
    
    /// List tertiary Layer Style Set.
    public var listTertiary: LayerStyleSet!
    
    /// List secondary Layer Style Set.
    public var listSecondary: LayerStyleSet!
    
    /// List primary Layer Style Set.
    public var listPrimary: LayerStyleSet!
    
    /// Grid tertiary Layer Style Set.
    public var gridTertiary: LayerStyleSet!
    
    /// Grid secondary Layer Style Set.
    public var gridSecondary: LayerStyleSet!
    
    /// Grid primary Layer Style Set.
    public var gridPrimary: LayerStyleSet!
    
    /// Default tertiary Layer Style Set.
    public var defaultTertiary: LayerStyleSet!
    
    /// Default secondary Layer Style Set.
    public var defaultSecondary: LayerStyleSet!
    
    /// Default primary Layer Style Set.
    public var defaultPrimary: LayerStyleSet!

    public init?(json: JSON) {
        
        defaultPrimary = LayerStyleSet(json: json["defaultPrimary"])
        
        defaultSecondary = LayerStyleSet(json: json["defaultSecondary"], defaultLayerStyle: defaultPrimary.normal) ?? defaultPrimary
        
        defaultTertiary = LayerStyleSet(json: json["defaultTertiary"], defaultLayerStyle: defaultSecondary.normal) ?? defaultSecondary
        
        gridPrimary = LayerStyleSet(json: json["gridPrimary"], defaultLayerStyle: defaultPrimary.normal) ?? defaultPrimary
        
        gridSecondary = LayerStyleSet(json: json["gridSecondary"], defaultLayerStyle: gridPrimary.normal) ?? gridPrimary
        
        gridTertiary = LayerStyleSet(json: json["gridTertiary"], defaultLayerStyle: gridSecondary.normal) ?? gridSecondary
        
        listPrimary = LayerStyleSet(json: json["listPrimary"], defaultLayerStyle: defaultPrimary.normal) ?? defaultPrimary
        
        listSecondary = LayerStyleSet(json: json["listSecondary"], defaultLayerStyle: listPrimary.normal) ?? listPrimary
        
        listTertiary = LayerStyleSet(json: json["listTertiary"], defaultLayerStyle: listSecondary.normal) ?? listSecondary
        
        buttonPrimary = LayerStyleSet(json: json["buttonPrimary"], defaultLayerStyle: defaultPrimary.normal) ?? defaultPrimary
        
        buttonSecondary = LayerStyleSet(json: json["buttonSecondary"], defaultLayerStyle: buttonPrimary.normal) ?? buttonPrimary
        
        buttonTertiary = LayerStyleSet(json: json["buttonTertiary"], defaultLayerStyle: buttonSecondary.normal) ?? buttonSecondary
        
        textInputPrimary = LayerStyleSet(json: json["textInputPrimary"], defaultLayerStyle: defaultPrimary.normal) ?? defaultPrimary
        
        textInputSecondary = LayerStyleSet(json: json["textInputSecondary"], defaultLayerStyle: textInputPrimary.normal) ?? textInputPrimary
        
        textInputTertiary = LayerStyleSet(json: json["textInputTertiary"], defaultLayerStyle: textInputSecondary.normal) ?? textInputSecondary
        
    }
}
