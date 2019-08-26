import Foundation

import UIKit
import AVFoundation

/// A set of methods that your delegate object must implement to interact with the image scanner interface.
protocol ImageScannerControllerDelegate: NSObjectProtocol {

    /// Tells the delegate that the user scanned a document.
    ///
    /// - Parameters:
    ///   - scanner: The scanner controller object managing the scanning interface.
    ///   - results: The results of the user scanning with the camera.
    /// - Discussion: Your delegate's implementation of this method should dismiss the image scanner controller.
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults)

    /// Tells the delegate that the user cancelled the scan operation.
    ///
    /// - Parameters:
    ///   - scanner: The scanner controller object managing the scanning interface.
    /// - Discussion: Your delegate's implementation of this method should dismiss the image scanner controller.
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController)

    /// Tells the delegate that an error occured during the user's scanning experience.
    ///
    /// - Parameters:
    ///   - scanner: The scanner controller object managing the scanning interface.
    ///   - error: The error that occured.
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error)
}

/// A view controller that manages the full flow for scanning documents.
/// The `ImageScannerController` class is meant to be presented. It consists of a series of 3 different screens which guide the user:
/// 1. Uses the camera to capture an image with a rectangle that has been detected.
/// 2. Edit the detected rectangle.
/// 3. Review the cropped down version of the rectangle.
class ImageScannerController: UINavigationController {

    /// The object that acts as the delegate of the `ImageScannerController`.
    weak var imageScannerDelegate: ImageScannerControllerDelegate?

    // MARK: - Life Cycle

    /// A black UIView, used to quickly display a black screen when the shutter button is presseed.
    let blackFlashView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var rotationAngle = Measurement<UnitAngle>(value: 0, unit: .degrees)

    required init(image: UIImage? = nil, delegate: ImageScannerControllerDelegate? = nil) {
        super.init(rootViewController: ScannerViewController())

        self.imageScannerDelegate = delegate

        navigationBar.tintColor = .black
        navigationBar.isTranslucent = false
        self.view.addSubview(blackFlashView)
        setupConstraints()

        // If an image was passed in by the host app (e.g. picked from the photo library), use it instead of the document scanner.
        if let image = image {

            var detectedQuads: [Quadrilateral] = []

            // Whether or not we detect a quad, present the edit view controller after attempting to detect a quad.
            // *** Vision *requires* a completion block to detect rectangles, but it's instant.
            // *** When using Vision, we'll present the normal edit view controller first, then present the updated edit view controller later.
            defer {
                let editViewController = EditScanViewController(image: image, quads: detectedQuads)
                setViewControllers([editViewController], animated: false)
            }
            
            rotationAngle.value += 180
            guard let ciImage = CIImage(image: image.applyingPortraitOrientation().rotated(by: rotationAngle, options: [.flipOnVerticalAxis]) ?? image.applyingPortraitOrientation()) else { return }
            if #available(iOS 11.0, *) {
                // Use the VisionRectangleDetector on iOS 11 to attempt to find a rectangle from the initial image.
                VisionRectangleDetector.rectangles(forImage: ciImage.oriented(.up)) { (quads) in
                    guard let quads = quads else { return }
                    detectedQuads = quads

                    for i in detectedQuads.indices {
                        detectedQuads[i].reorganize()
                    }

                    let editViewController = EditScanViewController(image: image, quads: detectedQuads)
                    self.setViewControllers([editViewController], animated: true)
                }
            } else {
                // Use the CIRectangleDetector on iOS 10 to attempt to find a rectangle from the initial image.
                detectedQuads = CIRectangleDetector.rectangles(forImage: ciImage)!
                for i in detectedQuads.indices {
                    detectedQuads[i].reorganize()
                }
            }
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupConstraints() {
        let blackFlashViewConstraints = [
            blackFlashView.topAnchor.constraint(equalTo: view.topAnchor),
            blackFlashView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: blackFlashView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: blackFlashView.trailingAnchor)
        ]

        NSLayoutConstraint.activate(blackFlashViewConstraints)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    func flashToBlack() {
        view.bringSubviewToFront(blackFlashView)
        blackFlashView.isHidden = false
        let flashDuration = DispatchTime.now() + 0.05
        DispatchQueue.main.asyncAfter(deadline: flashDuration) {
            self.blackFlashView.isHidden = true
        }
    }

}

/// Data structure containing information about a scan.
struct ImageScannerResults {

    /// The original image taken by the user, prior to the cropping applied by WeScan.
    var originalImage: UIImage

    /// The deskewed and cropped orignal image using the detected rectangle, without any filters.
    var scannedImage: UIImage

    /// The enhanced image, passed through an Adaptive Thresholding function. This image will always be grayscale and may not always be available.
    var enhancedImage: UIImage?

    /// Whether the user wants to use the enhanced image or not. The `enhancedImage`, for use with OCR or similar uses, may still be available even if it has not been selected by the user.
    var doesUserPreferEnhancedImage: Bool

    /// The detected rectangle which was used to generate the `scannedImage`.
    var detectedRectangle: Quadrilateral

}
