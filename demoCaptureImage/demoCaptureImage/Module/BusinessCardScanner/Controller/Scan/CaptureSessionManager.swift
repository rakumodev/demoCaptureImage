import Foundation
import CoreMotion
import AVFoundation
import UIKit

/// A set of functions that inform the delegate object of the state of the detection.
protocol RectangleDetectionDelegateProtocol: NSObjectProtocol {

    /// Called when the capture of a picture has started.
    ///
    /// - Parameters:
    ///   - captureSessionManager: The `CaptureSessionManager` instance that started capturing a picture.
    func didStartCapturingPicture(for captureSessionManager: CaptureSessionManager)

    /// Called when a quadrilateral has been detected.
    /// - Parameters:
    ///   - captureSessionManager: The `CaptureSessionManager` instance that has detected a quadrilateral.
    ///   - quad: The detected quadrilateral in the coordinates of the image.
    ///   - imageSize: The size of the image the quadrilateral has been detected on.
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didDetectQuad quad: Quadrilateral?, _ imageSize: CGSize)

    // Hoang
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didDetectQuads quads: [Quadrilateral]?, _ imageSize: CGSize)
    
    /// Called when a picture with or without a quadrilateral has been captured.
    ///
    /// - Parameters:
    ///   - captureSessionManager: The `CaptureSessionManager` instance that has captured a picture.
    ///   - picture: The picture that has been captured.
    ///   - quad: The quadrilateral that was detected in the picture's coordinates if any.
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage, withQuad quads: [Quadrilateral]?)

    /// Called when an error occured with the capture session manager.
    /// - Parameters:
    ///   - captureSessionManager: The `CaptureSessionManager` that encountered an error.
    ///   - error: The encountered error.
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error)
    

}

/// The CaptureSessionManager is responsible for setting up and managing the AVCaptureSession and the functions related to capturing.
class CaptureSessionManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    let videoPreviewLayer: AVCaptureVideoPreviewLayer
    let captureSession = AVCaptureSession()
    let rectangleFunnel = RectangleFeaturesFunnel()
    weak var delegate: RectangleDetectionDelegateProtocol?
    
    var displayedRectangleResult: RectangleDetectorResult?
    var displayedRectanglesResult: [RectangleDetectorResult]?
    
    var photoOutput = AVCapturePhotoOutput()

    /// Whether the CaptureSessionManager should be detecting quadrilaterals.
    var isDetecting = true

    /// The number of times no rectangles have been found in a row.
    var noRectangleCount = 0

    /// The minimum number of time required by `noRectangleCount` to validate that no rectangles have been found.
    let noRectangleThreshold = 3

    // MARK: Life Cycle

    init?(videoPreviewLayer: AVCaptureVideoPreviewLayer) {
        self.videoPreviewLayer = videoPreviewLayer
        super.init()

        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            let error = ImageScannerControllerError.inputDevice
            delegate?.captureSessionManager(self, didFailWithError: error)
            return nil
        }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo

        photoOutput.isHighResolutionCaptureEnabled = true

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true

        defer {
            device.unlockForConfiguration()
            captureSession.commitConfiguration()
        }

        guard let deviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(deviceInput),
            captureSession.canAddOutput(photoOutput),
            captureSession.canAddOutput(videoOutput) else {
                let error = ImageScannerControllerError.inputDevice
                delegate?.captureSessionManager(self, didFailWithError: error)
                return
        }

        do {
            try device.lockForConfiguration()
        } catch {
            let error = ImageScannerControllerError.inputDevice
            delegate?.captureSessionManager(self, didFailWithError: error)
            return
        }

        device.isSubjectAreaChangeMonitoringEnabled = true

        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)

        videoPreviewLayer.session = captureSession
        videoPreviewLayer.videoGravity = .resizeAspectFill

        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video_ouput_queue"))
    }

    // MARK: Capture Session Life Cycle

    /// Starts the camera and detecting quadrilaterals.
    func start() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch authorizationStatus {
        case .authorized:
            DispatchQueue.main.async {
                self.captureSession.startRunning()
            }
            isDetecting = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (_) in
                DispatchQueue.main.async { [weak self] in
                    self?.start()
                }
            })
        default:
            let error = ImageScannerControllerError.authorization
            delegate?.captureSessionManager(self, didFailWithError: error)
        }
    }

    func stop() {
        captureSession.stopRunning()
    }

    func capturePhoto() {
        guard let connection = photoOutput.connection(with: .video), connection.isEnabled, connection.isActive else {
            let error = ImageScannerControllerError.capture
            delegate?.captureSessionManager(self, didFailWithError: error)
            return
        }

        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.isAutoStillImageStabilizationEnabled = true

        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isDetecting == true,
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
        }

        let imageSize = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))

        if #available(iOS 11.0, *) {
            VisionRectangleDetector.rectangle(forPixelBuffer: pixelBuffer) { (rectangles) in
                self.processRectangle(rectangles: rectangles, imageSize: imageSize)
            }
        } else {
            let finalImage = CIImage(cvPixelBuffer: pixelBuffer)
            CIRectangleDetector.rectangle(forImage: finalImage) { (rectangle) in
//                self.processRectangle(rectangle: rectangle, imageSize: imageSize)
            }
        }
    }

    func processRectangle(rectangles: [Quadrilateral]?, imageSize: CGSize) {
        if let rectangles = rectangles {
            self.noRectangleCount = 0
            let quads = self.rectangleFunnel.add(rectangles, currentlyDisplayedRectangles: displayedRectanglesResult)
            var rectanglesDetectorResult = [RectangleDetectorResult]()
            quads.forEach({ (quad) in
                rectanglesDetectorResult.append(RectangleDetectorResult(rectangle: quad, imageSize: imageSize))
            })
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.displayRectanglesResult(rectanglesResult: rectanglesDetectorResult, imageSize: imageSize)
            }
            
            return
                
//            rectangles.forEach { (rectangle) in
//                self.rectangleFunnel.add(rectangle, currentlyDisplayedRectangle: self.displayedRectangleResult?.rectangle) { [weak self] (result, rectangle) in
//
//                    guard let strongSelf = self else {
//                        return
//                    }
//
//                    let shouldAutoScan = (result == .showAndAutoScan)
//                    strongSelf.displayRectangleResult(rectangleResult: RectangleDetectorResult(rectangle: rectangle, imageSize: imageSize))
//                    if shouldAutoScan, CaptureSession.current.isAutoScanEnabled, !CaptureSession.current.isEditing {
//                        //                    capturePhoto()
//                    }
//                }
//            }
        } else {

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.noRectangleCount += 1

                if strongSelf.noRectangleCount > strongSelf.noRectangleThreshold {
                    // Reset the currentAutoScanPassCount, so the threshold is restarted the next time a rectangle is found
                    strongSelf.rectangleFunnel.currentAutoScanPassCount = 0

                    // Remove the currently displayed rectangle as no rectangles are being found anymore
                    strongSelf.displayedRectangleResult = nil
                    strongSelf.delegate?.captureSessionManager(strongSelf, didDetectQuad: nil, imageSize)
                }
            }
            return
        }
    }

    @discardableResult func displayRectangleResult(rectangleResult: RectangleDetectorResult) -> Quadrilateral {
        displayedRectangleResult = rectangleResult

        let quad = rectangleResult.rectangle.toCartesian(withHeight: rectangleResult.imageSize.height)

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.captureSessionManager(strongSelf, didDetectQuad: quad, rectangleResult.imageSize)
        }
        return quad
    }
    
    func displayRectanglesResult(rectanglesResult: [RectangleDetectorResult], imageSize: CGSize) -> [Quadrilateral] {
        displayedRectanglesResult = rectanglesResult
        var quads = [Quadrilateral]()
        rectanglesResult.forEach { (rectangle) in
            let quad = rectangle.rectangle.toCartesian(withHeight: rectangle.imageSize.height)
            quads.append(quad)
        }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.captureSessionManager(strongSelf, didDetectQuads: quads, imageSize)
        }
        return quads
    }
}

extension CaptureSessionManager: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            delegate?.captureSessionManager(self, didFailWithError: error)
            return
        }

        CaptureSession.current.setImageOrientation()

        isDetecting = false
        rectangleFunnel.currentAutoScanPassCount = 0
        delegate?.didStartCapturingPicture(for: self)

        if let sampleBuffer = photoSampleBuffer,
            let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil) {
            completeImageCapture(with: imageData)
        } else {
            let error = ImageScannerControllerError.capture
            delegate?.captureSessionManager(self, didFailWithError: error)
            return
        }

    }

    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            delegate?.captureSessionManager(self, didFailWithError: error)
            return
        }

        CaptureSession.current.setImageOrientation()

        isDetecting = false
        rectangleFunnel.currentAutoScanPassCount = 0
        delegate?.didStartCapturingPicture(for: self)

        if let imageData = photo.fileDataRepresentation() {
            completeImageCapture(with: imageData)
        } else {
            let error = ImageScannerControllerError.capture
            delegate?.captureSessionManager(self, didFailWithError: error)
            return
        }
    }

    /// Completes the image capture by processing the image, and passing it to the delegate object.
    /// This function is necessary because the capture functions for iOS 10 and 11 are decoupled.
    func completeImageCapture(with imageData: Data) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            CaptureSession.current.isEditing = true
            guard let image = UIImage(data: imageData) else {
                let error = ImageScannerControllerError.capture
                DispatchQueue.main.async {
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.delegate?.captureSessionManager(strongSelf, didFailWithError: error)
                }
                return
            }

            var angle: CGFloat = 0.0

            switch image.imageOrientation {
            case .right:
                angle = CGFloat.pi / 2
            case .up:
                angle = CGFloat.pi
            default:
                break
            }
            
            var quads: [Quadrilateral]?
            if let displayedRectanglesResult = self?.displayedRectanglesResult, let imageSize = displayedRectanglesResult.first?.imageSize {
                quads = self?.displayRectanglesResult(rectanglesResult: displayedRectanglesResult, imageSize: imageSize)
                var quadsTmp = [Quadrilateral]()
                quads?.forEach({ (quad) in
                    let quadScale = quad.scale(imageSize, image.size, withRotationAngle: angle)
                    quadsTmp.append(quadScale)
                })
                quads = quadsTmp
            }

            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.delegate?.captureSessionManager(strongSelf, didCapturePicture: image, withQuad: quads)
            }
        }
    }
}

/// Data structure representing the result of the detection of a quadrilateral.
 struct RectangleDetectorResult {

    /// The detected quadrilateral.
    let rectangle: Quadrilateral

    /// The size of the image the quadrilateral was detected on.
    let imageSize: CGSize

}
