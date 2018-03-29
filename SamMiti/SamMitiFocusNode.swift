//
//  FocusNode.swift
//  SamMitiAR
//
//  Created by Nattawut Singhchai on 2/2/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import SceneKit
import GLTFSceneKit
import ARKit

public class SamMitiFocusNode: SCNNode {

    private struct Constant {

        struct defaultFocusNodePaths {
            private static let artScnAssetsName = "SamMitiArt.scnassets"
            static let notFoundPath = defaultFocusNodePaths.artScnAssetsName + "/defaultFocusNotFound.scn"
            static let estimatedPath = defaultFocusNodePaths.artScnAssetsName + "/defaultFocusEstimated.scn"
            static let existingPath = defaultFocusNodePaths.artScnAssetsName + "/defaultFocusExisting.scn"
        }

        struct key {
            struct pulsing {
                static let fadeAnimation = "pulsingFadeAnimation"
                static let scaleAnimation = "pulsingScaleAnimation"
            }
            static let opacity = "opacity"
            static let transform = "transform"
        }

    }

    // MARK: - Types

    enum State: Equatable {
        case initializing
        case detecting(hitTestResult: ARHitTestResult, camera: ARCamera?)
    }

    // ชื่อเฉพาะสำหรับอธิบายลักษณะการแสดงของ Focus Node
    enum StatusAppearance {
        case complete
        case partial
        case none
    }

    /// The most recent position of the focus square based on the current state.
    var lastPosition: float3? {
        switch state {
        case .initializing: return nil
        case .detecting(let hitTestResult, _): return hitTestResult.worldTransform.translation
        }
    }

    var state: State = .initializing {
        didSet {
            guard state != oldValue else { return }

            switch state {
            case .initializing:
                //TODO: สร้างฟังก์ชั่นให้เปิดหรือปิด Billboard ของ FocusNode ได้
//                displayAsBillboard()
                break

            case let .detecting(hitTestResult, camera):
                if let planeAnchor = hitTestResult.anchor as? ARPlaneAnchor {
                    anchorsOfVisitedPlanes.insert(planeAnchor)
                    currentPlaneAnchor = planeAnchor
                } else {
                    currentPlaneAnchor = nil
                }
                let position = hitTestResult.worldTransform.translation
                recentFocusSquarePositions.append(position)
                updateTransform(for: position, hitTestResult: hitTestResult, camera: camera)
            }
        }
    }

    /// The current appearance of focus node
    private var statusAppearance: StatusAppearance = .none

    /// Indicates whether the segments of the focus square are disconnected.
    private var isOpen = false

    /// Indicates if the square is currently being animated.
    private var isAnimating = false

    /// Indicates if the square is currently changing its alignment.
    private var isChangingAlignment = false

    /// The focus current alignment.
    public var currentAlignment: ARPlaneAnchor.Alignment?

    /// The current plane anchor if the focus square is on a plane.
    private(set) var currentPlaneAnchor: ARPlaneAnchor?

    /// The focus square's most recent positions.
    private var recentFocusSquarePositions: [float3] = []

    /// The focus square's most recent alignments.
    private(set) var recentFocusSquareAlignments: [ARPlaneAnchor.Alignment] = []

    /// Previously visited plane anchors.
    private var anchorsOfVisitedPlanes: Set<ARAnchor> = []

    /// The primary node that controls the position of other `FocusSquare` nodes.
    private let positioningNode = SCNNode()

    /// The node that control the size for pulsing animation
    private let scalingNode = SCNNode()

    /// The content primary node for carrying all focus childen nodes
    private var focusNode: SCNNode!

    /// The template node for Not Found confident level
    private var focusNotFoundTemplateNode: SCNNode!

    /// The template node for Estimated confident level
    private var focusEstimatedTemplateNode: SCNNode!

    /// The template node for Existing confident level
    private var focusExistingTemplateNode: SCNNode!

    public var currentPlaneDetectingConfidentLevel: PlaneDetectingConfidentLevel? = nil {
        didSet {
            if currentPlaneDetectingConfidentLevel != oldValue {
                setState(confidentLevel: currentPlaneDetectingConfidentLevel)
            }
        }
    }

    // MARK: - Init/Deinit
    /// Initializes and returns an Focus Node with given parameters.
    ///

    public override init() {
        super.init()
        setup()
    }

    /// Initializes and returns an Focus Node with given parameters.
    ///
    /// notFound: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = notFound
    /// estimated: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = estimated
    /// existing: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = existing
    public init(withNotFoundNamed notFoundNamed: String,
                estimatedNamed: String,
                existingNamed: String) {
        super.init()
        setup(withNotFoundNamed: notFoundNamed, estimatedNamed: estimatedNamed, existingNamed: existingNamed)
    }
    
    /// Initializes and returns an Focus Node with given parameters.
    ///
    /// notFound: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = notFound
    /// estimated: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = estimated
    /// existing: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = existing
    public init(fromNotFoundPath notFoundPath: String,
                estimatedPath: String,
                existingPath: String) {
        super.init()
        setup(fromNotFoundPath: notFoundPath, estimatedPath: estimatedPath, existingPath: existingPath)
    }
    /// Initializes and returns an Focus Node with given parameters.
    ///
    /// notFound: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = notFound
    /// estimated: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = estimated
    /// existing: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = existing
    public init(withNotFoundGLTFNamed notFoundGLTFNamed: String,
                estimatedGLTFNamed: String,
                existingGLTFNamed: String) {
        super.init()
        setup(withNotFoundGLTFNamed: notFoundGLTFNamed, estimatedGLTFNamed: estimatedGLTFNamed, existingGLTFNamed: existingGLTFNamed)
    }
    
    /// Initializes and returns an Focus Node with given parameters.
    ///
    /// notFound: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = notFound
    /// estimated: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = estimated
    /// existing: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = existing
    public init(fromNotFoundGLTFPath notFoundGLTFPath: String,
                estimatedGLTFPath: String,
                existingGLTFPath: String) {
        super.init()
        setup(fromNotFoundGLTFPath: notFoundGLTFPath, estimatedGLTFPath: estimatedGLTFPath, existingGLTFPath: existingGLTFPath)
    }
    
    /// Initializes and returns an Focus Node with given parameters.
    ///
    /// notFound: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = notFound
    /// estimated: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = estimated
    /// existing: ชื่อของ *.scn file ใน main bundle ที่จะนำมาแสดงตอน state = existing
    public init(fromNotFoundGLTFUrl notFoundGLTFUrl: URL,
                estimatedGLTFUrl: URL,
                existingGLTFUrl: URL) {
        super.init()
        setup(fromNotFoundGLTFUrl: notFoundGLTFUrl, estimatedGLTFUrl: estimatedGLTFUrl, existingGLTFUrl: existingGLTFUrl)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func node(withNamed name: String?) -> SCNNode? {
        // escaping for default template node
        guard let name = name else { return nil }
        let node = SCNReferenceNode(named: name)
        node?.load()
        return node
    }

    private func node(fromPath path: String) -> SCNNode? {
        guard let url = Bundle(for: type(of: self)).resourceURL?.appendingPathComponent(path) else { return nil }
        let node = SCNReferenceNode(url: url)
        node?.load()
        return node
    }
    
    func node(withGLTFNamed name: String) -> SCNNode? {
        return try? GLTFSceneSource(named: name).scene().rootNode.clone()
    }
    
    func node(fromGLTFPath path: String) -> SCNNode? {
        return try? GLTFSceneSource(path: path).scene().rootNode.clone()
    }
    
    func node(fromGLTFUrl url: URL) -> SCNNode? {
        return try? GLTFSceneSource(url: url).scene().rootNode.clone()
    }
    
    func setup(withNotFoundNamed notFoundNamed: String,
               estimatedNamed: String,
               existingNamed: String) {

        /// Getting all template node from external files
        setup(withNotFoundNode: node(withNamed: notFoundNamed),
              estimatedNode: node(withNamed: estimatedNamed),
              existingNode: node(withNamed: existingNamed))
    }
    
    func setup(fromNotFoundPath notFoundPath: String,
               estimatedPath: String,
               existingPath: String) {
        
        /// Getting all template node from external files
        setup(withNotFoundNode: node(fromPath: notFoundPath),
              estimatedNode: node(fromPath: estimatedPath),
              existingNode: node(fromPath: existingPath))
    }
    
    func setup(withNotFoundGLTFNamed notFoundGLTFNamed: String,
               estimatedGLTFNamed: String,
               existingGLTFNamed: String) {
        
        /// Getting all template node from external files
        setup(withNotFoundNode: node(withGLTFNamed: notFoundGLTFNamed),
              estimatedNode: node(withGLTFNamed: estimatedGLTFNamed),
              existingNode: node(withGLTFNamed: existingGLTFNamed))
    }
    
    func setup(fromNotFoundGLTFPath notFoundGLTFPath: String,
               estimatedGLTFPath: String,
               existingGLTFPath: String) {
        
        /// Getting all template node from external files
        setup(withNotFoundNode: node(fromGLTFPath: notFoundGLTFPath),
              estimatedNode: node(fromGLTFPath: estimatedGLTFPath),
              existingNode: node(fromGLTFPath: existingGLTFPath))
    }
    
    func setup(fromNotFoundGLTFUrl notFoundGLTFUrl: URL,
               estimatedGLTFUrl: URL,
               existingGLTFUrl: URL) {
        
        /// Getting all template node from external files
        setup(withNotFoundNode: node(fromGLTFUrl: notFoundGLTFUrl),
              estimatedNode: node(fromGLTFUrl: estimatedGLTFUrl),
              existingNode: node(fromGLTFUrl: existingGLTFUrl))
    }
    
    func validateFocusNodeLoading(withNotFoundNode notFoundNode: SCNNode?,
                                  estimatedNode: SCNNode?,
                                  existingNode: SCNNode?) -> Bool {
        
        guard let notFoundNode = notFoundNode,
            let estimatedNode = estimatedNode,
            let existingNode = existingNode else {
                return false
        }
        
        var estimatedChildNodeNames: [String] = []
        var existingChildNodeNames: [String] = []
        
        
        estimatedNode.childNodes.forEach { (childNode) in
            estimatedChildNodeNames.append(childNode.name ?? "<undefined>")
        }
        
        existingNode.childNodes.forEach { (childNode) in
            existingChildNodeNames.append(childNode.name ?? "<undefined>")
        }
        
        for childNode in notFoundNode.childNodes {
            let nodeName = childNode.name ?? "<undefined>"
            if !estimatedChildNodeNames.contains(nodeName) || !existingChildNodeNames.contains(nodeName) {
                return false
            }
        }
        
        return true
    }
    
    func setup(withNotFoundNode notFoundNode: SCNNode? = nil,
               estimatedNode: SCNNode? = nil,
               existingNode: SCNNode? = nil) {
        
        if validateFocusNodeLoading(withNotFoundNode: notFoundNode, estimatedNode: estimatedNode, existingNode: existingNode) {
            /// Getting all template node from external files
            focusNotFoundTemplateNode = notFoundNode ?? node(fromPath: Constant.defaultFocusNodePaths.notFoundPath)
            focusEstimatedTemplateNode = estimatedNode ?? node(fromPath: Constant.defaultFocusNodePaths.estimatedPath)
            focusExistingTemplateNode = existingNode ?? node(fromPath: Constant.defaultFocusNodePaths.existingPath)
            
        } else {
            /// Getting all template node from external files
            focusNotFoundTemplateNode = node(fromPath: Constant.defaultFocusNodePaths.notFoundPath)
            focusEstimatedTemplateNode = node(fromPath: Constant.defaultFocusNodePaths.estimatedPath)
            focusExistingTemplateNode = node(fromPath: Constant.defaultFocusNodePaths.existingPath)
        }
        
        focusNode = focusNotFoundTemplateNode
        
        addChildNode(scalingNode)
        scalingNode.addChildNode(focusNode)
        
        for focusChildNode in focusNode.childNodes {
            let morpher = SCNMorpher()
            guard let childNodeName = focusChildNode.name,
            let focusEstimatedTemplateGeometry = focusEstimatedTemplateNode.geometryWith(name: childNodeName),
            let focusExistingTemplateGeometry = focusExistingTemplateNode.geometryWith(name: childNodeName) else { return }
            morpher.targets = [focusEstimatedTemplateGeometry,
                               focusExistingTemplateGeometry]
            focusChildNode.morpher = morpher
        }
        
        displayNodeHierarchyOnTop(true)
        
    }

    func setState(confidentLevel: PlaneDetectingConfidentLevel?) {
        OperationQueue.main.addOperation {
            self.focusNode.isHidden = false
            self.update(forPlaneDetectingConfidentLevel: confidentLevel)
        }
    }

    private func updateNodeProperties(of node: SCNNode, from templateNode: SCNNode) {
        node.opacity = templateNode.opacity
        node.transform = templateNode.transform
        guard let templateFirstMaterial = templateNode.geometry?.firstMaterial else { return }
        node.geometry?.firstMaterial?.diffuse.contents = templateNode.geometry?.firstMaterial?.diffuse.contents
        node.geometry?.firstMaterial?.diffuse.intensity = templateFirstMaterial.diffuse.intensity
        node.geometry?.firstMaterial?.transparency = templateFirstMaterial.transparency
    }

    func update(forPlaneDetectingConfidentLevel confidentLevel: PlaneDetectingConfidentLevel?) {
        guard let confidentLevel = confidentLevel else {
            self.update(forStatusAppearance: .none)
            return
        }
        switch confidentLevel {
        case .existing:
            self.update(forStatusAppearance: .complete)
        case .estimated:
            self.update(forStatusAppearance: .partial)
        default:
            self.update(forStatusAppearance: .none)
        }
    }

    private func update(forStatusAppearance statusAppearance: StatusAppearance) {
        SceneKitAnimator.animateWithDuration(duration: 0.35 / 2.0, timingFunction: .easeInOut, animations: {
            self.willUpdate(forStatusAppearance: statusAppearance)
        }, completion: {
            self.didUpdate(forStatusAppearance: statusAppearance)
        })
    }

    fileprivate func extractedFunc(_ statusAppearance: StatusAppearance) {
        setFocusNode(withPulsing: statusAppearance == .partial)
    }

    private func willUpdate(forStatusAppearance statusAppearance: StatusAppearance) {
        focusNode.childNodes.forEach {
            switch statusAppearance {
            case .complete:
                $0.morpher?.setWeight(0, forTargetAt: 0)
                $0.morpher?.setWeight(1, forTargetAt: 1)

                guard let templateNode = focusExistingTemplateNode.childNode(withName: $0.name!, recursively: true) else { return }
                updateNodeProperties(of: $0, from: templateNode)

            case .partial:
                $0.morpher?.setWeight(1, forTargetAt: 0)
                $0.morpher?.setWeight(0, forTargetAt: 1)

                guard let templateNode = focusEstimatedTemplateNode.childNode(withName: $0.name!, recursively: true) else { return }
                updateNodeProperties(of: $0, from: templateNode)

            case .none:
                $0.morpher?.setWeight(0, forTargetAt: 0)
                $0.morpher?.setWeight(0, forTargetAt: 1)

                guard let templateNode = focusNotFoundTemplateNode.childNode(withName: $0.name!, recursively: true) else { return }
                updateNodeProperties(of: $0, from: templateNode)
            }
        }
    }

    private func didUpdate(forStatusAppearance statusAppearance: StatusAppearance) {
        let nodes = focusNode.childNodes
        switch statusAppearance {
        case .complete:
            nodes.forEach { $0.isHidden = false }
        case .partial:
            nodes.forEach { $0.isHidden = false }
        case .none:
            nodes.forEach { $0.isHidden = true }
        }
    }

    func removePulsingAnimation() {
        removeAnimation(forKey: Constant.key.pulsing.fadeAnimation)
        scalingNode.removeAnimation(forKey: Constant.key.pulsing.scaleAnimation)
    }

    func setFocusNode(withPulsing willPulse: Bool) {
        removePulsingAnimation()

        if willPulse {

            let fadeAnimation = CABasicAnimation(keyPath: Constant.key.opacity)
            fadeAnimation.fromValue = 1
            fadeAnimation.toValue = 1
            fadeAnimation.timingFunction = .default
            fadeAnimation.duration = 1
            fadeAnimation.autoreverses = true
            fadeAnimation.repeatCount = HUGE
            addAnimation(fadeAnimation, forKey: Constant.key.pulsing.fadeAnimation)

            let scaleAnimation = CABasicAnimation(keyPath: Constant.key.transform)
            scaleAnimation.fromValue = SCNMatrix4MakeScale(1, 1, 1)
            scaleAnimation.toValue = SCNMatrix4MakeScale(1.1, 1.1, 1.1)
            scaleAnimation.timingFunction = .default
            scaleAnimation.duration = 1
            scaleAnimation.autoreverses = true
            scaleAnimation.repeatCount = HUGE
            scalingNode.addAnimation(scaleAnimation, forKey: Constant.key.pulsing.scaleAnimation)

        }
    }

    public func reset() {
        currentPlaneDetectingConfidentLevel = .notFound
        removePulsingAnimation()
    }

    // MARK: - Appearance
    var willHide = false {
        didSet {
            if oldValue != willHide {
                if willHide {
                    hide()
                } else {
                    unhide()
                }
            }
        }
    }

    /// Hides the focus square.
    func hide() {
        update(forStatusAppearance: .none)
    }

    /// Unhides the focus square.
    func unhide() {
        update(forPlaneDetectingConfidentLevel: currentPlaneDetectingConfidentLevel)
    }

    /// Displays the focus square parallel to the camera plane.
    private func displayAsBillboard() {
        simdTransform = matrix_identity_float4x4
        eulerAngles.x = .pi / 2
        simdPosition = float3(0, 0, -0.8)
        unhide()
    }

    // MARK: Helper Methods

    /// Update the transform of the focus square to be aligned with the camera.
    private func updateTransform(for position: float3, hitTestResult: ARHitTestResult, camera: ARCamera?) {
        // Average using several most recent positions.
        recentFocusSquarePositions = Array(recentFocusSquarePositions.suffix(10))

        // Move to average of recent positions to avoid jitter.
        let average = recentFocusSquarePositions.reduce(float3(0), { $0 + $1 }) / Float(recentFocusSquarePositions.count)
        self.simdPosition = average
        self.simdScale = float3(scaleBasedOnDistance(camera: camera))

        // Correct y rotation of camera square.
        guard let camera = camera else { return }
        let tilt = abs(camera.eulerAngles.x)
        let threshold1: Float = .pi / 2 * 0.65
        let threshold2: Float = .pi / 2 * 0.75
        let yaw = atan2f(camera.transform.columns.0.x, camera.transform.columns.1.x)
        var angle: Float = 0

        switch tilt {
        case 0..<threshold1:
            angle = camera.eulerAngles.y

        case threshold1..<threshold2:
            let relativeInRange = abs((tilt - threshold1) / (threshold2 - threshold1))
            let normalizedY = normalize(camera.eulerAngles.y, forMinimalRotationTo: yaw)
            angle = normalizedY * (1 - relativeInRange) + yaw * relativeInRange

        default:
            angle = yaw
        }

        if state != .initializing {
            updateAlignment(for: hitTestResult, yRotationAngle: angle)
        }
    }

    private func updateAlignment(for hitTestResult: ARHitTestResult,
                                 yRotationAngle angle: Float) {
        // Abort if an animation is currently in progress.
        if isChangingAlignment {
            return
        }

        var shouldAnimateAlignmentChange = false

        let tempNode = SCNNode()
        tempNode.simdRotation = float4(0, 1, 0, angle)

        // Determine current alignment
        var alignment: ARPlaneAnchor.Alignment?
        if #available(iOS 11.3, *) {
            if let planeAnchor = hitTestResult.anchor as? ARPlaneAnchor {
                alignment = planeAnchor.alignment
            } else if hitTestResult.type == .estimatedHorizontalPlane {
                alignment = .horizontal
            } else if hitTestResult.type == .estimatedVerticalPlane {
                alignment = .vertical
            }
        } else {
            if let planeAnchor = hitTestResult.anchor as? ARPlaneAnchor {
                alignment = planeAnchor.alignment
            } else if hitTestResult.type == .estimatedHorizontalPlane {
                alignment = .horizontal
            }
        }

        // add to list of recent alignments
        if alignment != nil {
            recentFocusSquareAlignments.append(alignment!)
        }

        // Average using several most recent alignments.
        recentFocusSquareAlignments = Array(recentFocusSquareAlignments.suffix(20))

        let horizontalHistory = recentFocusSquareAlignments.filter({ $0 == .horizontal }).count

        // Alignment is same as most of the history - change it
        if #available(iOS 11.3, *) {
            let verticalHistory = recentFocusSquareAlignments.filter({ $0 == .vertical }).count

            if alignment == .horizontal && horizontalHistory > 15 ||
                alignment == .vertical && verticalHistory > 10 ||
                hitTestResult.anchor is ARPlaneAnchor {
                if alignment != currentAlignment {
                    shouldAnimateAlignmentChange = true
                    currentAlignment = alignment
                    recentFocusSquareAlignments.removeAll()
                }
            } else {
                // Alignment is different than most of the history - ignore it
                alignment = currentAlignment
                return
            }
        } else {
            if alignment == .horizontal && horizontalHistory > 15 ||
                hitTestResult.anchor is ARPlaneAnchor {
                if alignment != currentAlignment {
                    shouldAnimateAlignmentChange = true
                    currentAlignment = alignment
                    recentFocusSquareAlignments.removeAll()
                }
            } else {
                // Alignment is different than most of the history - ignore it
                alignment = currentAlignment
                return
            }
        }

        if #available(iOS 11.3, *) {
            if alignment == .vertical {
                tempNode.simdOrientation = hitTestResult.worldTransform.orientation
                shouldAnimateAlignmentChange = true
            }
        }

        // Change the focus square's alignment
        if shouldAnimateAlignmentChange {
            performAlignmentAnimation(to: tempNode.simdOrientation)
        } else {
            simdOrientation = tempNode.simdOrientation
        }
    }

    private func normalize(_ angle: Float, forMinimalRotationTo ref: Float) -> Float {
        // Normalize angle in steps of 90 degrees such that the rotation to the other angle is minimal
        var normalized = angle
        while abs(normalized - ref) > .pi / 4 {
            if angle > ref {
                normalized -= .pi / 2
            } else {
                normalized += .pi / 2
            }
        }
        return normalized
    }

    /**
     Reduce visual size change with distance by scaling up when close and down when far away.

     These adjustments result in a scale of 1.0x for a distance of 0.7 m or less
     (estimated distance when looking at a table), and a scale of 1.2x
     for a distance 1.5 m distance (estimated distance when looking at the floor).
     */
    private func scaleBasedOnDistance(camera: ARCamera?) -> Float {
        guard let camera = camera else { return 1.0 }

        let distanceFromCamera = simd_length(simdWorldPosition - camera.transform.translation)
        if distanceFromCamera < 0.7 {
            return distanceFromCamera / 0.7
        } else {
            return 0.25 * distanceFromCamera + 0.825
        }
    }

    // MARK: Animations

    private func performAlignmentAnimation(to newOrientation: simd_quatf) {
        isChangingAlignment = true
        SCNTransaction.begin()
        SCNTransaction.completionBlock = {
            self.isChangingAlignment = false
        }
        SCNTransaction.animationDuration = 0.5
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        simdOrientation = newOrientation
        SCNTransaction.commit()
    }

    /// Sets the rendering order of the `positioningNode` to show on top or under other scene content.
    func displayNodeHierarchyOnTop(_ isOnTop: Bool) {
        // Recursivley traverses the node's children to update the rendering order depending on the `isOnTop` parameter.
        func updateRenderOrder(for node: SCNNode) {
            
            node.renderingOrder = isOnTop ? -1 : 0

            for material in node.geometry?.materials ?? [] {
                material.readsFromDepthBuffer = !isOnTop
            }

            for child in node.childNodes {
                updateRenderOrder(for: child)
            }
        }

        updateRenderOrder(for: focusNode)
    }
}

// Helpers

extension SCNNode {
    func geometryWith(name: String) -> SCNGeometry? {
        return childNode(withName: name, recursively: true)?.geometry
    }
}
