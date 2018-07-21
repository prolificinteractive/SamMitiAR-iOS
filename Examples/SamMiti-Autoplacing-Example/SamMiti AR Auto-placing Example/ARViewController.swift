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
    
    private func initializeModel() {
        let virtualObject = SamMitiVirtualObject(refferenceNode: SCNReferenceNode(named: "art.scnassets/damaged-helmet-scn/DamagedHelmet.scn")! , allowedAlignments: [.horizontal])
        print("Loadin virtualObject naming \(virtualObject)")
        
        virtualObjectLoader.loadVirtualObject(virtualObject) { loadedObject in
            loadedObject.scaleRange = (0.1)...10
            
            self.sceneView.currentVirtualObject = loadedObject
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        sceneView.placingMode = .automatic
        
        sceneView.samMitiARDelegate = self
        sceneView.isAutoFocusEnabled = false
//        sceneView.hitTestPlacingPoint = CGPoint(x: 0.5, y: 0.5)
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
        
        sceneView.allowedGestureTypes  = [.tap, .pan, .rotation, .pinch]
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeSamMiti()
        initializeModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's AR session.
        sceneView.session.pause()
    }
    
    private func initializeSamMiti() {
        
        // Keep screen on all the time
        UIApplication.shared.isIdleTimerDisabled = true
        sceneView.startAR()
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .all
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
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didSnappedToPoint: Float) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Example of using delegate for haptic feedback when scaling to bound
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didScaleToBound: Float) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
}
