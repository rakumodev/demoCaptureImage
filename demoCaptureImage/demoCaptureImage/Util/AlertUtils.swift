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

}
