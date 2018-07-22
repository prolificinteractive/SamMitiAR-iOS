//
//  SamMitiAR.swift
//  SamMitiAR
//
//  Created by Nattawut Singhchai on 29/1/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import ARKit

/**
 Placing Mode
 เป็น mode สำหรับวางวัตถุ
 - `.focusNode` เป็นการวางแบบปกติโดยจะมี indicator (focus node) ช่วย
 - `.quickDrop` เป็นโหมดการวางอัตโนมัติเมื่อเจอพื้นผิวที่สามารถวางได้
 */
public enum PlacingMode {
    
    case focusNode
    
    case quickDrop
}

final public class SamMitiARView: ARSCNView {
    
    // MARK: - Public Access
    
    /**
     Delegate สำหรับ event ต่างๆ ภายใน ARView
     */
    public weak var samMitiARDelegate: SamMitiARDelegate?
    
    /**
     Focus node ใช้ FocusNode(notFound:estimated:existing) เพื่อที่จะทำ customize focus indicator
     */
    public var focusNode = SamMitiFocusNode() {
        didSet {
            oldValue.removeFromParentNode()
            if placingMode == .quickDrop {
                focusNode.isHidden = true
            }
            scene.rootNode.addChildNode(focusNode)
            
        }
    }
    
    /**
     Current Placing Mode
     */
    public var placingMode: PlacingMode = .focusNode {
        didSet {
            focusNode.isHidden = placingMode != .focusNode
        }
    }
    
    /**
     A Boolean value that determines whether the device camera uses fixed focus or autofocus behavior. The default value for this property is false.
     */
    public var isAutoFocusEnabled: Bool = false
    
    /**
     A point in normalized image coordinate space. (The point (0,0) represents the top left corner of the image, and the point (1,1) represents the bottom right corner.) The default value for this property is (0.5, 0.5). This value is only used when placing mode is set to focus node otherwise the value will be overridden by the position of the preview vistual object.
     */
    public var hitTestPlacingPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    /**
     A Boolean value that specifies whether SamMiti updates SceneKit Environment Intensity according to light estimate intensity divide 1000. The default value for this property is true.
     */
    public var isLightingIntensityAutomaticallyUpdated: Bool = true
    
    /**
     The visual contents of the material property—A cube map texture that depicts the environment surrounding the scene’s contents, used for advanced lighting effects. The default value for this property is the HDR image of photo studio.
     */
    public var lightingEnvironmentContent: Any? = "SamMitiArt.scnassets/studioHdr.hdr"
    
    /**
     A float value for Environment Intensity Multiplier. The default value for this property is 1.0.
     */
    public var baseLightingEnvironmentIntensity: CGFloat = 1.0
    
    /**
     The behavior ARKit uses for generating environment textures. The default value for this property is  `ARWorldTrackingConfiguration.EnvironmentTexturing.automatic`.
     */
    public var environmentTexturing: SamMitiARConfiguration.EnvironmentTexturing = .automatic
    
    /**
     Options for allowing different gestures to be recognized.
     */
    public var allowedGestureTypes: GestureTypes = .all {
        didSet {
            if gestureManager != nil {
                gestureManager = GestureManager(view: self, types: allowedGestureTypes, delegate: self)
            }
        }
    }
    
    /**
     The initial size ratio ot the screen of the virtual object ( value 1 means the bounding box of the virtual object in that particular axis will be full screen) for automatic placing mode (if using focus node mode this value will be ignored.) Default value for this property is CGSize(width: 0.667, height: 0.667).
     */
    public var initialPreviewObjectMaxSizeRatio: CGSize = CGSize(width: 0.667, height: 0.667)
    
    /**
     The initial opacity of the virtual object for automatic placing mode (if using focus node mode this value will be ignored.) Default value for this property is  0.667.
     */
    public var initialPreviewObjectOpacity: CGFloat = 0.667
    
    /// Virtual Object ที่จะทำ interacting ด้วย
    public weak var currentVirtualObject: SamMitiVirtualObject? {
        didSet {
            setCurrentVirtualObject(to: currentVirtualObject)
        }
    }
    
    /// Virtual Object ที่ถูกวางไว้บน  root node เรียบร้อยแล้ว
    public var placedVirtualObjects: [SamMitiVirtualObject] {
        return scene.rootNode.childNodes.compactMap { $0 as? SamMitiVirtualObject }
    }
    
    public var currentPlanConfidentLevel: PlaneDetectingConfidentLevel? {
        return planeDetecting.currentPlaneDetectingConfidentLevel
    }
    
    // MARK: - Private/Internal Uses
    private var planeDetecting = SamMitiPlaneDetecting()
    
    private let billBoardConstraint = SCNBillboardConstraint()
    
    private let mainKeyLight = SCNLight()
    
    private let mainFillLight = SCNLight()
    
    private let translateAssumingInfinitePlane = true
    
    private var samMitiDebugOptions: SamMitiDebugOptions = []
    
    // The view for showing debuging values
    var arDebugView: UIStackView?
    
    // Values for position tracking quality, with possible causes when tracking quality is limited.
    private var currentTrackingStateReason: ARCamera.TrackingState.Reason? {
        didSet {
            if oldValue != currentTrackingStateReason {
                samMitiARDelegate?.trackingStateReasonChanged(to: currentTrackingStateReason)
            }
        }
    }
    
    // Values for position tracking quality, with possible causes when tracking quality is limited.
    private var currentTrackingState: SamMitiTrackingState = .notAvailable {
        didSet {
            if oldValue != currentTrackingState {
                samMitiARDelegate?.trackingStateChanged(to: currentTrackingState)
            }
        }
    }
    
    private let samMitiDelegateObject = SamMitiDelegateObject()
    
    private var gestureManager: GestureManager?
    
    private var currentTrackingPosition: CGPoint?
    
    private var interactionStatus: SamMitiInteractionStatus = .idle {
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
    
    private var currentGesture: GestureTypes?
    
    /// A serial queue used to coordinate adding or removing nodes from the scene.
    private let updateQueue = DispatchQueue(label: "com.prolific.SamMitiAR.serialSceneKitQueue")
    
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
    
    var isAdjustOntoPlaneAnchorEnabled: Bool = true
    
    private func initSetup() {
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
        
        resetAR(withDebugOptions: debugOptions)
        
        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
         */
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    /// Use for reset session, tracking, and virtualObjects
    public func resetAR(withDebugOptions replacedDebugOptions: SamMitiDebugOptions? = nil) {
        
        if let debugOptions = replacedDebugOptions {
            setupDebugOptions(debugOptions)
        }
        
        currentVirtualObject = nil
        
        placedVirtualObjects.forEach { $0.removeFromParentNode() }
        
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
    
    private func resetTracking() {
        planeDetecting.reset()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .all
        if #available(iOS 12.0, *) {
            
            // TODO: ถึง Wut ดูให้หน่อย
            configuration.environmentTexturing = configuration.environmentTexturing.definedBy(environmentTexturing)
            
        }
        
        configuration.isAutoFocusEnabled = isAutoFocusEnabled
        
        
        session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        
        //reset Internal Values
        interactionStatus = .idle
    }
    
    private func updateSession(for frame: ARFrame,
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
        
        if let lightEstimate = session.currentFrame?.lightEstimate {
            mainKeyLight.intensity = lightEstimate.ambientIntensity *
                baseLightingEnvironmentIntensity / 18
            mainFillLight.intensity = lightEstimate.ambientIntensity *
                baseLightingEnvironmentIntensity / 18
            mainKeyLight.temperature = lightEstimate.ambientColorTemperature
            mainFillLight.temperature = lightEstimate.ambientColorTemperature
            
        }
        
        if environmentTexturing == .none {
            
            // Setup the content for Lighting Environment
            lightingEnvironment.contents = lightingEnvironmentContent
            
            // If light estimation is enabled, update the intensity of the model's lights and the environment map
            if isLightingIntensityAutomaticallyUpdated {
                if let lightEstimate = session.currentFrame?.lightEstimate {
                    lightingEnvironment.intensity = lightEstimate.ambientIntensity *
                        baseLightingEnvironmentIntensity / 1000
                } else {
                    lightingEnvironment.intensity = baseLightingEnvironmentIntensity
                }
            }
        } else {
            
            // Set nil to content for Lighting Environment
            lightingEnvironment.contents = nil
            
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
    
    private func setupCamera() {
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
    
    private func setupLight() {
        mainFillLight.type = .directional
        mainFillLight.castsShadow = false
        mainFillLight.color = UIColor(white: 0.31, alpha: 1)
        mainFillLight.intensity = 0
        mainKeyLight.type = .directional
        mainKeyLight.castsShadow = false
        mainKeyLight.color = UIColor(white: 0.73, alpha: 1)
        mainKeyLight.intensity = 0
        
        let lightKeyNode = SCNNode()
        lightKeyNode.light = mainKeyLight
        lightKeyNode.position.y = 48
        let lightKeyContainNode = SCNNode()
        lightKeyContainNode.addChildNode(lightKeyNode)
        lightKeyContainNode.eulerAngles = SCNVector3(-57.996 / 180 * .pi, -7.37 / 180 * .pi, 17.772 / 180 * .pi)
        scene.rootNode.addChildNode(lightKeyContainNode)
        
        let lightFillNode = SCNNode()
        lightFillNode.light = mainFillLight
        lightFillNode.position.y = 48
        let lightFillNodeContainNode = SCNNode()
        lightFillNodeContainNode.addChildNode(lightFillNode)
        lightFillNodeContainNode.eulerAngles = SCNVector3(-117.883 / 180 * .pi, 6.597 / 180 * .pi, -11.664 / 180 * .pi)
        scene.rootNode.addChildNode(lightFillNodeContainNode)
    }
    
    private func checkConfidentLevelFor(result: ARHitTestResult?) -> PlaneDetectingConfidentLevel {
        guard let resultType = result?.type else { return .notFound }
        switch resultType {
        case .existingPlaneUsingGeometry:
            return .existing
        case .estimatedVerticalPlane, .estimatedHorizontalPlane, .existingPlane:
            return .estimated
        default:
            return .notFound
        }
    }
    
    private func checkAlignmentFor(result: ARHitTestResult?) -> ARPlaneAnchor.Alignment? {
        guard let result = result else { return nil }
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
    }
    
    // MARK: - Positioning
    
    /**
     Searches for real-world objects or AR anchors in the captured camera image by prioritizing different hitTestTypes according to different situations.
     
     - Parameters:
     - _ point: A point in the screen-space coordinate system of the scene renderer.
     - infinitePlane: A Boolean value to determine weather or not the function calculates for the estimated infinite plane.
     - objectPosition: The translation of the object which uses to help determining infinite plane.
     - allowedAlignments: An array of orientation allowed to be found.
     */
    private func smartHitTest(_ point: CGPoint,
                              infinitePlane: Bool = false,
                              objectPosition: float3? = nil,
                              allowedAlignments: [ARPlaneAnchor.Alignment] = .all) -> ARHitTestResult? {
        
        // Perform the hit test.
        let results = hitTest(point, types: [.existingPlaneUsingGeometry, .estimatedVerticalPlane, .estimatedHorizontalPlane])
        
        
        // 1. Check for a result on an existing plane using geometry.
        if let existingPlaneUsingGeometryResult = results.first(where: { $0.type == .existingPlaneUsingGeometry }),
            let planeAnchor = existingPlaneUsingGeometryResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
            return existingPlaneUsingGeometryResult
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
        
    }
    
    private func interactionStatusChangedTo(_ interactionStatus: SamMitiInteractionStatus) {
        samMitiARDelegate?.interactionStatusChanged(to: interactionStatus)
        if samMitiDebugOptions.contains(.showStateStatus) {
            updateInteractionStatusDebugsView(to: interactionStatus)
        }
    }
    
    private func updatePlaneDetectingValues(by result: ARHitTestResult?,
                                            shouldUpdateFocusNodeConfidentLevel: Bool = true) {
        
        // Update Plane Detection Confident Level
        confidentLevelChangedTo(checkConfidentLevelFor(result: result), shouldUpdateFocusNodeConfidentLevel: shouldUpdateFocusNodeConfidentLevel)
        
        // Update Alignment
        alignmentChangedTo(checkAlignmentFor(result: result))
        
        // Update Hit Test Distance
        hitTestDistanceChangedTo(result?.distance)
        
    }
    
    private func resetPlaneDetectingValues(){
        // Update Plane Detection Confident Level
        confidentLevelChangedTo(nil)
        
        // Update Alignment
        alignmentChangedTo(nil)
        
        // Update Hit Test Distance
        hitTestDistanceChangedTo(nil)
    }
    
    private func confidentLevelChangedTo(_ confidentLevel: PlaneDetectingConfidentLevel?,
                                         shouldUpdateFocusNodeConfidentLevel: Bool = true) {
        if confidentLevel != self.planeDetecting.currentPlaneDetectingConfidentLevel {
            self.planeDetecting.currentPlaneDetectingConfidentLevel = confidentLevel
            if shouldUpdateFocusNodeConfidentLevel {
                self.focusNode.currentPlaneDetectingConfidentLevel = confidentLevel
            }
            samMitiARDelegate?.planeDetectingConfidentLevelChanged(to: confidentLevel)
            if let currentVirtualObject = currentVirtualObject,
                !placedVirtualObjects.contains(currentVirtualObject),
                case .existing? = confidentLevel,
                case .quickDrop = placingMode {
                OperationQueue.main.addOperation {
                    self.place(byTransitioningFromCurrentTransform: true)
                }
            }
            if samMitiDebugOptions.contains(.showStateStatus) {
                updateDetectingLevelDebugsView(to: confidentLevel)
            }
        }
    }
    
    private func alignmentChangedTo(_ alignment: ARPlaneAnchor.Alignment?) {
        if alignment != self.planeDetecting.currentAlignment {
            self.planeDetecting.currentAlignment = alignment
            samMitiARDelegate?.alignmentChanged(to: alignment)
            
            // Check if plane detecting status debug mode has been enabled
            if samMitiDebugOptions.contains(.showStateStatus) {
                updateAlignmentDebugsView(to: alignment)
            }
        }
    }
    
    private func hitTestDistanceChangedTo(_ distance: CGFloat?) {
        samMitiARDelegate?.hitTestDistanceChanged(to: distance)
        if samMitiDebugOptions.contains(.showStateStatus) {
            updateHitTestDistanceDebugsView(to: distance)
        }
    }
    
    // - MARK: - Object Anchors
    /// - Tag: AddOrUpdateAnchor
    private func addOrUpdateAnchor(for object: SamMitiVirtualObject) {
        // If the anchor is not nil, remove it from the session.
        if let anchor = object.anchor {
            session.remove(anchor: anchor)
        }
        
        // Create a new anchor with the object's current transform and add it to the session
        let newAnchor = ARAnchor(transform: object.simdWorldTransform)
        object.anchor = newAnchor
        session.add(anchor: newAnchor)
    }
    
    private func updateDebugViewTransform(by frame: ARFrame) {
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
        // TODO: Rename this function name to have it make more sense (and refer to UIView more)
        if isAnimationDisabled {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            bounds = CGRect(origin: CGPoint.zero, size: size)
            center = point
            CATransaction.commit()
        }
    }
    
    // MARK: - Placing Virtual Objects
    
    public func place(byTransitioningFromCurrentTransform isTransitioningFromCurrectTransform: Bool = false) {
        guard let placedVirtualObject = currentVirtualObject,
            planeDetecting.currentPlaneDetectingConfidentLevel != .notFound,
            !placedVirtualObjects.contains(placedVirtualObject) else {
                return
        }
        
        // Clear virtual object
        currentVirtualObject = nil
        
        // Place Virtual Object
        if isTransitioningFromCurrectTransform {
            place(placedVirtualObject, at: focusNode.transform, from: placedVirtualObject.worldTransform)
        } else {
            place(placedVirtualObject, at: focusNode.transform)
        }
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
        
        SceneKitAnimator
            .animateWithDuration(duration: 0.11,
                                 timingFunction: .explodingEaseOut,
                                 animations: {
                                    object.virtualScale = finalScale * 1.2 // Scale to 1.2 to make a bouncing effect
                                    object.opacity = 1
            })
            .thenAnimateWithDuration(duration: 0.2,
                                     timingFunction: .easeInOut,
                                     animations: {
                                        object.virtualScale = finalScale
                                        
            }, completion: {
                
                // Callback delegate
                self.samMitiARDelegate?.samMitiViewDidPlace(object)
            })
    }
    
    private func place(_ object: SamMitiVirtualObject, at transform: SCNMatrix4, from currentTranform: SCNMatrix4) {
        
        // Callback delegate
        self.samMitiARDelegate?.samMitiViewWillPlace(object, at: transform)
        
        // Adding virtualObject to rootNode
        self.scene.rootNode <- object
        object.virtualTransform = currentTranform
        
        SceneKitAnimator
            .animateWithDuration(duration: 0.5,
                                 timingFunction: .easeInOut,
                                 animations: {
                                    object.virtualTransform = transform
                                    object.scale = SCNVector3(1, 1, 1)
                                    object.opacity = 1
                                    
            }, completion: {
                
                // Start AdjustOntoPlaneAnchor
                self.isAdjustOntoPlaneAnchorEnabled = true
                
                // Add current position Anchor
                self.addOrUpdateAnchor(for: object)
                
                // Callback delegate
                self.samMitiARDelegate?.samMitiViewDidPlace(object)
            })
    }
    
    private func getCameraFov() -> vector_float2 {
        // - TODO: Create/find logic of finding FOV of ARKit
        let currentOrientation = UIApplication.shared.statusBarOrientation
        
        let viewSize = bounds.size
        
        if (session.currentFrame?.camera) != nil  {
            // In case ARSession has been initialized, real FOV will be calculated from the camera projection matrix.
            
            let currentFrameCamera = session.currentFrame!.camera
            
            let projection = currentFrameCamera.projectionMatrix(for: currentOrientation,
                                                                 viewportSize: viewSize,
                                                                 zNear: 0.1,
                                                                 zFar: 0.9)
            let yScale = projection[ 1, 1 ] // = 1/tan(fovy/2)
            let yFov = 2 * atan( 1 / yScale )
            let xFov = yFov * Float( viewSize.width / viewSize.height )
            
            return vector_float2(xFov,
                                 yFov)
            
        } else {
            // Hardcoded Values in case ARSession hasn't been initialized.
            
            /// 3:4 iPhone & iPad Camera FOV = (x: 1.132, y: 0.849)
            var cameraFov = vector_float2(1.132, 0.849)
            
            /// Initialize Camera Image Resolution
            var cameraImageResolution = CGSize()
            
            if #available(iOS 12.0, *) {
                switch UIDevice.current.userInterfaceIdiom {
                case .phone:
                    cameraImageResolution = CGSize(width: 1920, height: 1440)
                case .pad:
                    cameraImageResolution = CGSize(width: 1920, height: 1080)
                default:
                    cameraImageResolution = CGSize(width: 1920, height: 1440)
                }
            } else {
                cameraImageResolution = CGSize(width: 1920, height: 1080)
            }
            
            if currentOrientation == .portrait || currentOrientation == .portraitUpsideDown {
                cameraFov = vector_float2(cameraFov.y, cameraFov.x)
                cameraImageResolution = CGSize(width: cameraImageResolution.height,
                                               height: cameraImageResolution.width)
            }
            
            /// Initialize AR Crop FOV
            var croppedCameraFov = vector_float2()
            
            if Float(cameraImageResolution.width / cameraImageResolution.height) < cameraFov.x / cameraFov.y {
                croppedCameraFov = vector_float2(Float(cameraImageResolution.width / cameraImageResolution.height) * cameraFov.y,
                                                 cameraFov.y)
            } else {
                croppedCameraFov = vector_float2(cameraFov.x,
                                                 Float(cameraImageResolution.height / cameraImageResolution.width) * cameraFov.x )
            }
            
            /// Return Cropped FOV by View size
            if Float(viewSize.width / viewSize.height) < croppedCameraFov.x / croppedCameraFov.y {
                return vector_float2(Float(viewSize.width / viewSize.height) * croppedCameraFov.y,
                                     croppedCameraFov.y)
            } else {
                return vector_float2(croppedCameraFov.x,
                                     Float(viewSize.height / viewSize.width) * croppedCameraFov.x )
            }
        }
    }
    
    private func setCurrentVirtualObject(to currentVirtualObject: SamMitiVirtualObject?) {
        if let currentVirtualObject = currentVirtualObject,
            !placedVirtualObjects.contains(currentVirtualObject) {
            currentVirtualObject.samMitiARDelegate = self.samMitiARDelegate
            interactionStatus = .placing
            
            if placingMode == .quickDrop {
                
                // Turn isAdjustOntoPlaneAnchorEnabled off to wait until the object get placed
                isAdjustOntoPlaneAnchorEnabled = false
                
                // Set Transparency Mode to Single Layer to display one layer see through opacity.
                currentVirtualObject.setMaterialTransparencyMode(to: .singleLayer)
                
                guard let objectBoundingBox = currentVirtualObject.contentNode?.boundingBox else { return }
                
                let cameraFov = getCameraFov()
                
                let objectBoundingBoxSize = SCNVector3((-objectBoundingBox.min.x + objectBoundingBox.max.x),
                                                       (-objectBoundingBox.min.y + objectBoundingBox.max.y),
                                                       (-objectBoundingBox.min.z + objectBoundingBox.max.z))
                
                let minimumSafeAreaBox = SCNVector3(objectBoundingBoxSize.x * Float( 1 / initialPreviewObjectMaxSizeRatio.width ),
                                                    objectBoundingBoxSize.y * Float( 1 / initialPreviewObjectMaxSizeRatio.height ),
                                                    objectBoundingBoxSize.z)
                
                let minDistanceFromX = minimumSafeAreaBox.x / tan(cameraFov.x) - objectBoundingBox.min.z
                let minDistanceFromY = minimumSafeAreaBox.y / tan(cameraFov.y) - objectBoundingBox.min.z
                
                currentVirtualObject.position = SCNVector3Make(-(objectBoundingBox.min.x + objectBoundingBox.max.x) / 2,
                                                               -(objectBoundingBox.min.y + objectBoundingBox.max.y) / 2,
                                                               -max(minDistanceFromX, minDistanceFromY))
                
                currentVirtualObject.eulerAngles = SCNVector3Make(.pi / 32, 0, 0)
                currentVirtualObject.opacity = initialPreviewObjectOpacity
                pointOfView?.addChildNode(currentVirtualObject)
                
                // Override hitTestPlacingPoint by the position of the preview virtual object
                hitTestPlacingPoint = CGPoint(x: CGFloat(projectPoint(currentVirtualObject.worldPosition).x) / bounds.width,
                                              y: CGFloat(projectPoint(currentVirtualObject.worldPosition).y) / bounds.height)
                
                if case .existing? = planeDetecting.currentPlaneDetectingConfidentLevel {
                    OperationQueue.main.addOperation {
                        self.place(byTransitioningFromCurrentTransform: true)
                    }
                }
            }
        } else {
            interactionStatus = .idle
        }
    }
    
    func updateObjectToCurrentTrackingPosition() {
        guard let object = currentVirtualObject, let position = currentTrackingPosition else { return }
        translate(object, basedOn: position, infinitePlane: translateAssumingInfinitePlane, allowAnimation: true)
    }
}

// MARK: - Helpers
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
    
    /// get current placing state
    public var isPlacingVirtualObject: Bool {
        guard let currentVirtualObject = currentVirtualObject else {
            return false
        }
        return !placedVirtualObjects.contains(currentVirtualObject)
    }
}

// MARK: - Gestures
extension SamMitiARView: GestureManagerDelegate {
    
    func receivedGesture(gesture: Gesture) {
        switch gesture {
        case .tapped(let gestureRecognizer):
            didTapped(gesture: gestureRecognizer)
        case .doubleTap(let gestureRecognizer) where !isPlacingVirtualObject:
            didDoubleTap(gesture: gestureRecognizer)
        case .longPress(let gestureRecognizer) where !isPlacingVirtualObject:
            didLongPress(gesture: gestureRecognizer)
        case .rotation(let gestureRecognizer) where !isPlacingVirtualObject:
            didRotate(gesture: gestureRecognizer)
        case .pinch(let gestureRecognizer) where !isPlacingVirtualObject:
            didPinch(gesture: gestureRecognizer)
        case .pan(let gestureRecognizer) where !isPlacingVirtualObject:
            didPan(gesture: gestureRecognizer)
        default:
            break
        }
    }
    
    private func didTapped(gesture: UITapGestureRecognizer) {
        
        guard case .ended = gesture.state else {
            return
        }
        
        if let selectedVirtualObject = virtualObject(at: gesture.location(in: self)) {
            
            // Check if the selected object has been changed
            if (currentVirtualObject != nil) ? placedVirtualObjects.contains(currentVirtualObject!) : true {
                samMitiARDelegate?.samMitiViewDidTap(on: selectedVirtualObject)
            }
        } else {
            samMitiARDelegate?.samMitiViewDidTap(on: nil)
        }
        
        if placingMode == .focusNode {
            place()
        }
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
            if let interactedVirtualObject = objectInteracting(with: gesture, in: self),
                currentVirtualObject == nil {
                currentVirtualObject = interactedVirtualObject
                currentGesture = .pan
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
            
            if currentGesture == .pan {
                
                currentVirtualObject = nil
                
                // Set interacting status
                interactionStatus = .idle
                
                currentGesture = nil
            }
        }
    }
    
    func didRotate(gesture: UIRotationGestureRecognizer) {
        if case .began = gesture.state {
            
            if currentVirtualObject == nil {
                currentVirtualObject = virtualObject(at: gesture.location(in: self))
                currentGesture = .rotation
            }
            
            
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
        
        if .ended == gesture.state || .cancelled == gesture.state {
            // Callback Delegate
            samMitiARDelegate?.samMitiViewDidRotate(virtualObject: currentVirtualObject)
            
            if currentGesture == .rotation {
                // Set interacting status
                interactionStatus = .idle
                
                // Clear the current virtual object.
                currentVirtualObject = nil
                
                currentGesture = nil
            }
            
        }
    }
    
    func didPinch(gesture: UIPinchGestureRecognizer) {
        
        if case .began = gesture.state {
            
            if currentGesture == nil {
                currentVirtualObject = virtualObject(at: gesture.location(in: self))
                currentGesture = .pinch
            }
            
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
        
        if .ended == gesture.state || .cancelled == gesture.state {
            
            // Callback Delegate
            samMitiARDelegate?.samMitiViewDidPinch(virtualObject: currentVirtualObject)
            
            if currentGesture == .pinch {
                // Set interacting status
                interactionStatus = .idle
                
                // Clear the current virtual object.
                currentVirtualObject = nil
                
                currentGesture = nil
            }
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
            planeAlignment = .vertical
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
