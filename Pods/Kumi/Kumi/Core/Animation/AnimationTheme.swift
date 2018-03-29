//
//  AnimationTheme.Swift
//  Kumi
//
//  Created by Prolific Interactive on 3/14/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Animation theme.
public final class AnimationTheme {

    /// Extra Fast CABasic Animation Style.
    public var extraFastCABasicAnimationStyle: CABasicAnimationStyle?

    /// Fast CABasic Animation Style.
    public var fastCABasicAnimationStyle: CABasicAnimationStyle?

    /// Normal CABasic Animation Style.
    public var normalCABasicAnimationStyle: CABasicAnimationStyle?

    /// Slow CABasic Animation Style.
    public var slowCABasicAnimationStyle: CABasicAnimationStyle?

    /// Extra Slow CABasic Animation Style.
    public var extraSlowCABasicAnimationStyle: CABasicAnimationStyle?

    /// Extra Fast UIView Animation Style.
    public var extraFastUIViewAnimationStyle: UIViewAnimationStyle?

    /// Fast UIView Animation Style.
    public var fastUIViewAnimationStyle: UIViewAnimationStyle?

    /// Normal UIView Animation Style.
    public var normalUIViewAnimationStyle: UIViewAnimationStyle?

    /// Slow UIView Animation Style.
    public var slowUIViewAnimationStyle: UIViewAnimationStyle?

    /// Extra Slow UIView Animation Style.
    public var extraSlowUIViewAnimationStyle: UIViewAnimationStyle?

    public init?(json: JSON) {

        let CABasicAnimationsJSON = json["CABasicAnimations"]
        
        extraFastCABasicAnimationStyle = CABasicAnimationStyle(json: CABasicAnimationsJSON["extraFast"])

        fastCABasicAnimationStyle = CABasicAnimationStyle(json: CABasicAnimationsJSON["fast"])

        normalCABasicAnimationStyle = CABasicAnimationStyle(json: CABasicAnimationsJSON["normal"])

        slowCABasicAnimationStyle = CABasicAnimationStyle(json: CABasicAnimationsJSON["slow"])

        extraSlowCABasicAnimationStyle = CABasicAnimationStyle(json: CABasicAnimationsJSON["extraSlow"])
        


        let UIViewAnimationsJSON = json["UIViewAnimations"]
            
        extraFastUIViewAnimationStyle = UIViewAnimationStyle(json: UIViewAnimationsJSON["extraFast"])
        
        fastUIViewAnimationStyle = UIViewAnimationStyle(json: UIViewAnimationsJSON["fast"])
    
        normalUIViewAnimationStyle = UIViewAnimationStyle(json: UIViewAnimationsJSON["normal"])
    
        slowUIViewAnimationStyle = UIViewAnimationStyle(json: UIViewAnimationsJSON["slow"])
    
        extraSlowUIViewAnimationStyle = UIViewAnimationStyle(json: UIViewAnimationsJSON["extraSlow"])

    }

}
