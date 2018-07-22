//
//  SamMitiVitualObjectLoader.swift
//  SamMiti
//
//  Created by Nattawut Singhchai on 9/2/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import UIKit

// ใช้สำหรับ load virtualObject ก่อนจะถูกส่งไปที่ Scene
public class SamMitiVitualObjectLoader: NSObject {

    /// virtual objects ที่ถูกเพิ่มเข้ามา
    public private(set) var objects: [SamMitiVirtualObject] = []

    public private(set) var isLoading = false

    // MARK: - Loading object

    /**
     Loads a `VirtualObject` on a background queue. `loadedHandler` is invoked
     on a background queue once `object` has been loaded.
     */
    public func loadVirtualObject(_ object: SamMitiVirtualObject,
                                  loadedHandler: ((SamMitiVirtualObject) -> Void)? = nil) {
        isLoading = true
        objects.append(object)

        // Load the content asynchronously.
        DispatchQueue.global(qos: .userInitiated).async {
            object.load()
            self.isLoading = false
            DispatchQueue.main.sync {
                loadedHandler?(object)
            }
        }
    }

    // MARK: - Removing Objects

    public func removeAllVirtualObjects() {
        // Reverse the indices so we don't trample over indices as objects are removed.
        for index in objects.indices.reversed() {
            removeVirtualObject(at: index)
        }
    }

    // remove virtualObject at index
    public func removeVirtualObject(at index: Int) {
        guard objects.indices.contains(index) else { return }

        objects[index].removeFromParentNode()
        objects.remove(at: index)
    }

    // remove virtualObject (if exist)
    public func remove(_ object: SamMitiVirtualObject) {
        guard objects.contains(object) else { return }
        object.removeFromParentNode()
        objects.remove(at: objects.index(of: object)!)
    }
    
    // Set all texture maps to nil to release the memory
    private func removeAllTextureMaps(of object: SamMitiVirtualObject) {
        object.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry {
                for material in geometry.materials {
                    
                    /// Visual Properties for Physically Based Shading
                    material.diffuse.contents = nil
                    material.metalness.contents = nil
                    material.roughness.contents = nil
                    
                    /// Visual Properties for Special Effects
                    material.normal.contents = nil
                    material.displacement.contents = nil
                    material.emission.contents = nil
                    material.selfIllumination.contents = nil
                    material.ambientOcclusion.contents = nil
                    
                    /// Visual Properties for Basic Shading
                    material.ambient.contents = nil
                    material.specular.contents = nil
                    material.reflective.contents = nil
                    material.multiply.contents = nil
                    material.transparent.contents = nil
                }
            }
        }
    }
}
