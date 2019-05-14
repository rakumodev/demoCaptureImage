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
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = GlobalConstant.GOOGLE_CLIENT_ID
        GIDSignIn.sharedInstance().delegate = self
        //Initialize sign-in UI
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

extension LoginViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
            DispatchQueue.main.async {
                ProgressHUD.show()
            }
            if let error = error {
                //Authentication error
                DispatchQueue.main.async {
                    ProgressHUD.dismiss()
                    AlertUtils.showSimpleAlertView(with: "Error", message: error.localizedDescription)
                }
                print("\(error.localizedDescription)")
            }
            else {
                //Authenticate with our server after signed in user.
                let idToken = user.authentication.idToken
                let imageURL = user.profile.imageURL(withDimension: 48)
                DispatchQueue.global(qos: .userInteractive).async {
                    APIManager.sharedInstance.login(with: idToken ?? "", and: imageURL?.absoluteString ?? "", completion: { (success, msgError) in
                        if success {
                            print("Login successfully")
                            UserDefaults.standard.set(true, forKey: GlobalConstant.LOGGED_IN)
                            //Navigate to home screen after authenticate with server successfully
                            DispatchQueue.main.async {
                                ProgressHUD.dismiss()
                                let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
                                let homeViewController = mainStoryBoard.instantiateViewController(withIdentifier: GlobalConstant.HOME_SCREEN_IDENTIFER)
                                let homeScreenNav = UINavigationController.init(rootViewController: homeViewController)
                                AppDelegate.sharedInstance().window?.rootViewController = homeScreenNav
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                ProgressHUD.dismiss()
                                AlertUtils.showSimpleAlertView(with: "Error", message: msgError!)
                            }
                            print(msgError!)
                        }
                    })
                }
            }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        //Perform operations when the user disconnects from app here.
        
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
