//
//  AppDelegate.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/8/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import UIKit
import GoogleSignIn
import AFNetworking
import ProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var loginScreen: LoginViewController!
    var homeScreen: HomeViewController!
    let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = Constant.GOOGLE_CLIENT_ID
        GIDSignIn.sharedInstance().delegate = self

        //Perform check if user has already logged in yet
        if UserDefaults.standard.bool(forKey: Constant.LOGGED_IN) {
            //If true then app directly navigates to home screen
            let homeViewController = mainStoryBoard.instantiateViewController(withIdentifier: Constant.HOME_SCREEN_IDENTIFER)
            let homeScreenNav = UINavigationController.init(rootViewController: homeViewController)
            self.window?.rootViewController = homeScreenNav
        }
        else {
            //If false then app navigates to login screen
            let logInViewController = mainStoryBoard.instantiateViewController(withIdentifier: Constant.LOGIN_SCREEN_IDENTIFER)
            let logInNav = UINavigationController.init(rootViewController: logInViewController)
            self.window?.rootViewController = logInNav
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        ProgressHUD.show()
        DispatchQueue.global(qos: .userInteractive).async {
            if let error = error {
                //Authentication error
                ProgressHUD.dismiss()
                AlertUtils.showSimpleAlertView(with: "Error", message: error.localizedDescription)
                print("\(error.localizedDescription)")
            }
            else {
                //Authenticate with our server after signed in user.
                let idToken = user.authentication.idToken
                let imageURL = user.profile.imageURL(withDimension: 48)
                //Prepare json data
                let params = ["idToken":idToken ?? "",
                              "imageURL":imageURL?.absoluteString ?? ""]
                //Create multipart data request
                let request = AFHTTPRequestSerializer().multipartFormRequest(withMethod: RequestMethod.POST.rawValue, urlString: Constant.SEVER_API_URL, parameters: params, constructingBodyWith: { (formData) in
                    print("Processed multipart request")
                }, error: nil)
                let manager = AFURLSessionManager.init(sessionConfiguration: .default)
                let uploadTask = manager.uploadTask(withStreamedRequest: request as URLRequest, progress: nil) { (response, data, error) in
                    if error == nil {
                        guard let data = data else {
                            //Show error message
                            ProgressHUD.dismiss()
                            AlertUtils.showSimpleAlertView(with: "Error", message: error!.localizedDescription)
                            print(error!.localizedDescription)
                            return
                        }
                        if let responseJSON = data as? [String:Any] {
                            print(responseJSON)
                            if let statusCode = responseJSON["statusCode"] as! Int?, statusCode == 200 {
                                print("Login successfully")
                                ProgressHUD.dismiss()
                                UserDefaults.standard.set(true, forKey: Constant.LOGGED_IN)
                                //Navigate to home screen after authenticate with server successfully
                                DispatchQueue.main.async {
                                    let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
                                    let homeViewController = mainStoryBoard.instantiateViewController(withIdentifier: Constant.HOME_SCREEN_IDENTIFER)
                                    let homeScreenNav = UINavigationController.init(rootViewController: homeViewController)
                                    self.window?.rootViewController = homeScreenNav
                                }
                            }
                        }
                    }
                    else {
                        //Show error message
                        ProgressHUD.dismiss()
                        AlertUtils.showSimpleAlertView(with: "Error", message: error!.localizedDescription)
                        print(error!.localizedDescription)
                    }
                }
                uploadTask.resume()
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        //Perform operations when the user disconnects from app here.
        
    }
    
}

extension AppDelegate {
    
    class func sharedInstance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
}
