//
//  LoginViewController.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/10/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import UIKit
import GoogleSignIn
import ProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var bottomLb: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Configure UI for different environment
        configUI()
        //Set GoogleSignIn UI delegate
        GIDSignIn.sharedInstance().uiDelegate = self
        AppDelegate.sharedInstance().loginScreen = self
    }
    
    func configUI(){
        
        //Configure UI for each environment
        let bgColor = Environment().configuration(PlistKey.BACKGROUND_COLOR)
        let lbColor = Environment().configuration(PlistKey.LABEL_COLOR)

        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.init(hexString: bgColor)
            self.bottomLb.textColor = UIColor.init(hexString: lbColor)
            self.loginBtn.setTitleColor(UIColor.init(hexString: lbColor), for: .normal)
        }
        
    }
    
    @IBAction func userClickLoginBtn(_ sender: UIButton) {
        print("Login button clicked")
        GIDSignIn.sharedInstance().signIn()
    }
    
}

extension LoginViewController: GIDSignInUIDelegate {
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    private func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        DispatchQueue.main.async {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
