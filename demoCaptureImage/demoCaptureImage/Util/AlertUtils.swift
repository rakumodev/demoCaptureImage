//
//  AlertUtils.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/13/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import UIKit

struct AlertUtils {

    //Basically show an alert view with "Ok" button
    static func showSimpleAlertView(with title: String, message: String, _ parentVC: UIViewController? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            if parentVC != nil {
                parentVC?.present(alert, animated: true, completion: nil)
            } else {
                AppDelegate.sharedInstance()!.window?.topViewController()?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    static func showYesNoAlertView(with title: String, message: String, _ parentVC: UIViewController? = nil, completion: @escaping(_ isOk: Bool) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: { (_) in
                completion(true)
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (_) in
                alert.dismiss(animated: true, completion: nil)
                completion(false)
            }))
            if parentVC != nil {
                parentVC?.present(alert, animated: true, completion: nil)
            } else {
                AppDelegate.sharedInstance()!.window?.topViewController()?.present(alert, animated: true, completion: nil)
            }
        }
    }

}
