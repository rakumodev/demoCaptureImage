//
//  ReviewViewController.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/13/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import UIKit

/// The `ReviewViewController` offers an interface to review the image after it has been cropped and deskwed according to the passed in quadrilateral.
class ReviewViewController: UIViewController {

    var rotationAngle = Measurement<UnitAngle>(value: 0, unit: .degrees)
    var enhancedImageIsAvailable = false
    var isCurrentlyDisplayingEnhancedImage = false

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = results.scannedImage
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var enhanceButton: UIBarButtonItem = {
        let image = UIImage(named: "enhance", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(toggleEnhancedImage))
        button.tintColor = .white
        return button
    }()

    lazy var rotateButton: UIBarButtonItem = {
        let image = UIImage(named: "rotate", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(rotateImage))
        button.tintColor = .white
        return button
    }()

    lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finishScan))
        button.tintColor = navigationController?.navigationBar.tintColor
        return button
    }()

    let results: ImageScannerResults

    // MARK: - Life Cycle

    init(results: ImageScannerResults) {
        self.results = results
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        enhancedImageIsAvailable = results.enhancedImage != nil

        setupViews()
        setupToolbar()
        setupConstraints()

        title = NSLocalizedString("wescan.review.title", tableName: nil, bundle: Bundle(for: ReviewViewController.self), value: "Review", comment: "The review title of the ReviewController")
        navigationItem.rightBarButtonItem = doneButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // We only show the toolbar (with the enhance button) if the enhanced image is available.
        if enhancedImageIsAvailable {
            navigationController?.setToolbarHidden(false, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }

    // MARK: Setups

    func setupViews() {
        view.addSubview(imageView)
    }

    func setupToolbar() {
        guard enhancedImageIsAvailable else { return }

        navigationController?.toolbar.barStyle = .blackTranslucent

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [fixedSpace, enhanceButton, flexibleSpace, rotateButton, fixedSpace]
    }

    func setupConstraints() {
        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ]

        NSLayoutConstraint.activate(imageViewConstraints)
    }

    // MARK: - Actions

    @objc func reloadImage() {
        if enhancedImageIsAvailable, isCurrentlyDisplayingEnhancedImage {
            imageView.image = results.enhancedImage?.rotated(by: rotationAngle) ?? results.enhancedImage
        } else {
            imageView.image = results.scannedImage.rotated(by: rotationAngle) ?? results.scannedImage
        }
    }

    @objc func toggleEnhancedImage() {
        guard enhancedImageIsAvailable else { return }

        isCurrentlyDisplayingEnhancedImage.toggle()
        reloadImage()

        if isCurrentlyDisplayingEnhancedImage {
            enhanceButton.tintColor = UIColor(red: 64 / 255, green: 159 / 255, blue: 255 / 255, alpha: 1.0)
        } else {
            enhanceButton.tintColor = .white
        }
    }

    @objc func rotateImage() {
        rotationAngle.value += 90

        if rotationAngle.value == 360 {
            rotationAngle.value = 0
        }

        reloadImage()
    }

    @objc func finishScan() {
        guard let imageScannerController = navigationController as? ImageScannerController else { return }
        var newResults = results
        newResults.scannedImage = results.scannedImage.rotated(by: rotationAngle) ?? results.scannedImage
        newResults.enhancedImage = results.enhancedImage?.rotated(by: rotationAngle) ?? results.enhancedImage
        newResults.doesUserPreferEnhancedImage = isCurrentlyDisplayingEnhancedImage
        imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFinishScanningWithResults: newResults)
    }

}
