//
//  SamMitiVirtualObject.swift
//  SamMiti
//
//  Created by Nattawut Singhchai on 7/2/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import ARKit
import GLTFSceneKit

//TODO: Add interaction ability (Movable, Scalable, Rotatable)

open class SamMitiVirtualObject: SCNNode {
    
    public typealias VoidBlock = () -> Void
    
    enum LoadingType {
        
        enum GLTFSourceType {
            case name(String)
            case path(String)
            case url(URL)
        }
        
        case none
        case refferenceNode(SCNReferenceNode)
        case gltf(GLTFSourceType)
    }

    /// Anchor
    public var anchor: ARAnchor?
    
    /// Current plane anchor
//    public var currentPlaneAnchor: ARPlaneAnchor?
    
    /// Alignment ไหนที่วางได้บ้าง
    public var allowedAlignments: [ARPlaneAnchor.Alignment] = .all

    /// ใช้สำหรับจำกัด min, max scale ของวัตถุ
    ///
    /// Example: scaleRange = (0.01)...2
    public var scaleRange: ClosedRange<Float>?
    
    // Snap Zoom
    /// points (1 is default scale), [] = disable
    public var snapScalingPoints: [Float] = [1.0]
    
    /// snap threshold:
    /// where [ 0 > threshold > 1 ]
    /// -------- p -------
    ///    |<-t->|<-t->|
    public var snapScalingThreshold: Float = 0.1
    
    /// Temporaly begin rotation factor
    private var temporalyBeginRotationFactor: Float = 0
    
    /// Temporaly begin pinch factor
    private var temporalyBeginPinchFactor: Float = 1

    /// Object นี้ถูก load หรือยัง
    public private(set) var isLoaded: Bool
    
    /// Loading type
    var loadingType: LoadingType = .none

    /// ใช้สำหรับปรับขนาดของวัตถุ
    public private(set) var nodeScale: Float = 1 {
        didSet {
            let scaleFactor = nodeScale
            scaleControllerNode.scale = SCNVector3Make(scaleFactor, scaleFactor, scaleFactor)
        }
    }

    /// ใช้สำหรับเก็บค่า scaleMultiplier
    private var _virtualScale: Float = 1
    
    /// Object scaling
    public var virtualScale: Float {
        get {
            return _virtualScale
        } set {
            let scale: Float
            if let scaleRange = scaleRange {
                scale = max(scaleRange.lowerBound, min(scaleRange.upperBound, newValue))
            } else {
                scale = newValue
            }
            
            // find possible snap point
            let snapPoint = snapScalingPoints.first {
                let begin = $0 * (1 - self.snapScalingThreshold)
                let end = $0 * (1 + self.snapScalingThreshold)
                return (begin...end).contains(scale)
            }
            if let snapPoint = snapPoint, scale != snapPoint {
                if _virtualScale != snapPoint {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    _virtualScale = snapPoint
                }
            }else{
                _virtualScale = scale
            }
            
            //TODO: Update Node Scale here
            // update transform
            nodeScale = virtualScale
        }
    }

    /// ใช้สำหรับหมุนวัตถุในแกน Y
    public var virtualRotation: Float = 0 {
        didSet {
            yRotationControllerNode.eulerAngles.y = virtualRotation
        }
    }

    /// node จริงๆ ที่ถูก class นี้ห่อไว้
    public var contentNode: SCNNode? {
        didSet {
            oldValue?.removeFromParentNode()
            if let containNode = contentNode {
                containNode.removeFromParentNode()
                headNode <- containNode
                isLoaded = true
            }
        }
    }

    // Node graphs
    let yRotationControllerNode = SCNNode()
    let pivotYRotationControllerNode = SCNNode()
    let scaleControllerNode = SCNNode()
    let pivotScaleControllerNode = SCNNode()
    let headNode = SCNNode()

    /// Use average of recent virtual object distances to avoid rapid changes in object scale.
    private var recentVirtualObjectDistances: [Float] = []
    var startingDragVector: SCNVector3 = SCNVector3Zero
    var startingObjectVector: SCNVector3 = SCNVector3Zero
    var lastPanGesture: UIPanGestureRecognizer?

    // MARK: - Init/Deinit
    /// Initializes and returns Virtual Object
    ///
    public override init() {
        isLoaded = false
        super.init()
        setupNodeStructure()
    }

    // MARK: - Init/Deinit
    /// Initializes and returns Virtual Object
    ///
    /// - Parameters:
    ///   - containNode: Loaded SCNNode object
    ///   - allowAlignment: Aligment ที่สามารถวางได้
    public init(containNode: SCNNode,
                allowedAlignments: [ARPlaneAnchor.Alignment] = .all) {
        isLoaded = true
        super.init()
        self.allowedAlignments = allowedAlignments
        setupNodeStructure()
        self.contentNode = containNode
        headNode <- containNode
    }

    // MARK: - Init/Deinit
    /// Initializes and returns Virtual Object
    ///
    /// - Parameters:
    ///   - scene: SCNScene object
    ///   - allowAlignment: Aligment ที่สามารถวางได้
    public init(scene: SCNScene, allowedAlignments: [ARPlaneAnchor.Alignment] = .all) {
        isLoaded = true
        super.init()
        self.allowedAlignments = allowedAlignments
        setupNodeStructure()
        let node = scene.rootNode.clone()
        contentNode = node
        headNode <- node
    }

    /// Initializes and returns Virtual Object
    ///
    /// - Parameters:
    ///   - refferenceNode: SCNReferenceNode object
    ///   - allowAlignment: Aligment ที่สามารถวางได้
    public init(refferenceNode: SCNReferenceNode,
                allowedAlignments: [ARPlaneAnchor.Alignment] = .all) {
        isLoaded = false
        super.init()
        self.allowedAlignments = allowedAlignments
        setupNodeStructure()
        loadingType = .refferenceNode(refferenceNode)
    }

    /// Initializes and returns Virtual Object
    ///
    /// - Parameters:
    ///   - gltf: GLTFSceneSource object
    ///   - allowAlignment: Aligment ที่สามารถวางได้
    public init(gltfNamed: String,
                allowedAlignments: [ARPlaneAnchor.Alignment] = .all) {
        isLoaded = false
        super.init()
        self.allowedAlignments = allowedAlignments
        setupNodeStructure()
        loadingType = .gltf(.name(gltfNamed))
    }
    
    public init(gltfPath: String,
                allowedAlignments: [ARPlaneAnchor.Alignment] = .all) {
        isLoaded = false
        super.init()
        self.allowedAlignments = allowedAlignments
        setupNodeStructure()
        loadingType = .gltf(.path(gltfPath))
    }
    
    public init(gltfUrl: URL,
                allowedAlignments: [ARPlaneAnchor.Alignment] = .all) {
        isLoaded = false
        super.init()
        self.allowedAlignments = allowedAlignments
        setupNodeStructure()
        loadingType = .gltf(.url(gltfUrl))
    }

    /// Initializes and returns Virtual Object
    ///
    /// - Parameters:
    ///   - coder: Coder สำหรับ decode object
    required public init?(coder aDecoder: NSCoder) {
        isLoaded = false
        super.init(coder: aDecoder)
        setupNodeStructure()
    }
    
    deinit {
        loadingType = .none
    }
    
    func setupNodeStructure() {
        
        yRotationControllerNode.name        = "yRotationControllerNode"
        pivotYRotationControllerNode.name   = "pivotYRotationControllerNode"
        scaleControllerNode.name            = "scaleControllerNode"
        pivotScaleControllerNode.name       = "pivotScaleControllerNode"
        headNode.name                       = "headNode"

        self <- yRotationControllerNode
            <- pivotYRotationControllerNode
            <- scaleControllerNode
            <- pivotScaleControllerNode
            <- headNode
    }

    func load() {
        switch loadingType {
        case .gltf(let gltfSource):
            loadGLTF(gltfSource)
        case .refferenceNode(let refNode):
            refNode.load()
            contentNode = refNode
        default:
            break
        }
        loadingType = .none
    }
    
    func loadGLTF(_ sourceType: LoadingType.GLTFSourceType) {
        switch sourceType {
        case .name(let name):
            contentNode = try? GLTFSceneSource(named: name).scene().rootNode.clone()
        case .path(let path):
            contentNode = try? GLTFSceneSource(path: path).scene().rootNode.clone()
        case .url(let url):
            contentNode = try? GLTFSceneSource(url: url).scene().rootNode.clone()
        }
    }
    
    /// Reset all node trasform
    public func reset() {
        nodeScale = 1
        virtualScale = 1
        virtualRotation = 0
        
        transform                               = SCNMatrix4Identity
        scaleControllerNode.transform           = SCNMatrix4Identity
        pivotScaleControllerNode.transform      = SCNMatrix4Identity
        yRotationControllerNode.transform       = SCNMatrix4Identity
        pivotYRotationControllerNode.transform  = SCNMatrix4Identity
        headNode.transform                      = SCNMatrix4Identity
        
        loadingType = .none
    }

    var virtualTransform: SCNMatrix4 {
        get {
            return self.transform
        } set {
            self.transform = newValue
        }
    }

    /// Set Rotation to object from rotation gesture
     func setRotation(fromGesture gesture: UIRotationGestureRecognizer,
                            inSceneView sceneView: SCNView) {

        switch gesture.state {
        case .began:
            temporalyBeginRotationFactor = virtualRotation
        case .changed:
            virtualRotation = temporalyBeginRotationFactor - Float(gesture.rotation)
        default:
            break
        }
    }

    // Set scale to object from pinch gesture
     func setPinch(fromGesture gesture: UIPinchGestureRecognizer,
                         inSceneView sceneView: SCNView) {

        switch gesture.state {
        case .began:
            temporalyBeginPinchFactor = virtualScale
        case .changed:
            virtualScale = temporalyBeginPinchFactor * Float(gesture.scale)
        default:
            break
        }
    }

    /// - Tag: AdjustOntoPlaneAnchor
    func adjustOntoPlaneAnchor(_ anchor: ARPlaneAnchor,
                               using node: SCNNode) {
        // Test if the alignment of the plane is compatible with the object's allowed placement
        if !allowedAlignments.contains(anchor.alignment) && anchor.alignment != currentAlignment {
            return
        }

        // Get the object's position in the plane's coordinate system.
        let planePosition = node.convertPosition(position, from: parent)

        // Check that the object is not already on the plane.
        guard planePosition.y != 0 else { return }

        // Add 10% tolerance to the corners of the plane.
        let tolerance: Float = 0.1

        let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
        let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
        let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
        let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance

        guard (minX...maxX).contains(planePosition.x) && (minZ...maxZ).contains(planePosition.z) else {
            return
        }

        // Move onto the plane if it is near it (within 5 centimeters).
        let verticalAllowance: Float = 0.05
        let epsilon: Float = 0.001 // Do not update if the difference is less than 1 mm.
        let distanceToPlane = abs(planePosition.y)
        if distanceToPlane > epsilon && distanceToPlane < verticalAllowance {
            SceneKitAnimator.animateWithDuration(
                duration: CFTimeInterval(distanceToPlane * 500), // Move 2 mm per second.
                timingFunction: .easeInOut,
                animations: {
                    localTranslate(by: SCNVector3Make(0, -planePosition.y, 0))
                    updateAlignment(to: anchor.alignment, transform: simdWorldTransform, allowAnimation: false)
            })
        }
    }

    // MARK: - Setting the object's alignment

    var isChangingAlignment = false
    public var currentAlignment = ARPlaneAnchor.Alignment.horizontal
    /// Remember the last rotation for horizontal alignment
    var rotationWhenAlignedHorizontally: Float = 0

    func updateAlignment(to newAlignment: ARPlaneAnchor.Alignment,
                         transform: float4x4,
                         allowAnimation: Bool) {
        if isChangingAlignment {
            return
        }

        // Only animate if the alignment has changed.
        let animationDuration = (newAlignment != currentAlignment && allowAnimation) ? 0.5 : 0

        var newObjectRotation: Float?
        if newAlignment == .horizontal && currentAlignment != .horizontal {
            // When changing to horizontal placement, restore the previous horizontal rotation.
            newObjectRotation = rotationWhenAlignedHorizontally
        } else if newAlignment != .horizontal && currentAlignment == .horizontal {
            // When changing to vertical placement, reset the object's rotation (y-up).
            newObjectRotation = 0.0001
        }

        currentAlignment = newAlignment

        SCNTransaction.begin()
        SCNTransaction.animationDuration = animationDuration
        SCNTransaction.completionBlock = {
            self.isChangingAlignment = false
        }

        isChangingAlignment = true

        // Use the filtered position rather than the exact one from the transform.
        simdTransform = transform
        simdTransform.translation = simdWorldPosition

        if newObjectRotation != nil {
            virtualRotation = newObjectRotation!
        }

        SCNTransaction.commit()
    }

    /**
     Set the object's position based on the provided position relative to the `cameraTransform`.
     If `smoothMovement` is true, the new position will be averaged with previous position to
     avoid large jumps.

     - Tag: VirtualObjectSetPosition
     */
    public func setTransform(_ newTransform: float4x4,
                             relativeTo cameraTransform: float4x4,
                             smoothMovement: Bool,
                             alignment: ARPlaneAnchor.Alignment,
                             allowAnimation: Bool) {
        let cameraWorldPosition = cameraTransform.translation
        var positionOffsetFromCamera = newTransform.translation - cameraWorldPosition

        // Limit the distance of the object from the camera to a maximum of 10 meters.
        if simd_length(positionOffsetFromCamera) > 10 {
            positionOffsetFromCamera = simd_normalize(positionOffsetFromCamera)
            positionOffsetFromCamera *= 10
        }

        /*
         Compute the average distance of the object from the camera over the last ten
         updates. Notice that the distance is applied to the vector from
         the camera to the content, so it affects only the percieved distance to the
         object. Averaging does _not_ make the content "lag".
         */
        if smoothMovement {
            let hitTestResultDistance = simd_length(positionOffsetFromCamera)

            // Add the latest position and keep up to 10 recent distances to smooth with.
            recentVirtualObjectDistances.append(hitTestResultDistance)
            recentVirtualObjectDistances = Array(recentVirtualObjectDistances.suffix(10))

            let averageDistance = recentVirtualObjectDistances.average!
            let averagedDistancePosition = simd_normalize(positionOffsetFromCamera) * averageDistance
            simdPosition = cameraWorldPosition + averagedDistancePosition
        } else {
            simdPosition = cameraWorldPosition + positionOffsetFromCamera
        }

        if currentAlignment != alignment {
            currentAlignment = alignment
            updateAlignment(to: alignment, transform: newTransform, allowAnimation: allowAnimation)
        }
    }

    /// Custom Remove animation
    public func setAnimationForVirtualObjectRemoving(_ animation: @escaping ((SamMitiVirtualObject, @escaping VoidBlock) -> Void)) {
        self.animationForVirtualObjectRemoving = animation
    }

    var animationForVirtualObjectRemoving: ((SamMitiVirtualObject, @escaping VoidBlock) -> Void)?

    open override func removeFromParentNode() {
        if let removeAnimation = animationForVirtualObjectRemoving,
            let _ = parent {
            removeAnimation(self, super.removeFromParentNode)
        } else {
            super.removeFromParentNode()
        }
    }

}

public extension SCNReferenceNode {

    /// Helper สำหรับ init reference node จาก scene names
    convenience init?(named: String) {
        self.init(url: Bundle.main.bundleURL.appendingPathComponent(named))
    }
}

extension SCNNode {

    func partOfVirtualObject() -> SamMitiVirtualObject? {

        if self is SamMitiVirtualObject {
            return self as? SamMitiVirtualObject
        }

        if self.parent != nil {
            return self.parent!.partOfVirtualObject()
        }

        return nil
    }
}

extension Collection where Element == Float, Index == Int {
    /// Return the mean of a list of Floats. Used with `recentVirtualObjectDistances`.
    var average: Float? {
        guard !isEmpty else {
            return nil
        }

        let sum = reduce(Float(0)) { current, next -> Float in
            return current + next
        }

        return sum / Float(count)
    }
}

