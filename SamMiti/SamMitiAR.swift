//
//  SamMitiAR.swift
//  SamMitiAR
//
//  Created by Nattawut Singhchai on 29/1/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import ARKit

public class SamMitiARView: ARSCNView {

    let billBoardConstraint = SCNBillboardConstraint()

    private var planeDetecting = SamMitiPlaneDetecting()

    /// delegate สำหรับ event ต่างๆ ภายใน ARView
    public weak var samMitiARDelegate: SamMitiARDelegate?
    
    /// focus node ใช้ FocusNode(notFound:estimated:existing) เพื่อที่จะทำ customize focus indicator
    public var focusNode = SamMitiFocusNode() {
        didSet {
            oldValue.removeFromParentNode()
            scene.rootNode.addChildNode(focusNode)
        }
    }
    
    
    let mainKeyLight = SCNLight()
    
    let mainFillLight = SCNLight()
    
    /// A Boolean value that determines whether the device camera uses fixed focus or autofocus behavior. The default value for this property is false.
    public var isAutoFocusEnabled: Bool = false

    let translateAssumingInfinitePlane = true

    var samMitiDebugOptions: SamMitiDebugOptions = []
    
    // A point in normalized image coordinate space. (The point (0,0) represents the top left corner of the image, and the point (1,1) represents the bottom right corner.) The default value for this property is (0.5, 0.5).
    public var hitTestPlacingPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    // The view for showing debuging values
    var arDebugView: UIStackView?
    
    // A Boolean value that specifies whether SamMiti updates SceneKit Environment Intensity according to light estimate intensity divide 1000. The default value for this property is true.
    public var isLightingIntensityAutomaticallyUpdated: Bool = true
    
    // The visual contents of the material property—A cube map texture that depicts the environment surrounding the scene’s contents, used for advanced lighting effects. The default value for this property is the HDR image of photo studio.
    public var lightingEnvironmentContent: Any? = "SamMitiArt.scnassets/studioHdr.hdr"

    // A float value for Environment Intensity Multiplier. The default value for this property is 1.0.
    public var baseLightingEnvironmentIntensity: CGFloat = 1.0
    
    // The behavior ARKit uses for generating environment textures. The default value for this property is  ARWorldTrackingConfiguration.EnvironmentTexturing.automatic.
    public var environmentTexturing: SamMitiARConfiguration.EnvironmentTexturing = .automatic
    
    // Values for position tracking quality, with possible causes when tracking quality is limited.
    private var currentTrackingStateReason: ARCamera.TrackingState.Reason? {
        didSet {
            if oldValue != currentTrackingStateReason {
                samMitiARDelegate?.trackingStateReasonChanged(to: currentTrackingStateReason)
            }
        }
    }
    
    // TODO: ช่วยดูให้ที
    // Values for position tracking quality, with possible causes when tracking quality is limited.
    private var currentTrackingState: SamMitiTrackingState = .notAvailable {
        didSet {
            if oldValue != currentTrackingState {
                samMitiARDelegate?.trackingStateChanged(to: currentTrackingState)
            }
        }
    }
    
    let samMitiDelegateObject = SamMitiDelegateObject()
    
    // Options for allowing different gestures to be recognized.
    public var allowedGestureTypes: GestureTypes = .all {
        didSet {
            if gestureManager != nil {
                gestureManager = GestureManager(view: self, types: allowedGestureTypes, delegate: self)
            }
        }
    }

    var gestureManager: GestureManager?

    var currentTrackingPosition: CGPoint?
    
    var interactionStatus: SamMitiInteractionStatus = .idle {
        didSet {
            if oldValue != interactionStatus {
                interactionStatusChangedTo(interactionStatus)
                if interactionStatus == .idle {
                    
                    // Reset Confident Level, Alignment, and Hit Test Distance
                    resetPlaneDetectingValues()
                }
            }
        }
    }

    /// Virtual Object ที่จะทำ interacting ด้วย
    public weak var currentVirtualObject: SamMitiVirtualObject? {
        didSet {
            if let currentVirtualObject = currentVirtualObject,
                !placedVirtualObjects.contains(currentVirtualObject) {
                currentVirtualObject.samMitiARDelegate = self.samMitiARDelegate
                interactionStatus = .placing
            } else {
                interactionStatus = .idle
            }
        }
    }

    /// Virtual Object ที่ถูกวางไว้บน  root node เรียบร้อยแล้ว
    public var placedVirtualObjects: [SamMitiVirtualObject] {
        return scene.rootNode.childNodes.compactMap { $0 as? SamMitiVirtualObject }
    }

    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.prolific.SamMitiAR.serialSceneKitQueue")

    // MARK: - Init/Deinit
    /// Initializes and returns an SamMitiAR with given parameters.
    ///
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initSetup()
    }

    public override init(frame: CGRect, options: [String: Any]? = nil) {
        super.init(frame: frame, options: options)
        initSetup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetup()
    }

    func initSetup() {
        scene.rootNode.addChildNode(focusNode)
        samMitiDelegateObject.sceneView = self
    }

    // MARK: - Setup AR
    
    /// Use to start ARSession
    ///
    /// arDebigOptions: To show debug views
    public func startAR(withDebugOptions debugOptions: SamMitiDebugOptions = []) {

        samMitiDelegateObject.updateSession = {
            self.updateSession(for: $0, trackingState: $1)
        }

        self.delegate = samMitiDelegateObject

        self.session.delegate = samMitiDelegateObject

        gestureManager = GestureManager(view: self, types: allowedGestureTypes, delegate: self)
        
        // Initialize Tracking Session
        resetTracking()
        
        // Set up scene's camera.
        setupCamera()
        
        // Set up light nodes.
        setupLight()

        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
         */
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Setup Debug functions
        setupDebugOptions(debugOptions)
    }

    /// Use for reset session, tracking, and virtualObjects
    public func resetAR(withDebugOptions replacedDebugOptions: SamMitiDebugOptions? = nil) {
        
        if let debugOptions = replacedDebugOptions {
            setupDebugOptions(debugOptions)
        }
        currentVirtualObject = nil
        scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        
        // Initialize Tracking Session
        resetTracking()
        
        // Set up scene's camera.
        setupCamera()
        
        // Set up light nodes.
        setupLight()
    }
    
    private func setupDebugOptions(_ debugOptions: SamMitiDebugOptions) {
        
        self.samMitiDebugOptions = debugOptions
        samMitiDelegateObject.showAnchorPlane = debugOptions.contains(.showAnchorPlane)
        
        arDebugView?.removeFromSuperview()
        
        if debugOptions.contains(.showStateStatus) {
            setupDetectingLevelDebugsView()
        }
        
    }

    func resetTracking() {
        planeDetecting.reset()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .all
        if #available(iOS 12.0, *) {
            
            // TODO: ถึง Wut ดูให้หน่อย
            configuration.environmentTexturing = configuration.environmentTexturing.definedBy(environmentTexturing)
            
        }
        
        if #available(iOS 11.3, *) {
            configuration.isAutoFocusEnabled = isAutoFocusEnabled
        }
        
        session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        
        //reset Internal Values
        interactionStatus = .idle
    }

    func updateSession(for frame: ARFrame,
                       trackingState: ARCamera.TrackingState) {
        samMitiARDelegate?.updateSessionInfo(for: frame, trackingState: trackingState)
        switch trackingState {
        case .normal:
            currentTrackingState = .normal
        case .notAvailable:
            currentTrackingState = .notAvailable
        case .limited(let reason):
            currentTrackingState = .limited
            currentTrackingStateReason = reason
        }
        
        if samMitiDebugOptions.contains(.showStateStatus) {
            updateDebugViewTransform(by: frame)
        }
        
        
        let lightingEnvironment = self.scene.lightingEnvironment
        
        
        
        if environmentTexturing != .none {
            
            if let lightEstimate = session.currentFrame?.lightEstimate {
                mainKeyLight.intensity = lightEstimate.ambientIntensity *
                    baseLightingEnvironmentIntensity / 18
                mainFillLight.intensity = lightEstimate.ambientIntensity *
                    baseLightingEnvironmentIntensity / 18
                mainKeyLight.temperature = lightEstimate.ambientColorTemperature
                mainFillLight.temperature = lightEstimate.ambientColorTemperature
                
            }
        } else {
            
            // Setup the content for Lighting Environment
            lightingEnvironment.contents = lightingEnvironmentContent
            
            //         If light estimation is enabled, update the intensity of the model's lights and the environment map
            if isLightingIntensityAutomaticallyUpdated {
                if let lightEstimate = session.currentFrame?.lightEstimate {
                    lightingEnvironment.intensity = lightEstimate.ambientIntensity *
                        baseLightingEnvironmentIntensity / 666
                } else {
                    lightingEnvironment.intensity = baseLightingEnvironmentIntensity
                }
            }
            
        }
        


        let point: CGPoint = {
            let width = bounds.width * hitTestPlacingPoint.x
            let height = bounds.height * hitTestPlacingPoint.y
            return CGPoint(x: width, y: height)
        }()

        let allowedAlignments: [ARPlaneAnchor.Alignment] = currentVirtualObject?.allowedAlignments ?? []

        if interactionStatus != .interacting {
            if interactionStatus == .placing {
                focusNode.willHide = false
                if let result = self.smartHitTest(point, allowedAlignments: allowedAlignments) {
                    updateQueue.async {
                        self.scene.rootNode.addChildNode(self.focusNode)
                        let camera = self.session.currentFrame?.camera
                        
                        self.focusNode.state = .detecting(hitTestResult: result, camera: camera)
                        
                        // Update Confident Level, Alignment, and Hit Test Distance
                        self.updatePlaneDetectingValues(by: result)
                        
                    }
                } else {
                    updateQueue.async {
                        self.focusNode.state = .initializing
                        self.pointOfView?.addChildNode(self.focusNode)
                        
                        // Update Confident Level, Alignment, and Hit Test Distance
                        self.updatePlaneDetectingValues(by: nil)
                        
                    }
                }
            } else {
                // Reset Confident Level, Alignment, and Hit Test Distance
                resetPlaneDetectingValues()
                
                focusNode.willHide = true
            }
        }
    }
    
    // MARK: - Scene content setup
    
    func setupCamera() {
        guard let camera = self.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }
        
        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.wantsHDR = true
        camera.exposureOffset = 0
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    func setupLight() {
        if environmentTexturing != .none {
            mainFillLight.type = .directional
            mainFillLight.color = UIColor(white: 0.31, alpha: 1)
            mainFillLight.intensity = 0
            mainKeyLight.type = .directional
            mainKeyLight.color = UIColor(white: 0.73, alpha: 1)
            mainKeyLight.intensity = 0
            
            let lightKeyNode = SCNNode()
            lightKeyNode.light = mainKeyLight
            lightKeyNode.position.y = 48
            lightKeyNode.eulerAngles = SCNVector3(-57.996 / 180 * .pi, -7.37 / 180 * .pi, 17.772 / 180 * .pi)
            scene.rootNode.addChildNode(lightKeyNode)
            
            let lightFillNode = SCNNode()
            lightFillNode.light = mainFillLight
            lightFillNode.position.y = 48
            lightFillNode.eulerAngles = SCNVector3(-117.883 / 180 * .pi, 6.597 / 180 * .pi, -11.664 / 180 * .pi)
            scene.rootNode.addChildNode(lightFillNode)
        }
    }

    func checkConfidentLevelFor(result: ARHitTestResult?) -> PlaneDetectingConfidentLevel {
        guard let resultType = result?.type else { return .notFound }
        if #available(iOS 11.3, *) {
            switch resultType {
            case .existingPlaneUsingGeometry:
                return .existing
            case .estimatedVerticalPlane, .estimatedHorizontalPlane, .existingPlane:
                return .estimated
            default:
                return .notFound
            }
        } else {
            switch resultType {
            case .existingPlaneUsingExtent:
                return .existing
            case .estimatedHorizontalPlane, .existingPlane:
                return .estimated
            default:
                return .notFound
            }
        }
    }

    func checkAlignmentFor(result: ARHitTestResult?) -> ARPlaneAnchor.Alignment? {
        guard let result = result else { return nil }
        if #available(iOS 11.3, *) {
            if let planeAnchor = result.anchor as? ARPlaneAnchor {
                return planeAnchor.alignment
            } else {
                switch result.type {
                case .estimatedVerticalPlane:
                    return .vertical
                case .estimatedHorizontalPlane:
                    return .horizontal
                default:
                    return nil
                }
            }
        } else {
            switch result.type {
            case .estimatedHorizontalPlane, .existingPlane, .existingPlaneUsingExtent:
                return .horizontal
            default:
                return nil
            }
        }
    }

    // MARK: Position Testing


    /// Searches for real-world objects or AR anchors in the captured camera image by prioritizing different hitTestTypes according to different situations.
    ///
    /// - Parameters:
    ///   - _ point: A point in the screen-space coordinate system of the scene renderer.
    ///   - infinitePlane: A Boolean value to determine weather or not the function calculates for the estimated infinite plane.
    ///   - objectPosition: The translation of the object which uses to help determining infinite plane.
    ///   - allowedAlignments: An array of orientation allowed to be found.
    func smartHitTest(_ point: CGPoint,
                      infinitePlane: Bool = false,
                      objectPosition: float3? = nil,
                      allowedAlignments: [ARPlaneAnchor.Alignment] = .all) -> ARHitTestResult? {

        // Perform the hit test.
        var results: [ARHitTestResult]
        if #available(iOS 11.3, *) {
            results = hitTest(point, types: [.existingPlaneUsingGeometry, .estimatedVerticalPlane, .estimatedHorizontalPlane])
        } else {
            // Fallback on earlier versions
            results = hitTest(point, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
        }

            if #available(iOS 11.3, *) {
            // 1. Check for a result on an existing plane using geometry.
            if let existingPlaneUsingGeometryResult = results.first(where: { $0.type == .existingPlaneUsingGeometry }),
                let planeAnchor = existingPlaneUsingGeometryResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
                return existingPlaneUsingGeometryResult
            }
            } else {
                // Fallback on earlier versions
                if let existingPlaneUsingGeometryResult = results.first(where: { $0.type == .existingPlaneUsingExtent }),
                    let planeAnchor = existingPlaneUsingGeometryResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
                    return existingPlaneUsingGeometryResult
                }
        }

            if infinitePlane {

                // 2. Check for a result on an existing plane, assuming its dimensions are infinite.
                //    Loop through all hits against infinite existing planes and either return the
                //    nearest one (vertical planes) or return the nearest one which is within 5 cm
                //    of the object's position.
                let infinitePlaneResults = hitTest(point, types: .existingPlane)

                for infinitePlaneResult in infinitePlaneResults {
                    if let planeAnchor = infinitePlaneResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
                        if planeAnchor.alignment == .horizontal {
                            // For horizontal planes we only want to return a hit test result
                            // if it is close to the current object's position.
                            if let objectY = objectPosition?.y {
                                let planeY = infinitePlaneResult.worldTransform.translation.y
                                if objectY > planeY - 0.05 && objectY < planeY + 0.05 {
                                    return infinitePlaneResult
                                }
                            } else {
                                return infinitePlaneResult
                            }
                        } else {
                            // Return the first vertical plane hit test result.
                            return infinitePlaneResult
                        }
                    }
                }
            }

        if #available(iOS 11.3, *) {
            // 3. As a final fallback, check for a result on estimated planes.
            let vResult = results.first(where: { $0.type == .estimatedVerticalPlane })
            let hResult = results.first(where: { $0.type == .estimatedHorizontalPlane })
            switch (allowedAlignments.contains(.horizontal), allowedAlignments.contains(.vertical)) {
            case (true, false):
                return hResult
            case (false, true):
                // Allow fallback to horizontal because we assume that objects meant for vertical placement
                // (like a picture) can always be placed on a horizontal surface, too. << This is stupid!!!
                return vResult
            case (true, true):
                if hResult != nil && vResult != nil {
                    return hResult!.distance < vResult!.distance ? hResult! : vResult!
                } else {
                    return hResult ?? vResult
                }
            default:
                return nil
            }
        } else {
            // Fallback on earlier versions
            // 3. As a final fallback, check for a result on estimated planes.
            return results.first(where: { $0.type == .estimatedHorizontalPlane })
        }
    }
    
    func interactionStatusChangedTo(_ interactionStatus: SamMitiInteractionStatus) {
        samMitiARDelegate?.interactionStatusChanged(to: interactionStatus)
        if samMitiDebugOptions.contains(.showStateStatus) {
            updateInteractionStatusDebugsView(to: interactionStatus)
        }
    }
    
    func updatePlaneDetectingValues(by result: ARHitTestResult?,
                                    shouldUpdateFocusNodeConfidentLevel: Bool = true) {
        
        // Update Plane Detection Confident Level
        confidentLevelChangedTo(checkConfidentLevelFor(result: result), shouldUpdateFocusNodeConfidentLevel: shouldUpdateFocusNodeConfidentLevel)
        
        // Update Alignment
        alignmentChangedTo(checkAlignmentFor(result: result))
        
        // Update Hit Test Distance
        hitTestDistanceChangedTo(result?.distance)
        
    }
    
    func resetPlaneDetectingValues(){
        // Update Plane Detection Confident Level
        confidentLevelChangedTo(nil)
        
        // Update Alignment
        alignmentChangedTo(nil)
        
        // Update Hit Test Distance
        hitTestDistanceChangedTo(nil)
    }
    
    func confidentLevelChangedTo(_ confidentLevel: PlaneDetectingConfidentLevel?,
                                 shouldUpdateFocusNodeConfidentLevel: Bool = true) {
        if confidentLevel != self.planeDetecting.currentPlaneDetectingConfidentLevel {
            self.planeDetecting.currentPlaneDetectingConfidentLevel = confidentLevel
            if shouldUpdateFocusNodeConfidentLevel {
                self.focusNode.currentPlaneDetectingConfidentLevel = confidentLevel
            }
            samMitiARDelegate?.planeDetectingConfidentLevelChanged(to: confidentLevel)
            if samMitiDebugOptions.contains(.showStateStatus) {
                updateDetectingLevelDebugsView(to: confidentLevel)
            }
        }
    }

    func alignmentChangedTo(_ alignment: ARPlaneAnchor.Alignment?) {
        if alignment != self.planeDetecting.currentAlignment {
            self.planeDetecting.currentAlignment = alignment
            samMitiARDelegate?.alignmentChanged(to: alignment)
            
            // Check if plane detecting status debug mode has been enabled
            if samMitiDebugOptions.contains(.showStateStatus) {
                updateAlignmentDebugsView(to: alignment)
            }
        }
    }

    func hitTestDistanceChangedTo(_ distance: CGFloat?) {
        samMitiARDelegate?.hitTestDistanceChanged(to: distance)
        if samMitiDebugOptions.contains(.showStateStatus) {
            updateHitTestDistanceDebugsView(to: distance)
        }
    }

    // - MARK: Object anchors
    /// - Tag: AddOrUpdateAnchor
    func addOrUpdateAnchor(for object: SamMitiVirtualObject) {
        // If the anchor is not nil, remove it from the session.
        if let anchor = object.anchor {
            session.remove(anchor: anchor)
        }

        // Create a new anchor with the object's current transform and add it to the session
        let newAnchor = ARAnchor(transform: object.simdWorldTransform)
        object.anchor = newAnchor
        session.add(anchor: newAnchor)
    }

    func updateDebugViewTransform(by frame: ARFrame) {
        if frame.camera.eulerAngles != float3(x: 0, y: 0, z: 0) {
            let angleCorrections:[UIInterfaceOrientation] = [
                .landscapeRight,
                .portrait,
                .landscapeLeft,
                .portraitUpsideDown,
                ]
            OperationQueue.main.addOperation {
                let fixAngle = CGFloat(angleCorrections.index(of: UIApplication.shared.statusBarOrientation) ?? 1) * .pi / 2
                let transform = CATransform3DMakeRotation(CGFloat(frame.camera.eulerAngles.z) + fixAngle , 0, 0, 1)
                self.arDebugView?.layer.transform = transform
            }
        }
    }
    
    public func performTransitionWithOutAnimation(to size: CGSize, parentViewCenterPoint point: CGPoint, isAnimationDisabled: Bool = true) {
        if isAnimationDisabled {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            bounds = CGRect(origin: CGPoint.zero, size: size)
            center = point
            CATransaction.commit()
        }
    }
}

// Helpers

extension SamMitiARView {

    /// A helper method to return the first object that is found under the provided `gesture`s touch locations.
    /// - Tag: TouchTesting
    private func objectInteracting(with gesture: UIGestureRecognizer, in view: ARSCNView) -> SamMitiVirtualObject? {
        for index in 0..<gesture.numberOfTouches {
            let touchLocation = gesture.location(ofTouch: index, in: view)

            // Look for an object directly under the `touchLocation`.
            if let object = virtualObject(at: touchLocation) {
                return object
            }
        }

        // As a last resort look for an object under the center of the touches.
        return virtualObject(at: gesture.center(in: view))
    }

    /// Hit tests against the `sceneView` to find an object at the provided point.
    func virtualObject(at hitPoint: CGPoint) -> SamMitiVirtualObject? {
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
        let hitTestResults = hitTest(hitPoint, options: hitTestOptions)

        return hitTestResults.lazy.compactMap { $0.node.partOfVirtualObject() }.first
    }
}

// Gestures
extension SamMitiARView: GestureManagerDelegate {

    func receivedGesture(gesture: Gesture) {
        switch gesture {
        case .tapped(let gestureRecognizer):
            didTapped(gesture: gestureRecognizer)
        case .doubleTap(let gestureRecognizer):
            didDoubleTap(gesture: gestureRecognizer)
        case .longPress(let gestureRecognizer):
            didLongPress(gesture: gestureRecognizer)
        case .rotation(let gestureRecognizer):
            didRotate(gesture: gestureRecognizer)
        case .pinch(let gestureRecognizer):
            didPinch(gesture: gestureRecognizer)
        case .pan(let gestureRecognizer):
            didPan(gesture: gestureRecognizer)
        }
    }

    func didTapped(gesture: UITapGestureRecognizer) {

        guard case .ended = gesture.state else {
            return
        }
        
        let selectedVirtualObjectFromHitTest =  virtualObject(at: gesture.location(in: self))
        
        if let selectedVirtualObject = selectedVirtualObjectFromHitTest {
            
            // Check if the selected object has been changed
            if (currentVirtualObject != nil) ? placedVirtualObjects.contains(currentVirtualObject!) : true {
                samMitiARDelegate?.samMitiViewDidTap(on: selectedVirtualObject)
            }
        } else {
            samMitiARDelegate?.samMitiViewDidTap(on: nil)
        }

        guard let placedVirtualObject = currentVirtualObject,
            planeDetecting.currentPlaneDetectingConfidentLevel != .notFound,
            !placedVirtualObjects.contains(placedVirtualObject) else {
                return
        }
        
        // Clear virtual object 
        currentVirtualObject = nil
        
        // Place Virtual Object
        place(placedVirtualObject, at: focusNode.transform)
    }
    
    private func place(_ object: SamMitiVirtualObject, at transform: SCNMatrix4) {
        
        // Callback delegate
        self.samMitiARDelegate?.samMitiViewWillPlace(object, at: transform)
        
        // Adding virtualObject to rootNode
        self.scene.rootNode <- object
        object.virtualTransform = transform
        object.scale = SCNVector3(1, 1, 1)
        addOrUpdateAnchor(for: object)
        let finalScale = object.defaultScale
        
        object.virtualScale = finalScale * 0.01 // Scale to 0.01 to prepare for up coming animation
        
        SceneKitAnimator.animateWithDuration(duration: 0.11,
                                             timingFunction: .explodingEaseOut,
                                             animations: {
                                                object.virtualScale = finalScale * 1.2 // Scale to 1.2 to make a bouncing effect
        },
                                             completion: nil).thenAnimateWithDuration(duration: 0.2,
                                                                                      timingFunction: .easeInOut,
                                                                                      animations: {
                                                                                        object.virtualScale = finalScale
                                             }, completion: {
                                                
                                                // Callback delegate
                                                self.samMitiARDelegate?.samMitiViewDidPlace(object)
                                             })
    }
    
    func didDoubleTap(gesture: UITapGestureRecognizer) {
        
        guard case .ended = gesture.state else {
            return
        }
        
        let selectedVirtualObjectFromHitTest =  virtualObject(at: gesture.location(in: self))
        
        if let selectedVirtualObject = selectedVirtualObjectFromHitTest {
            
            // Check if the selected object has been changed
            if (currentVirtualObject != nil) ? placedVirtualObjects.contains(currentVirtualObject!) : true {
                samMitiARDelegate?.samMitiViewDidDoubleTap(on: selectedVirtualObject)
            }
        } else {
            samMitiARDelegate?.samMitiViewDidDoubleTap(on: nil)
        }
        
        guard let placedVirtualObject = currentVirtualObject,
            planeDetecting.currentPlaneDetectingConfidentLevel != .notFound,
            !placedVirtualObjects.contains(placedVirtualObject) else {
                return
        }
        
        // Clear virtual object
        currentVirtualObject = nil
        
    }
    
    func didLongPress(gesture: UILongPressGestureRecognizer) {
        
        guard case .changed = gesture.state else {
            return
        }
        
        let selectedVirtualObjectFromHitTest =  virtualObject(at: gesture.location(in: self))
        
        if let selectedVirtualObject = selectedVirtualObjectFromHitTest {
            
            // Check if the selected object has been changed
            if (currentVirtualObject != nil) ? placedVirtualObjects.contains(currentVirtualObject!) : true {
                samMitiARDelegate?.samMitiViewDidLongPress(on: selectedVirtualObject)
            }
        } else {
            samMitiARDelegate?.samMitiViewDidLongPress(on: nil)
        }
        
        guard let placedVirtualObject = currentVirtualObject,
            planeDetecting.currentPlaneDetectingConfidentLevel != .notFound,
            !placedVirtualObjects.contains(placedVirtualObject) else {
                return
        }
        
        // Clear virtual object
        currentVirtualObject = nil
        
    }
    
    func didPan(gesture: ThresholdPanGesture) {
        switch gesture.state {
        case .began:
            // Check for interaction with a new object.
            if let interactedVirtualObject = objectInteracting(with: gesture, in: self) {
                currentVirtualObject = interactedVirtualObject
            }
            
            //Set interacting status
            interactionStatus = currentVirtualObject != nil ? .interacting : .idle
            
            //Callback Delegate
            samMitiARDelegate?.samMitiViewWillBeginTranslating(virtualObject: currentVirtualObject)
            
        case .changed where gesture.isThresholdExceeded:
            guard let interactedVirtualObject = currentVirtualObject else { return }
            let translation = gesture.translation(in: self)
            
            let currentPosition = currentTrackingPosition ?? CGPoint(projectPoint(interactedVirtualObject.position))
            
            // The `currentTrackingPosition` is used to update the `selectedObject` in `updateObjectToCurrentTrackingPosition()`.
            currentTrackingPosition = CGPoint(x: currentPosition.x + translation.x, y: currentPosition.y + translation.y)
            
            gesture.setTranslation(.zero, in: self)
            
            //Set interacting status
            interactionStatus = .interacting
            
            //Callback Delegate
            samMitiARDelegate?.samMitiViewIsTranslating(virtualObject: interactedVirtualObject)
            
        case .changed:
            // Ignore changes to the pan gesture until the threshold for displacment has been exceeded.
            
            break
            
        case .ended, .cancelled:
            // Update the object's anchor when the gesture ended.
            guard let interactedVirtualObject = currentVirtualObject else { break }
            addOrUpdateAnchor(for: interactedVirtualObject)
            
            //Callback Delegate
            samMitiARDelegate?.samMitiViewDidTranslate(virtualObject: currentVirtualObject)
            
            fallthrough
            
        default:
            // Clear the current position tracking.
            currentTrackingPosition = nil
            currentVirtualObject = nil
            
            // Set interacting status
            interactionStatus = .idle
        }
    }
    
    func updateObjectToCurrentTrackingPosition() {
        guard let object = currentVirtualObject, let position = currentTrackingPosition else { return }
        translate(object, basedOn: position, infinitePlane: translateAssumingInfinitePlane, allowAnimation: true)
    }

    func didRotate(gesture: UIRotationGestureRecognizer) {
        if case .began = gesture.state {
            currentVirtualObject = virtualObject(at: gesture.location(in: self))
            
            // Set interacting status
            interactionStatus = .interacting
            
            // Callback Delegate
            samMitiARDelegate?.samMitiViewWillBeginRotating(virtualObject: currentVirtualObject)
        }
        
        if let interactedVirtualObject = currentVirtualObject, placedVirtualObjects.contains(interactedVirtualObject) {
            interactedVirtualObject.setRotation(fromGesture: gesture, inSceneView: self)
            
            // Set interacting status
            interactionStatus = .interacting
            
            // Callback Delegate
            samMitiARDelegate?.samMitiViewIsRotating(virtualObject: interactedVirtualObject)
            
        }
        
        // TODO: refactor this
        if case .ended = gesture.state {
            // Set interacting status
            interactionStatus = .idle
            
            // Callback Delegate
            samMitiARDelegate?.samMitiViewDidRotate(virtualObject: currentVirtualObject)
            
            // Clear the current virtual object.
            currentVirtualObject = nil
        } else if case .cancelled = gesture.state {
            // Set interacting status
            interactionStatus = .idle
            
            // Callback Delegate
            samMitiARDelegate?.samMitiViewDidRotate(virtualObject: currentVirtualObject)
            
            // Clear the current virtual object.
            currentVirtualObject = nil
            
        }
    }
    
    func didPinch(gesture: UIPinchGestureRecognizer) {
        
        if case .began = gesture.state {
            currentVirtualObject = virtualObject(at: gesture.location(in: self))
            
            // Set interacting status
            interactionStatus = .interacting
            
            // Callback Delegate
            samMitiARDelegate?.samMitiViewWillBeginPinching(virtualObject: currentVirtualObject)
        }
        
        if let interactedVirtualObject = currentVirtualObject, placedVirtualObjects.contains(interactedVirtualObject) {
            interactedVirtualObject.setPinch(fromGesture: gesture, inSceneView: self)
            
            // Set interacting status
            interactionStatus = .interacting
            
            // Callback Delegate
            samMitiARDelegate?.samMitiViewIsPinching(virtualObject: interactedVirtualObject)
            
        }
        
        // TODO: refactor this
        if case .ended = gesture.state {
            // Set interacting status
            interactionStatus = .idle
            
            // Callback Delegate
            samMitiARDelegate?.samMitiViewDidPinch(virtualObject: currentVirtualObject)
            
            // Clear the current virtual object.
            currentVirtualObject = nil
        } else if case .cancelled = gesture.state {
            // Set interacting status
            interactionStatus = .idle
            
            // Callback Delegate
            samMitiARDelegate?.samMitiViewDidPinch(virtualObject: currentVirtualObject)
            
            // Clear the current virtual object.
            currentVirtualObject = nil
            
        }
    }

    /// - Tag: DragVirtualObject
    private func translate(_ object: SamMitiVirtualObject,
                           basedOn screenPos: CGPoint,
                           infinitePlane: Bool,
                           allowAnimation: Bool) {
        guard let cameraTransform = session.currentFrame?.camera.transform,
            let result = smartHitTest(screenPos,
                                      infinitePlane: infinitePlane,
                                      objectPosition: object.simdWorldPosition,
                                      allowedAlignments: object.allowedAlignments) else { return }
        
        // Update Confident Level, Alignment, and Hit Test Distance
        updatePlaneDetectingValues(by: result, shouldUpdateFocusNodeConfidentLevel: false)

        var planeAlignment: ARPlaneAnchor.Alignment = .horizontal
        if let planeAnchor = result.anchor as? ARPlaneAnchor {
            planeAlignment = planeAnchor.alignment
        } else if result.type == .estimatedHorizontalPlane {
            planeAlignment = .horizontal
        } else if result.type != .estimatedHorizontalPlane {
            if #available(iOS 11.3, *) {
                planeAlignment = .vertical
            } else {
                // Fallback on earlier versions
            }
        } else {
            return
        }

        /*
         Plane hit test results are generally smooth. If we did *not* hit a plane,
         smooth the movement to prevent large jumps.
         */
        let transform = result.worldTransform
//        let isOnPlane = result.anchor is ARPlaneAnchor
        object.setTransform(transform,
                            relativeTo: cameraTransform,
                            smoothMovement: true,
                            alignment: planeAlignment,
                            allowAnimation: allowAnimation)
    }
}
