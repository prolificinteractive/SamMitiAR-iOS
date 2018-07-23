//
//  ARViewController.swift
//  SamMiti-Example
//
//  Created by Nattawut Singhchai on 30/1/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import UIKit
import ARKit
import SamMitiAR
import GLTFSceneKit

class ARViewController: UIViewController {
    
    let virtualObjectLoader = SamMitiVitualObjectLoader()
    
    @IBOutlet weak var samMitiARView: SamMitiARView!
    
    @IBOutlet weak var optionButton: UIView!
    
    @IBOutlet weak var addButton: UIView!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var messageContainerView: UIView!
    
    @IBOutlet weak var messageContainerVisualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var previousIsIdleTimerDisabled: Bool!
    
    var debugOptions: SamMitiDebugOptions = []
    
    //TODO: Xcode9
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            isMenuShowing = !isMenuShowing
        }
    }
    
    //TODO: Xcode10
    /*
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            isMenuShowing = !isMenuShowing
        }
    }
 */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Message Container View
        messageLabel.text = ""
        hideMessageContainerView(withAnimation: false)
        
        
        // SamMiti View mandatory delegate
        samMitiARView.samMitiARDelegate = self
        
        // SamMiti View Configuration
        samMitiARView.isAutoFocusEnabled = false
        samMitiARView.hitTestPlacingPoint = CGPoint(x: 0.5, y: 0.5)
        samMitiARView.isLightingIntensityAutomaticallyUpdated = true
        samMitiARView.environmentTexturing = .automatic
        samMitiARView.lightingEnvironmentContent = "art.scnassets/hdr-room.jpg"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Store isIdleTimerDisabled Value
        previousIsIdleTimerDisabled = UIApplication.shared.isIdleTimerDisabled
        
        // Keep screen on all the time
        UIApplication.shared.isIdleTimerDisabled = true
        samMitiARView.startAR(withDebugOptions: debugOptions)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset Stored isIdleTimerDisabled
        UIApplication.shared.isIdleTimerDisabled = previousIsIdleTimerDisabled
        
        // Pause the view's AR session.
        samMitiARView.session.pause()
    }

    // Prevent implicit transition animation of SamMitiView.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.samMitiARView.alpha = 0
        self.samMitiARView.performViewTransitionWithOutAnimation(to: size, parentViewCenterPoint: view.center)
        
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [unowned self] _ in
            self.samMitiARView.alpha = 1
            }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func resetAR() {
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        let alert = UIAlertController(title: "Reset AR", message: "This AR scene is about to be reset. Do you want to proceed this action?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in
            self.virtualObjectLoader.removeAllVirtualObjects()
            self.samMitiARView.resetAR(withDebugOptions: self.debugOptions)
            self.handleLoad(virtualNode: nil)
        }))
        present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func optionButtonDidTouch(_ sender: UIButton) {

        let sheetController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        
        sheetController.addAction(UIAlertAction(title: "Reset AR", style: .default, handler: { (action) in
            if self.debugOptions.contains(.showStateStatus) {
                self.debugOptions.remove(.showStateStatus)
            }
            if self.debugOptions.contains(.showAnchorPlane) {
                self.debugOptions.remove(.showAnchorPlane)
            }
            self.resetAR()
        }))
        
        sheetController.addAction(UIAlertAction(title: "Change to Debugging Mode", style: .default, handler: { (action) in
            self.debugOptions.insert(.showStateStatus)
            self.debugOptions.insert(.showAnchorPlane)
            self.resetAR()
        }))
        
        sheetController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheetController.popoverPresentationController?.sourceView = sender
        sheetController.popoverPresentationController?.sourceRect = CGRect(x: sender.center.x, y: 8, width: 0, height: 0)
        present(sheetController, animated: true, completion: nil)
    }
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                loadingIndicator.isHidden = false
                addButton.isHidden = true
                optionButton.isHidden = true
            }else{
                loadingIndicator.isHidden = true
                addButton.isHidden = false
                optionButton.isHidden = false
            }
        }
    }

    
    var isMenuShowing = true {
        didSet {
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
                self.setMenuShow(self.isMenuShowing)
            }, completion: nil)
        }
    }
    
    var isHomeindicatorHidden = false
    
    var isStatusBarHidden = false
    
    //TODO: Xcode9
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return isHomeindicatorHidden
    }
    
    // TODO: Xcode10
    /*
    override var prefersHomeIndicatorAutoHidden: Bool {
        return isHomeindicatorHidden
    }
     */
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    private func setMenuShow(_ isShowing: Bool = true) {
        optionButton.alpha = isShowing ? 1 : 0
        addButton.alpha = isShowing ? 1 : 0
        messageContainerView.alpha = isShowing ? 1 : 0
        
        optionButton.transform.ty = isShowing ? 0 : 44
        addButton.transform.ty = isShowing ? 0 : 44
        
        messageContainerView.transform.ty = isShowing ? 0 : -messageContainerView.bounds.height
        
        isStatusBarHidden = !isShowing
        isHomeindicatorHidden = !isShowing
        
        setNeedsStatusBarAppearanceUpdate()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    func handleLoad(virtualNode: SamMitiVirtualObject?) {
        guard let virtualNode = virtualNode else {
            return
        }
        isLoading = false
        samMitiARView.currentVirtualObject = virtualNode
        
        // Print Virtual Node Name
        print(virtualNode.name ?? "Undefined Virtual Object Name")
        
        // Example shows how to access to the content of the Virtual Node
        guard let virtualContainNode = virtualNode.contentNode else {
            return
        }
        print(virtualContainNode)
    }
    
    func remove(virtualNode: SamMitiVirtualObject?) {
        guard let virtualNode = virtualNode else {
            return
        }
        isLoading = false
        samMitiARView.currentVirtualObject = virtualNode
        
        if samMitiARView.placedVirtualObjects.contains(virtualNode) {
            let alert = UIAlertController(title: "Delete", message: "Do you want to delete \(virtualNode.name ?? "this object")?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.virtualObjectLoader.remove(virtualNode)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    var messageTimer: Timer?
    
    func messageLabelDisplay(_ messageText: String) {
        
        if messageTimer != nil {
            messageTimer?.invalidate()
            messageTimer = nil
        }
        messageLabel.text = messageText
        showMessageContainerView()
        
        messageTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
            self.hideMessageContainerView()
        }
    }
    
    private func showMessageContainerView(withAnimation Animated: Bool = true){
        UIView.animate(withDuration: Animated ? 0.35 : 0,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
                        self.messageContainerVisualEffectView.alpha = 1
                        self.messageContainerVisualEffectView.transform.ty = 0
        })
    }
    
    private func hideMessageContainerView(withAnimation Animated: Bool = true){
        UIView.animate(withDuration: Animated ? 0.35 : 0,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
                        self.messageContainerVisualEffectView.alpha = 0
                        self.messageContainerVisualEffectView.transform.ty = -self.messageContainerVisualEffectView.bounds.height
        },
                       completion: { _ in
                        self.messageLabel.text = ""
        })
    }
    
    @IBAction func addButtonDidTouch(_ sender: UIButton) {
        guard !isLoading else { return }
        
        let sheetController = UIAlertController(title: "Add Virtual Object", message: nil, preferredStyle: .actionSheet)
        
        sheetController.addAction(UIAlertAction(title: "Metal Teapot—Old Metal", style: .default, handler: { (action) in
            self.isLoading = true
            self.virtualObjectLoader.loadVirtualObject(.metalTeapotOldMetal , loadedHandler: { virtualObjectNode in
                self.handleLoad(virtualNode: virtualObjectNode)
            })
        }))
        
        sheetController.addAction(UIAlertAction(title: "Metal Teapot—Rusty", style: .default, handler: { (action) in
            self.isLoading = true
            self.virtualObjectLoader.loadVirtualObject(.metalTeapotRusty, loadedHandler: { virtualObjectNode in
                self.handleLoad(virtualNode: virtualObjectNode)
            })
        }))
        
        sheetController.addAction(UIAlertAction(title: "Metal Teapot—Gold", style: .default, handler: { (action) in
            self.isLoading = true
            self.virtualObjectLoader.loadVirtualObject(.metalTeapotGold, loadedHandler: { virtualObjectNode in
                self.handleLoad(virtualNode: virtualObjectNode)
            })
        }))
        
        sheetController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheetController.popoverPresentationController?.sourceView = sender
        sheetController.popoverPresentationController?.sourceRect = CGRect(x: sender.center.x, y: -8, width: 0, height: 0)
        present(sheetController, animated: true, completion: nil)
    }
    
    @IBAction func optionShowDebugStatusButtonDidTouch(_ sender: UISwitch) {
        if sender.isOn {
            debugOptions.insert(.showStateStatus)
        } else {
            if debugOptions.contains(.showStateStatus) {
                debugOptions.remove(.showStateStatus)
            }
        }
    }
    
    @IBAction func optionShowAnchorPlanesButtonDidTouch(_ sender: UISwitch) {
        if sender.isOn {
            debugOptions.insert(.showAnchorPlane)
        } else {
            if debugOptions.contains(.showAnchorPlane) {
                debugOptions.remove(.showAnchorPlane)
            }
        }
    }
}

extension ARViewController: SamMitiARDelegate {
    
    // MARK: SamMiti Status Delegate
    
    func trackingStateChanged(to trackingState: ARCamera.TrackingState) {
        switch trackingState {
        case .normal:
            messageLabelDisplay("Tracking: Normal")
        case .notAvailable:
            messageLabelDisplay("Tracking: Not Available")
        case .limited:
            break
        }
    }
    
    func trackingStateReasonChanged(to trackingStateReason: ARCamera.TrackingState.Reason?) {
        guard let trackingStateReason = trackingStateReason else { return }
        switch trackingStateReason {
        case ARCamera.TrackingState.Reason.excessiveMotion:
            messageLabelDisplay("Tracking: Limited - Excessive Motion")
        case ARCamera.TrackingState.Reason.initializing:
            messageLabelDisplay("Tracking: Limited - Initializing")
        case ARCamera.TrackingState.Reason.insufficientFeatures:
            messageLabelDisplay("Tracking: Limited - Insufficient Features")
        case ARCamera.TrackingState.Reason.relocalizing:
            messageLabelDisplay("Tracking: Limited - Relocalizing")
        }
    }
    
    func interactionStatusChanged(to interactionStatus: SamMitiInteractionStatus) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: SamMiti Virtual Object Hit Test Gesture Delegate
    
    func samMitiViewWillPlace(_ virtualObject: SamMitiVirtualObject, at transform: SCNMatrix4) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    func samMitiViewDidTap(on virtualObject: SamMitiVirtualObject?) {
        handleLoad(virtualNode: virtualObject)
    }
    
    func samMitiViewDidLongPress(on virtualObject: SamMitiVirtualObject?) {
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        remove(virtualNode: virtualObject)
    }
    
    /// Example of using delegate for haptic feedback when object scaling is snapped
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didSnappedToScale: Float) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Example of using delegate for haptic feedback when scaling to bound
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didScaleToBound: Float) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
