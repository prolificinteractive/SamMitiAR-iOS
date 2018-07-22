//
//  VirtualObject.swift
//  SamMiti-Example
//
//  Created by Nattawut Singhchai on 9/2/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import SamMitiAR
import GLTFSceneKit
import ARKit

extension SamMitiVirtualObject {
    
    // Teapot model
    static var metalTeapotOldMetal: SamMitiVirtualObject {
        let refNode = SCNReferenceNode(named: "art.scnassets/metal-teapot-rusty/metal-teapot.scn")!
        let virtualNode = SamMitiVirtualObject(refferenceNode: refNode, allowedAlignments: .all)
        virtualNode.name = "Metal Teapot—Old Metal"
        
        virtualNode.setAnimationForVirtualObjectRemoving { (node, completed) in
            SceneKitAnimator.animateWithDuration(duration: 0.35 / 2, timingFunction: .easeIn, animations: {
                let transform = SCNMatrix4MakeScale(0.01, 0.01, 0.01)
                node.contentNode?.transform = transform
            }, completion: completed)
        }
        return virtualNode
    }
    
    // Teapot model
    static var metalTeapotRusty: SamMitiVirtualObject {
        let refNode = SCNReferenceNode(named: "art.scnassets/metal-teapot-hammerite/metal-teapot.scn")!
        let virtualNode = SamMitiVirtualObject(refferenceNode: refNode, allowedAlignments: .all)
        virtualNode.name = "Metal Teapot—Hammerite"
        
        virtualNode.setAnimationForVirtualObjectRemoving { (node, completed) in
            SceneKitAnimator.animateWithDuration(duration: 0.35 / 2, timingFunction: .easeIn, animations: {
                let transform = SCNMatrix4MakeScale(0.01, 0.01, 0.01)
                node.contentNode?.transform = transform
            }, completion: completed)
        }
        return virtualNode
    }
    
    // Teapot model
    static var metalTeapotGold: SamMitiVirtualObject {
        let refNode = SCNReferenceNode(named: "art.scnassets/metal-teapot-gold/metal-teapot.scn")!
        let virtualNode = SamMitiVirtualObject(refferenceNode: refNode, allowedAlignments: .all)
        virtualNode.name = "Metal Teapot—Gold"
        
        virtualNode.setAnimationForVirtualObjectRemoving { (node, completed) in
            SceneKitAnimator.animateWithDuration(duration: 0.35 / 2, timingFunction: .easeIn, animations: {
                let transform = SCNMatrix4MakeScale(0.01, 0.01, 0.01)
                node.contentNode?.transform = transform
            }, completion: completed)
        }
        return virtualNode
    }
}
