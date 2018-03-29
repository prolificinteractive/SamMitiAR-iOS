//
//  SamMitiARDebug.swift
//  SamMitiARDebug
//
//  Created by Nattawut Singhchai on 15/2/18.
//  Copyright © 2018 Prolific Interactive. All rights reserved.
//

import ARKit

// DebugOptions
//
// เป็น Option เพื่อเลือกแสดงค่าภายในที่เกิดขึ้นขณะอยู่ใน session ของ AR

public struct SamMitiDebugOptions: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// ค่าสถิติทั่วไป เช่น framerate หรือ จำนวน node
//    public static let statistics            = SamMitiDebugOptions(rawValue: 1 << 0)
    
    /// ค่าความ confident ของพื้นผิวที่ focus node ชี้อยู่
    public static let showStateStatus        = SamMitiDebugOptions(rawValue: 1 << 0)
    
    /// แสดง anchor ของพื้นผิว
    public static let showAnchorPlane           = SamMitiDebugOptions(rawValue: 1 << 1)

    public static let all: SamMitiDebugOptions = [.showStateStatus, .showAnchorPlane]
}


//interactingStatus
extension SamMitiARView {
    
    struct DesignConstants {
        /// Sizes
        static let labelWidth: CGFloat = 320
        static let labelHeight: CGFloat = 16
        
        /// Colors
        static let defaultTextColor: UIColor = .white
        static let warningTextColor: UIColor = .yellow
        static let destructiveTextColor: UIColor = .red
        static let undefinedTextColor: UIColor = UIColor.white.withAlphaComponent(0.33)
    }
    
    func setupDetectingLevelDebugsView() {
        let stackView = UIStackView(frame: CGRect(origin: .zero, size: CGSize.zero))
        stackView.spacing = 2
        stackView.alignment = .center
        stackView.axis = .vertical
        let font = UIFont.systemFont(ofSize: 12)
        
        let interactionStatusLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: DesignConstants.labelWidth, height: DesignConstants.labelHeight)))
        interactionStatusLabel.text = "Interaction Status: Idle"
        interactionStatusLabel.textColor = DesignConstants.defaultTextColor

        let confidentLevelLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: DesignConstants.labelWidth, height: DesignConstants.labelHeight)))
        confidentLevelLabel.text = "Plane Detecting Confident Level: Undefined"
        confidentLevelLabel.textColor = DesignConstants.undefinedTextColor

        let alignmentLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: DesignConstants.labelWidth, height: DesignConstants.labelHeight)))
        alignmentLabel.text = "Alignment: Undefined"
        alignmentLabel.textColor = DesignConstants.undefinedTextColor
        
        let hitTestDistanceLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: DesignConstants.labelWidth, height: DesignConstants.labelHeight)))
        hitTestDistanceLabel.text = "Hit Test Distance: Undefined"
        hitTestDistanceLabel.textColor = DesignConstants.undefinedTextColor
        
        stackView.addArrangedSubview(interactionStatusLabel)
        stackView.addArrangedSubview(confidentLevelLabel)
        stackView.addArrangedSubview(alignmentLabel)
        stackView.addArrangedSubview(hitTestDistanceLabel)

        for label in stackView.arrangedSubviews {
            guard let label = label as? UILabel else { continue }
            label.layer.shadowRadius = 2.0
            label.layer.shadowColor = UIColor.black.cgColor
            label.layer.shadowOpacity = 0.3
            label.layer.shadowOffset = .zero
            label.textColor = .white
            label.font = font
        }
        stackView.backgroundColor = .white
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: DesignConstants.labelWidth))
        
        arDebugView = stackView
        addSubview(stackView)

        addConstraint(NSLayoutConstraint(item: self, attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: stackView, attribute: .centerX,
                                         multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: stackView, attribute: .centerY,
                                         multiplier: 1, constant: 0))
    }
    
    func updateInteractionStatusDebugsView(to interactionStatus: SamMitiInteractionStatus) {
        OperationQueue.main.addOperation {
            var interactionStatusText = ""
            switch interactionStatus {
            case .idle:
                interactionStatusText = "Idle"
            case .placing:
                interactionStatusText = "Placing"
            case .interacting:
                interactionStatusText = "Interacting"
            }
            
            let label = self.arDebugView?.arrangedSubviews[0].asLabel
            label?.text = "Interaction Status: \(interactionStatusText)"
            
        }
    }
    
    func updateDetectingLevelDebugsView(to confidentLevel: PlaneDetectingConfidentLevel?) {
        OperationQueue.main.addOperation {
            
            var textColor = DesignConstants.undefinedTextColor
            var confidentLevelText = ""
            
            if let confidentLevel = confidentLevel {
                switch confidentLevel {
                case .estimated:
                    textColor = DesignConstants.warningTextColor
                    confidentLevelText = "Estimated"
                case .existing:
                    textColor = DesignConstants.defaultTextColor
                    confidentLevelText = "Existing"
                default:
                    textColor = DesignConstants.destructiveTextColor
                    confidentLevelText = "Not Found"
                }
            } else {
                textColor = DesignConstants.undefinedTextColor
                confidentLevelText = "Undefined"
            }
            
            let label = self.arDebugView?.arrangedSubviews[1].asLabel
            label?.text = "Plane Detecting Confident Level: \(confidentLevelText)"
            label?.textColor = textColor

        }
    }

    func updateAlignmentDebugsView(to alignment: ARPlaneAnchor.Alignment?) {
        OperationQueue.main.addOperation {
            let label = self.arDebugView?.arrangedSubviews[2].asLabel
            if let alignment = alignment {
                label?.textColor = .white
                switch alignment{
                case .horizontal:
                    label?.text = "Alignment: Horizontal"
                case .vertical:
                    label?.text = "Alignment: Vertical"
                }
                
            } else {
                label?.textColor = DesignConstants.undefinedTextColor
                label?.text = "Alignment: Undefined"
            }
        }
    }

    func updateHitTestDistanceDebugsView(to distance: CGFloat?) {
        OperationQueue.main.addOperation {
            let label = self.arDebugView?.arrangedSubviews[3].asLabel
            if let castDistance = distance {
                label?.textColor = .white
                label?.text = "Hit Test Distance: \(round(castDistance * 100) / 100)m"
            } else {
                label?.textColor = DesignConstants.undefinedTextColor
                label?.text = "Hit Test Distance: Undefined"
            }
        }

    }
}

// Utilitiy for cast UIView as? UILabel
extension UIView {
    var asLabel: UILabel? {
        return self as? UILabel
    }
}

