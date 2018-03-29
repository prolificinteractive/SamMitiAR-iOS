//
//  CATransform3D+JSON.swift
//  Pods
//
//  Created by VIRAKRI JINANGKUL on 6/4/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import SwiftyJSON

extension CATransform3D {
    
    init?(json: JSON) {
        
        self = CATransform3DIdentity
        
        if let perspective = json["perspective"].cgFloat {
            self.m34 = perspective
        }
        
        if let rotate = json["rotate"].cgFloat,
            let rotateX = json["rotateX"].cgFloat,
            let rotateY = json["rotateY"].cgFloat,
            let rotateZ = json["rotateZ"].cgFloat {
            
            self = CATransform3DRotate(self,
                                       rotate,
                                       rotateX,
                                       rotateY,
                                       rotateZ)
            
        }
        
        if let scaleX = json["scaleX"].cgFloat,
            let scaleY = json["scaleY"].cgFloat,
            let scaleZ = json["scaleZ"].cgFloat {
            
            self = CATransform3DScale(self,
                                      scaleX,
                                      scaleY,
                                      scaleZ)
        }
        
        if let translateX = json["translateX"].cgFloat,
            let translateY = json["translateY"].cgFloat,
            let translateZ = json["translateZ"].cgFloat {
            
            self = CATransform3DTranslate(self,
                                          translateX,
                                          translateY,
                                          translateZ)
        }
        
    }

}
