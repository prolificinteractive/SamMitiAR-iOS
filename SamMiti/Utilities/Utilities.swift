/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility functions and type extensions used throughout the projects.
*/

import Foundation
import ARKit

// MARK: - float4x4 extensions

public extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
    */
    var translation: float3 {
		get {
			let translation = columns.3
			return float3(translation.x, translation.y, translation.z)
		}
		set(newValue) {
            columns.3 = float4(newValue.x, newValue.y, newValue.z, columns.3.w)
		}
    }
	
	/**
	 Factors out the orientation component of the transform.
    */
	var orientation: simd_quatf {
		return simd_quaternion(self)
	}
	
    /**
     Creates a transform matrix with a uniform scale factor in all directions.
     */
    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
}

// MARK: - CGPoint extensions

public extension CGPoint {
    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
	init(_ vector: SCNVector3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
	}

    /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
    var length: CGFloat {
		return sqrt(x * x + y * y)
	}
}

// Fallback for non iOS 12
open class SamMitiARConfiguration: ARConfiguration {
    
    /**
     Enum constants for indicating the mode of environment texturing to run.
     */
    public enum EnvironmentTexturing : Int {
        
        
        /** No texture information is gathered. */
        case none
        
        
        /** Texture information is gathered for the environment.
         Environment textures will be generated for AREnvironmentProbes added to the session. */
        case manual
        
        
        /** Texture information is gathered for the environment and probes automatically placed in the scene. */
        case automatic
    }
}

@available(iOS 12.0, *)
extension ARWorldTrackingConfiguration.EnvironmentTexturing {
    
    // TODO: ถึง Wut ดูให้หน่อย
    public func definedBy(_ environmentTexturing: SamMitiARConfiguration.EnvironmentTexturing) -> ARWorldTrackingConfiguration.EnvironmentTexturing {
        switch environmentTexturing {
        case .none:
            return .none
        case .manual:
            return .manual
        case .automatic:
            return .automatic
        }
    }
}


extension ARWorldTrackingConfiguration.PlaneDetection {
    public static var all: ARWorldTrackingConfiguration.PlaneDetection {
        return [.horizontal, .vertical]
    }
}

extension Array where Element == ARPlaneAnchor.Alignment {
    public static let all: [ARPlaneAnchor.Alignment] = [.horizontal, .vertical]
}

// SCNNode(addChildNode:)
infix operator <- : AssignmentPrecedence

@discardableResult
public func <- (left: SCNNode, right: SCNNode) -> SCNNode {
    left.addChildNode(right)
    return left
}
