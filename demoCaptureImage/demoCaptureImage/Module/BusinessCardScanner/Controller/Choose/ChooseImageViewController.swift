//
//  ChooseImageViewController.swift
//  demoCaptureImage
//
//  Created by phatnt on 6/5/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import UIKit
import AVFoundation
import FSPagerView

class ChooseImageViewController: UIViewController {
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }

    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            pageControl.numberOfPages = self.scannedImages.count
            pageControl.contentHorizontalAlignment = .center
            pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            pageControl.hidesForSinglePage = true
        }
    }

    var scannedImages: [UIImage] = []
    var rotationAngle = Measurement<UnitAngle>(value: 0, unit: .degrees)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func userTappedCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func userTappedDoneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        finishScan()
    }
    
    @objc func finishScan() {
        guard let scannedImages = self.scannedImages as [UIImage]? else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        scannedImages.forEach { (scannedImage) in
            //Saving image
            UIImageWriteToSavedPhotosAlbum(scannedImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Add image to library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            debugPrint(error.localizedDescription)
        } else {
            debugPrint("Scanned image has been saved")
        }
    }
    
}

// MARK: - FSPagerViewDelegate
extension ChooseImageViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.scannedImages.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.clipsToBounds = true
        cell.imageView?.isOpaque = true
        cell.imageView?.image = scannedImages[index]
        cell.imageView?.backgroundColor = .black
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }
    
}

extension ChooseImageViewController {

    class func storyboardInstance() -> ChooseImageViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let instance = storyboard.instantiateViewController(withIdentifier: "ChooseImageViewController") as? ChooseImageViewController
        return instance
    }
}
