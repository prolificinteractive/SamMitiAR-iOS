//
//  SamMitiARStateDelegate.swift
//  SamMiti
//
//  Created by Nattawut Singhchai on 15/2/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import Foundation
import ARKit

// ใช้สำหรับ track ค่า event ต่างๆ ที่เกิดขึ้นในขณะเกิด AR Session

public protocol SamMitiARDelegate: class {
    
    /// เอาไว้ใช้สำหรับอ่านค่า ARFrame ในทุก ๆ frame
    ///
    /// frame: An object encapsulating the state of everything being tracked for a given moment in time.
    /// trackingState: A value describing the camera's tracking state.
    func updateSessionInfo(for frame: ARFrame, trackingState: ARCamera.TrackingState)
    
    /// Methods you can implement to receive new current tracking quality state
    func trackingStateChanged(to trackingState: SamMitiTrackingState)
    
    /// Methods you can implement to receive new current tracking quality state
    func trackingStateReasonChanged(to trackingStateReason: ARCamera.TrackingState.Reason?)
    
    /// Methods you can implement to receive current status of interaction
    func interactionStatusChanged(to interactionStatus: SamMitiInteractionStatus)
    
    /// เอาไว้เช็คว่า ปัจจุบัน focus node ที่เห็นอยู่ ระดับความ confident อยู่ระดับไหน
    func planeDetectingConfidentLevelChanged(to confidentLevel: PlaneDetectingConfidentLevel?)
    
    /// เช็คว่ามีการเปลี่ยนแปลงของค่า alignment ของ focus node อย่างไร
    func alignmentChanged(to alignement: ARPlaneAnchor.Alignment?)
    
    /// เอาไว้วัดระยะทางจากกล้องถึง focus node
    func hitTestDistanceChanged(to distance: CGFloat?)
    
    /// Take an event as soon as the Virtual Object will be placed
    func samMitiViewWillPlace(_ virtualObject: SamMitiVirtualObject,
                                at transform: SCNMatrix4)
    
    /// Take an event as soon as the Virtual Object was placed
    func samMitiViewDidPlace(_ virtualObject: SamMitiVirtualObject)
    
    /// Take an event when the Virtual Object get tapped
    ///
    /// Note: If virtual object has not been recognized by this gesture, the virtual object property will return nil.
    func samMitiViewDidTap(on virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get double tapped
    ///
    /// Note: If virtual object has not been recognized by this gesture, the virtual object property will return nil.
    func samMitiViewDidDoubleTap(on virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get long pressed
    ///
    /// Note: If virtual object has not been recognized by this gesture, the virtual object property will return nil.
    func samMitiViewDidLongPress(on virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get rotated
    ///
    /// Note: If virtual object has not been recognized by this gesture, the virtual object property will return nil.
    func samMitiViewWillBeginTranslating(virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object is translating
    func samMitiViewIsTranslating(virtualObject: SamMitiVirtualObject)
    
    /// Take an event when the Virtual Object get rotated
    func samMitiViewDidTranslate(virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get rotated
    ///
    /// Note: If virtual object has not been recognized by this gesture, the virtual object property will return nil.
    func samMitiViewWillBeginRotating(virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get rotated
    func samMitiViewIsRotating(virtualObject: SamMitiVirtualObject)
    
    /// Take an event when the Virtual Object get rotated
    func samMitiViewDidRotate(virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get pinched
    ///
    /// Note: If virtual object has not been recognized by this gesture, the virtual object property will return nil.
    func samMitiViewWillBeginPinching(virtualObject: SamMitiVirtualObject?)
    
    /// Take an event when the Virtual Object get pinched
    func samMitiViewIsPinching(virtualObject: SamMitiVirtualObject)
    
    /// Take an event when the Virtual Object get pinched
    func samMitiViewDidPinch(virtualObject: SamMitiVirtualObject?)
    
    // scaling events
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didSnappedToPoint: Float)
    
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didScaleToBound: Float)
}

//// Optional Protocol
public extension SamMitiARDelegate {
    
    func updateSessionInfo(for frame: ARFrame, trackingState: ARCamera.TrackingState) {}
    
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
    
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didSnappedToPoint: Float) {}
    
    func samMitiVirtualObject(_ virtualObject: SamMitiVirtualObject, didScaleToBound: Float) {}
    
}

