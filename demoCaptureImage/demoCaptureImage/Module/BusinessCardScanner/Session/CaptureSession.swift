//
//  CaptureSession.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/13/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import Foundation
import AVFoundation

/// A class containing global variables and settings for this capture session
class CaptureSession {
    
    static let current = CaptureSession()
    
    /// The AVCaptureDevice used for the flash and focus setting
    var device: CaptureDevice?
    
    /// Whether the user is past the scanning screen or not (needed to disable auto scan on other screens)
    var isEditing: Bool
    
    /// The status of auto scan. Auto scan tries to automatically scan a detected rectangle if it has a high enough accuracy.
    var isAutoScanEnabled: Bool
    
    /// The orientation of the captured image
    var editImageOrientation: CGImagePropertyOrientation
    
    init(isAutoScanEnabled: Bool = true, editImageOrientation: CGImagePropertyOrientation = .up) {
        self.device = AVCaptureDevice.default(for: .video)
        
        self.isEditing = false
        self.isAutoScanEnabled = isAutoScanEnabled
        self.editImageOrientation = editImageOrientation
    }
    
}
