//
//  SamMitiInteractionStatus.swift
//  SamMitiAR
//
//  Created by Virakri Jinangkul on 2/19/18.
//


/// Status of Possible Interactions
///
/// - idle: No virtual object is being interacted or being placed at this moment.
/// - placing: a virtual object is ready to be placed.
/// - interacting: a virtual object is being manipulated.
public enum SamMitiInteractionStatus {
    case idle
    case placing
    case interacting
}
