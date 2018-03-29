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
    
    static var plane: SamMitiVirtualObject {
        let plane = SCNPlane(width: 0.441 / 2, height: 0.646 / 2)
        plane.firstMaterial?.diffuse.contents = UIImage(named: "profile")
        plane.firstMaterial?.isDoubleSided = true
        
        let planeNode = SCNNode(geometry: plane)
        var t = SCNMatrix4MakeRotation(-.pi / 2, 1, 0, 0)
        t = SCNMatrix4Translate(t, 0, 0, -0.015)
        planeNode.transform = t
        let virtualNode = SamMitiVirtualObject(containNode: planeNode, allowedAlignments: .all)
        virtualNode.name = "Profile Pic"
        return virtualNode
    }
    
    // Example of getting GLTF model
    static var helmet: SamMitiVirtualObject {
        let virtualNode = SamMitiVirtualObject(gltfNamed: "art.scnassets/damaged-helmet/DamagedHelmet.gltf", allowedAlignments: .all)
        virtualNode.name = "Helmet GLTF"
        
        virtualNode.setAnimationForVirtualObjectRemoving { (node, completed) in
            SceneKitAnimator.animateWithDuration(duration: 0.35, timingFunction: .easeOut, animations: {
                var transform = SCNMatrix4MakeRotation(.pi, 0, 1, 0)
                transform = SCNMatrix4Scale(transform, 0.01, 0.01, 0.01)
                node.contentNode?.transform = transform
            }, completion: completed)
        }
        return virtualNode
    }
    
    static var yorkStreetStation: SamMitiVirtualObject {
        
        let refNode = SCNReferenceNode(named: "art.scnassets/york-st-sta/station_york.scn")!
        let virtualNode = SamMitiVirtualObject(refferenceNode: refNode, allowedAlignments: [.horizontal])
        virtualNode.name = "York St. Station"
        
        virtualNode.setAnimationForVirtualObjectRemoving { (node, completed) in
            SceneKitAnimator.animateWithDuration(duration: 0.35, timingFunction: .easeOut, animations: {
                var transform = SCNMatrix4MakeRotation(.pi, 0, 1, 0)
                transform = SCNMatrix4Scale(transform, 0.01, 0.01, 0.01)
                node.contentNode?.transform = transform
            }, completion: completed)
        }
        return virtualNode
    }
    
    static var hamburger: SamMitiVirtualObject {
        
        let refNode = SCNReferenceNode(named: "art.scnassets/hamburger/hamburger.scn")!
        let virtualNode = SamMitiVirtualObject(refferenceNode: refNode, allowedAlignments: .all)
        virtualNode.name = "Eat it! Hamburger"
        
        virtualNode.setAnimationForVirtualObjectRemoving { (node, completed) in
            SceneKitAnimator.animateWithDuration(duration: 0.35, timingFunction: .easeOut, animations: {
                var transform = SCNMatrix4MakeRotation(.pi, 0, 1, 0)
                transform = SCNMatrix4Scale(transform, 0.01, 0.01, 0.01)
                node.contentNode?.transform = transform
            }, completion: completed)
        }
        return virtualNode
    }
    
    // Example of getting model via URL
    static var duck: SamMitiVirtualObject {
        let virtualNode = SamMitiVirtualObject(gltfUrl: URL(string: "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Embedded/Duck.gltf")!, allowedAlignments: .all)
        virtualNode.name = "Duck"
        return virtualNode
    }
}
