//
//  ViewController.swift
//  
//
//  Created by Virakri Jinangkul on 7/20/18.
//

import UIKit
import SceneKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: SCNView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        
        // create a new scene
        let scene = SCNScene()
        
//        let modelNode = SCNReferenceNode(named: "art.scnassets/damaged-helmet-scn/DamagedHelmet.scn")!
        
        // TODO: Use SCNReferenceNode instead.
        let helmetScene = SCNScene(named: "art.scnassets/metal-teapot/metal-teapot.scn")!
        
        let modelNode = helmetScene.rootNode.childNode(withName: "main", recursively: false)!
        
        scene.rootNode.addChildNode(modelNode)
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 0.001
        scene.rootNode.addChildNode(cameraNode)
        
        let initialPreviewVirtualObjectMultiplier: Float = 0.333
        
        let objectBoundingBox = modelNode.boundingBox
        
        // place the camera
        cameraNode.position = SCNVector3Make((objectBoundingBox.min.x + objectBoundingBox.max.x) / 2,
                                             (objectBoundingBox.min.y + objectBoundingBox.max.y) / 2,
                                             (-objectBoundingBox.min.z + objectBoundingBox.max.z) *
                                                1 / initialPreviewVirtualObjectMultiplier)

        
        // animate the 3d object
        modelNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 10)))
        
        scene.lightingEnvironment.contents = "art.scnassets/studioHdr.hdr"
        scene.lightingEnvironment.intensity = 1.5
        
        // set the scene to the view
        sceneView.scene = scene
        
        // allows the user to manipulate the camera
        sceneView.allowsCameraControl = true
        
    }

}
