//
//  MockCaptureDevice.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/13/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import Foundation
import AVFoundation

protocol CaptureDevice: class {
    func unlockForConfiguration()
    func lockForConfiguration() throws

    var torchMode: AVCaptureDevice.TorchMode { get set }
    var isTorchAvailable: Bool { get }

    var focusMode: AVCaptureDevice.FocusMode { get set }
    var focusPointOfInterest: CGPoint { get set }
    var isFocusPointOfInterestSupported: Bool { get }
    func isFocusModeSupported(_ focusMode: AVCaptureDevice.FocusMode) -> Bool

    var exposureMode: AVCaptureDevice.ExposureMode { get set }
    var exposurePointOfInterest: CGPoint { get set }
    var isExposurePointOfInterestSupported: Bool { get }
    func isExposureModeSupported(_ exposureMode: AVCaptureDevice.ExposureMode) -> Bool

    var isSubjectAreaChangeMonitoringEnabled: Bool { get set }
}

class MockCaptureDevice: CaptureDevice {
    func unlockForConfiguration() {
        return
    }

    func lockForConfiguration() throws {
        return
    }

    var torchMode: AVCaptureDevice.TorchMode = .off
    var isTorchAvailable: Bool = true

    var focusMode: AVCaptureDevice.FocusMode = .continuousAutoFocus
    var focusPointOfInterest: CGPoint = .zero
    var isFocusPointOfInterestSupported: Bool = true

    var exposureMode: AVCaptureDevice.ExposureMode = .continuousAutoExposure
    var exposurePointOfInterest: CGPoint = .zero
    var isExposurePointOfInterestSupported: Bool = true

    func isFocusModeSupported(_ focusMode: AVCaptureDevice.FocusMode) -> Bool {
        return true
    }

    func isExposureModeSupported(_ exposureMode: AVCaptureDevice.ExposureMode) -> Bool {
        return true
    }

    var isSubjectAreaChangeMonitoringEnabled: Bool = false
}
