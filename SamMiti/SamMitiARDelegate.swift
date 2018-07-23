//
//  SamMitiARStateDelegate.swift
//  SamMiti
//
//  Created by Nattawut Singhchai on 15/2/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import Foundation
import ARKit

/// Method to track different event when AR Session gets called.
public protocol SamMitiARDelegate: class {
    
    /// Tells the delegate when AR session updates.
    ///
    /// - Parameters:
    ///   - frame: An object encapsulating the state of everything being tracked for a given moment in time.
    ///   - trackingState: A value describing the camera's tracking state.
    func updateSessionInfo(for frame: ARFrame, trackingState: ARCamera.TrackingState)
    
    /// Methods you can implement to receive new current tracking quality state.
    ///
    /// - Parameter trackingState: The general quality of position tracking available when the camera captured a frame.
    func trackingStateChanged(to trackingState: ARCamera.TrackingState)
    
    /// Methods you can implement to receive new current tracking quality state
    ///
    /// - Parameter trackingStateReason: Possible causes for limited position tracking quality.
    func trackingStateReasonChanged(to trackingStateReason: ARCamera.TrackingState.Reason?)
    
    /// Methods you can implement to receive current status of interaction.
    ///
    /// - Parameter interactionStatus: Status of possible interactions
    func interactionStatusChanged(to interactionStatus: SamMitiInteractionStatus)
    
    /// Method that allows to know the confident level that hittest changed.
    ///
    /// - Parameter confidentLevel: Levels of plane detecting confidence.
    func planeDetectingConfidentLevelChanged(to confidentLevel: PlaneDetectingConfidentLevel?)
    
    /// Method that allows to know when alignment of focus changed
    ///
    /// - Parameter alignement: Values describing possible general orientations of a detected plane with respect to gravity.
    func alignmentChanged(to alignement: ARPlaneAnchor.Alignment?)
    
    /// Method that allows to know when distance from the camera to the detected surface changed
    ///
    /// - Parameter distance: The distance, in meters, from the camera to the detected surface.
    func hitTestDistanceChanged(to distance: CGFloat?)
    
    /// Take an event as soon as the Virtual Object will be placed
    ///
    /// - Parameters:
    ///   - virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    ///   - transform: SceneKit uses matrices to represent coordinate space transformations.
    func samMitiViewWillPlace(_ virtualObject: SamMitiVirtualObject,
                                at transform: SCNMatrix4)
    
    /// Take an event as soon as the Virtual Object was placed
    ///
    /// - Parameter virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    func samMitiViewDidPlace(_ virtualObject: SamMitiVirtualObject)
    
    /// Take an event when the Virtual Object get tapped
    ///
    /// Note: If virtual object has not been recognized by this gesture, the virtual object property will return nil.
    ///
    /// - Parameter virtualObject:  An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    func samMitiViewDidTap(on virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get double tapped
    ///
    /// Note: If virtual object has not been recognized by this gesture, the virtual object property will return nil.
    ///
    /// - Parameter virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    func samMitiViewDidDoubleTap(on virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get long pressed
    ///
    /// - Parameter virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    func samMitiViewDidLongPress(on virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get rotated
    ///
    /// - Parameter virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    func samMitiViewWillBeginTranslating(virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object is translating
    ///
    /// - Parameter virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    func samMitiViewIsTranslating(virtualObject: SamMitiVirtualObject)
    
    /// Take an event when the Virtual Object get rotated
    ///
    /// - Parameter virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    func samMitiViewDidTranslate(virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get rotated
    ///
    /// Note: If virtual object has not been recognized by this gesture, the virtual object property will return nil.
    ///
    /// - Parameter virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    func samMitiViewWillBeginRotating(virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get rotated
    ///
    /// - Parameter virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    func samMitiViewIsRotating(virtualObject: SamMitiVirtualObject)
    
    /// Take an event when the Virtual Object get rotated
    ///
    /// - Parameter virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    func samMitiViewDidRotate(virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get pinched
    ///
    /// Note: If virtual object has not been recognized by this gesture, the virtual object property will return nil.
    ///
    /// - Parameter virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    func samMitiViewWillBeginPinching(virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get pinched
    ///
    /// - Parameter virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    func samMitiViewIsPinching(virtualObject: SamMitiVirtualObject)
    
    /// Take an event when the Virtual Object get pinched
    ///
    /// - Parameter virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    func samMitiViewDidPinch(virtualObject: SamMitiVirtualObject?)
    
    // MARK: - scaling events
    
    /// Take an event when virtual object is zooming and snapping to the defined size.
    ///
    /// - Parameters:
    ///   - virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    ///   - didSnappedToPoint: A float value that represent the current scale of virtual object.
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didSnapToScalingFactor scalingFactor: Float)
    
    /// Take an event when virtual object zoomed to the defined maximum or minimum bound.
    ///
    /// - Parameters:
    ///   - virtualObject: An Object that contains a set of SCNNodes representing different interaction functions and actual 3D content.
    ///   - didScaleToBound: A float value that represent the current scale of virtual object.
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didScaleToBound scalingFactor: Float)
}

//// Optional Protocol
public extension SamMitiARDelegate {
    
    func updateSessionInfo(for frame: ARFrame, trackingState: ARCamera.TrackingState) {}
    
    func trackingStateChanged(to trackingState: ARCamera.TrackingState) {}
    
    func trackingStateReasonChanged(to trackingStateReason: ARCamera.TrackingState.Reason?) {}
    
    func interactionStatusChanged(to interactionStatus: SamMitiInteractionStatus) {}
    
    func planeDetectingConfidentLevelChanged(to confidentLevel: PlaneDetectingConfidentLevel?) {}
    
    func alignmentChanged(to alignement: ARPlaneAnchor.Alignment?) {}
    
    func hitTestDistanceChanged(to distance: CGFloat?) {}
    
    func samMitiViewWillPlace(_ virtualObject: SamMitiVirtualObject, at transform: SCNMatrix4) {}
    
    func samMitiViewDidPlace(_ virtualObject: SamMitiVirtualObject) {}
    
    func samMitiViewDidTap(on virtualObject: SamMitiVirtualObject?) {}
    
    func samMitiViewDidDoubleTap(on virtualObject: SamMitiVirtualObject?) {}
    
    func samMitiViewDidLongPress(on virtualObject: SamMitiVirtualObject?) {}
    
    func samMitiViewWillBeginTranslating(virtualObject: SamMitiVirtualObject?) {}
    
    func samMitiViewIsTranslating(virtualObject: SamMitiVirtualObject) {}
    
    func samMitiViewDidTranslate(virtualObject: SamMitiVirtualObject?) {}
    
    func samMitiViewWillBeginRotating(virtualObject: SamMitiVirtualObject?) {}
    
    func samMitiViewIsRotating(virtualObject: SamMitiVirtualObject) {}
    
    func samMitiViewDidRotate(virtualObject: SamMitiVirtualObject?) {}
    
    func samMitiViewWillBeginPinching(virtualObject: SamMitiVirtualObject?) {}
    
    func samMitiViewIsPinching(virtualObject: SamMitiVirtualObject) {}
    
    func samMitiViewDidPinch(virtualObject: SamMitiVirtualObject?) {}
    
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didSnapToScalingFactor scalingFactor: Float) {}
    
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didScaleToBound scalingFactor: Float) {}
    
}

