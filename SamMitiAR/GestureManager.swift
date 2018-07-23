//
//  GestureManager.swift
//  SamMiti
//
//  Created by Nattawut Singhchai on 7/2/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import UIKit

public struct GestureTypes: OptionSet {
    public var rawValue: UInt
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let tap          = GestureTypes(rawValue: 1 << 1)
    public static let doubleTap    = GestureTypes(rawValue: 1 << 2)
    public static let longPress    = GestureTypes(rawValue: 1 << 3)
    public static let pinch        = GestureTypes(rawValue: 1 << 4)
    public static let pan          = GestureTypes(rawValue: 1 << 5)
    public static let rotation     = GestureTypes(rawValue: 1 << 6)

    static let all: GestureTypes = [.tap, .doubleTap, .longPress, .pinch, .pan, .rotation]
}

enum Gesture {
    case tapped(UITapGestureRecognizer)
    case doubleTap(UITapGestureRecognizer)
    case longPress(UILongPressGestureRecognizer)
    case pinch(UIPinchGestureRecognizer)
    case pan(ThresholdPanGesture)
    case rotation(UIRotationGestureRecognizer)
}

protocol GestureManagerDelegate {
    func receivedGesture(gesture: Gesture)
}

class GestureManager: NSObject, UIGestureRecognizerDelegate {

    public var delegate: GestureManagerDelegate?
    public var types: GestureTypes = []

    init(view: UIView, types: GestureTypes = .all, delegate: GestureManagerDelegate? = nil) {
        super.init()
        self.delegate = delegate
        self.types = types
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handletap(_:) ))
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        
        if types.contains(.tap) {
            tapGesture.delegate = self
            view.addGestureRecognizer(tapGesture)
        }

        if types.contains(.doubleTap) {
            doubleTapGesture.delegate = self
            doubleTapGesture.numberOfTapsRequired = 2
            view.addGestureRecognizer(doubleTapGesture)
        }
        
        if types.contains(.tap) && types.contains(.doubleTap){
            tapGesture.require(toFail: doubleTapGesture)
        }
        
        if types.contains(.longPress) {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPressGesture.delegate = self
            view.addGestureRecognizer(longPressGesture)
        }

        if types.contains(.pinch) {
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            pinchGesture.delegate = self
            view.addGestureRecognizer(pinchGesture)
        }

        if types.contains(.pan) {
            let panGesture = ThresholdPanGesture(target: self, action: #selector(handlePan(_:)))
            panGesture.delegate = self
            view.addGestureRecognizer(panGesture)
        }

        if types.contains(.rotation) {
            let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
            rotationGesture.delegate = self
            view.addGestureRecognizer(rotationGesture)
        }

    }

    @objc func handletap(_ sender: UITapGestureRecognizer) {
        delegate?.receivedGesture(gesture: .tapped(sender))
    }

    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        delegate?.receivedGesture(gesture: .doubleTap(sender))
    }

    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        delegate?.receivedGesture(gesture: .longPress(sender))
    }

    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        delegate?.receivedGesture(gesture: .pinch(sender))
    }

    @objc func handlePan(_ sender: ThresholdPanGesture) {
        delegate?.receivedGesture(gesture: .pan(sender))
    }

    @objc func handleRotation(_ sender: UIRotationGestureRecognizer) {
        delegate?.receivedGesture(gesture: .rotation(sender))
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

/// Extends `UIGestureRecognizer` to provide the center point resulting from multiple touches.
extension UIGestureRecognizer {
    func center(in view: UIView) -> CGPoint {
        let first = CGRect(origin: location(ofTouch: 0, in: view), size: .zero)

        let touchBounds = (1..<numberOfTouches).reduce(first) { touchBounds, index in
            return touchBounds.union(CGRect(origin: location(ofTouch: index, in: view), size: .zero))
        }

        return CGPoint(x: touchBounds.midX, y: touchBounds.midY)
    }
}
