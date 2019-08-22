//
//  HomeViewController.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/10/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import UIKit
import GoogleSignIn

class HomeViewController: UITableViewController {
    //Init action list model
    let actionList: [ActionModel] = {
        let captureImageAction = CaptureImageAction()
        let openLibraryAction = OpenLibraryAction()
        let logoutAction = LogoutAction()
        return [captureImageAction, openLibraryAction, logoutAction]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.sharedInstance()!.homeScreen = self
        // Do any additional setup after loading the view.
    }

    func userClickLogout() {
        AlertUtils.showYesNoAlertView(with: "Warning", message: "Do you want to logout ?", self) { (isOk) in
            if isOk {
                //User tapped OK button
                GIDSignIn.sharedInstance().signOut()
                UserDefaults.standard.set(false, forKey: GlobalConstant.LOGGED_IN)
                DispatchQueue.main.async {
                    let loginViewController = AppDelegate.sharedInstance()!.mainStoryBoard.instantiateViewController(withIdentifier: GlobalConstant.LOGIN_SCREEN_IDENTIFER)
                    let loginScreenNav = UINavigationController.init(rootViewController: loginViewController)
                    AppDelegate.sharedInstance()!.window?.rootViewController = loginScreenNav
                    print("Logout successfully")
                }
            } else {
                //User tapped Cancel button
                return
            }
        }
    }

    func userClickCaptureImage() {
        scanImage()
    }

    func userClickOpenPhotoLibrary() {
        openPhotoPibrary()
    }

    func scanImage() {
        DispatchQueue.main.async {
            let scannerViewController = ImageScannerController(delegate: self)
            self.present(scannerViewController, animated: true, completion: nil)
        }
    }

    func openPhotoPibrary() {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = actionList[indexPath.row].title
        cell.imageView?.image = actionList[indexPath.row].icon
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch actionList[indexPath.row].action {
        case .CAPTURE_IMAGE?:
            //Capture image
            userClickCaptureImage()
        case .OPEN_LIBRARY?:
            //Open library
            userClickOpenPhotoLibrary()
        case .LOGOUT?:
            //Logout
            userClickLogout()
        default: break
        }
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

extension HomeViewController: ImageScannerControllerDelegate {

    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        DispatchQueue.main.async {
            scanner.dismiss(animated: true, completion: nil)
        }
    }

    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        guard let scannedImage = results.scannedImage as UIImage? else {
            DispatchQueue.main.async {
                scanner.dismiss(animated: true, completion: nil)
            }
            return
        }
        //Saving image
        UIImageWriteToSavedPhotosAlbum(scannedImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        DispatchQueue.main.async {
            scanner.dismiss(animated: true, completion: nil)
        }
    }

    //Add image to library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            if let error = error {
                // we got back an error!
                AlertUtils.showSimpleAlertView(with: "Save error", message: error.localizedDescription)
            } else {
                AlertUtils.showSimpleAlertView(with: "Saved!", message: "Scanned image has been saved")
            }
        }
    }

    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        DispatchQueue.main.async {
            AlertUtils.showSimpleAlertView(with: "Error", message: error.localizedDescription)
        }
        print(error)
    }

}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //Cancel pick image
        DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: nil)
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            let scannerViewController = ImageScannerController.init(image: image, delegate: self)
            self.present(scannerViewController, animated: true, completion: nil)
        }
    }

}
