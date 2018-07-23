//
//  SamMitiPlaneDetecting.swift
//  SamMiti
//
//  Created by Nattawut Singhchai on 15/2/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import ARKit


/// Levels of plane detecting confidence
///
/// - notFound: Found no plane or surface.
/// - estimated: Found a real-world planar surface.
/// - existing: Found a real-world plane.
public enum PlaneDetectingConfidentLevel: Int {
    case notFound
    case estimated
    case existing
}

public struct SamMitiPlaneDetecting {

    /// Current plane detecting confident level
    public internal(set) var currentPlaneDetectingConfidentLevel: PlaneDetectingConfidentLevel? = nil

    /// Current alignment
    public internal(set) var currentAlignment: ARPlaneAnchor.Alignment? = nil

    /// Reset current plane detecting confident level to nil
    public mutating func reset() {
        currentPlaneDetectingConfidentLevel = nil
    }
}
