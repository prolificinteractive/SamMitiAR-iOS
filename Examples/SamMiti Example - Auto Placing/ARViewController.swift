//
//  ViewController.swift
//  SamMiti AR Auto-placing Example
//
//  Created by Virakri Jinangkul on 7/20/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import UIKit
import SamMitiAR
import ARKit
import SceneKit

class ARViewController: UIViewController {
    
    @IBOutlet weak var sceneView: SamMitiARView!
    
    var currentModelNode = SCNNode()
    
    let virtualObjectLoader = SamMitiVitualObjectLoader()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func initializeSamMiti() {
        
        // Keep screen on all the time
        UIApplication.shared.isIdleTimerDisabled = true
        sceneView.startAR()
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .all
    }
    
    private func initializeModel() {
        let virtualObject = SamMitiVirtualObject(refferenceNode: SCNReferenceNode(named: "art.scnassets/metal-teapot/metal-teapot.scn")! , allowedAlignments: [.horizontal])
        print("Loadin virtualObject naming \(virtualObject)")
        
        virtualObjectLoader.loadVirtualObject(virtualObject) { loadedObject in
            loadedObject.scaleRange = (0.1)...10
            
            self.sceneView.currentVirtualObject = loadedObject
            
            self.sceneView.currentVirtualObject?.contentNode?.opacity = 0
            
            SceneKitAnimator.animateWithDuration(duration: 0.35, animations: {
                self.sceneView.currentVirtualObject?.contentNode?.opacity = 1
            })
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        sceneView.placingMode = .quickDrop
        
        sceneView.samMitiARDelegate = self
        sceneView.isAutoFocusEnabled = false
        sceneView.isLightingIntensityAutomaticallyUpdated = true
        
        if #available(iOS 12.0, *) {
            sceneView.environmentTexturing = .automatic
            sceneView.lightingEnvironmentContent = nil
            sceneView.baseLightingEnvironmentIntensity = 6
        } else {
            sceneView.environmentTexturing = .none
            sceneView.lightingEnvironmentContent = "art.scnassets/hdr-room.jpg"
            sceneView.baseLightingEnvironmentIntensity = 1.5
        }
        
        sceneView.initialPreviewObjectOpacity = 0.667
        sceneView.initialPreviewObjectMaxSizeRatio = CGSize(width: 0.667, height: 0.667)
        sceneView.allowedGestureTypes  = [.tap, .pan, .rotation, .pinch]
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeSamMiti()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initializeModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's AR session.
        sceneView.session.pause()
    }

    @IBAction func closeButtonDidTouch(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ARViewController: SamMitiARDelegate {
    
    /// Example of using delegate for haptic feedback when object was placed
    func samMitiViewDidPlace(_ virtualObject: SamMitiVirtualObject) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Example of using delegate for haptic feedback when object scaling is snapped
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didSnappedToScalingFactor: Float) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Example of using delegate for haptic feedback when scaling to bound
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didScaleToBound: Float) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
}
