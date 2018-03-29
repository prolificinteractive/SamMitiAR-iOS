//
//  SamMitiDelegateObject.swift
//  SamMitiAR
//
//  Created by Nattawut Singhchai on 1/2/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import ARKit

class SamMitiDelegateObject: NSObject, ARSCNViewDelegate, ARSessionDelegate {

    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.prolificinteractive.com.samMitiAR.serialSceneKitQueue")

    var showAnchorPlane = false

    weak var sceneView: SamMitiARView?

    var updateSession: ((_ frame: ARFrame, _ trackingState: ARCamera.TrackingState) -> Void)?

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSession?(frame, frame.camera.trackingState)
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSession?(frame, frame.camera.trackingState)
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSession?(session.currentFrame!, camera.trackingState)
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        updateSession?(session.currentFrame!, frame.camera.trackingState)
    }

    /// - Tag: PlaceARContent
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        updateQueue.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {

                self.sceneView?.placedVirtualObjects.forEach { $0.adjustOntoPlaneAnchor(planeAnchor, using: node) }

                // Place content only for anchors found by plane detection.
                if self.showAnchorPlane {
                    if #available(iOS 11.3, *) {
                        guard let device = MTLCreateSystemDefaultDevice(),
                            let anchorGeometry = ARSCNPlaneGeometry(device: device) else { return }
                        anchorGeometry.update(from: planeAnchor.geometry)
                        node.opacity = 0.25
                        node.geometry = anchorGeometry
                    } else {
                        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
                        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                             height: CGFloat(planeAnchor.extent.z))
                        let planeNode = SCNNode(geometry: plane)
                        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)

                        /*
                         `SCNPlane` is vertically oriented in its local coordinate space, so
                         rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
                         */
                        planeNode.eulerAngles.x = -.pi / 2

                        // Make the plane visualization semitransparent to clearly show real-world placement.
                        planeNode.opacity = 0.25

                        /*
                         Add the plane visualization to the ARKit-managed node so that it tracks
                         changes in the plane anchor as plane estimation continues.
                         */
                        node.addChildNode(planeNode)
                    }
                }
            } else {
                if let objectAtAnchor = self.sceneView?.placedVirtualObjects.first(where: { $0.anchor == anchor }) {
                    objectAtAnchor.simdPosition = anchor.transform.translation
                    objectAtAnchor.anchor = anchor
                }
            }
        }

    }

    /// - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        let weakSelf = self
        updateQueue.async {
            weakSelf.sceneView?.placedVirtualObjects.forEach { $0.adjustOntoPlaneAnchor(planeAnchor, using: node) }
        }

        if showAnchorPlane {
            if #available(iOS 11.3, *) {
                guard let anchorGeometry = node.geometry as? ARSCNPlaneGeometry else { return }
                anchorGeometry.update(from: planeAnchor.geometry)
            } else {
                // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
                guard let planeNode = node.childNodes.first,
                    let plane = planeNode.geometry as? SCNPlane
                    else { return }

                // Plane estimation may shift the center of a plane relative to its anchor's transform.
                planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)

                /*
                 Plane estimation may extend the size of the plane, or combine previously detected
                 planes into a larger one. In the latter case, `ARSCNView` automatically deletes the
                 corresponding node for one plane, then calls this method to update the size of
                 the remaining plane.
                 */
                plane.width = CGFloat(planeAnchor.extent.x)
                plane.height = CGFloat(planeAnchor.extent.z)
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.sceneView?.updateObjectToCurrentTrackingPosition()
        }
    }

}
