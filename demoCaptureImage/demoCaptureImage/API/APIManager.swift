//
//  ServiceManager.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/14/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import Foundation
import Alamofire
import ProgressHUD

class APIManager {

    static let sharedInstance = APIManager()

    //Login API with our server
    func login(with email: String, completion: @escaping(_ success: Bool, _ errorMsg: String?) -> Void) {
        let serverUrl = Environment().configuration(PlistKey.SERVER_URL)
        let loginAPI = ConstantAPI.LOGIN_API
        let requestURLStr = String(format: "%@%@", serverUrl, loginAPI)
        print(requestURLStr)
        do {
            //Prepare parameters
            let params = ["email": email]
            print(params)
            //Prepare data
            let data = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            //Create a authentication POST request to our server
            AF.upload(data, to: requestURLStr, method: .post, headers: ["Content-Type": "application/json"]).response { (response) in
                if response.error == nil {
                    //Our server responses without any error
                    do {
                        if let responseData = response.data {
                            //Handle repsonse data
                            guard let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                                completion(false, "Cannot serializable json object")
                                return
                            }
                            print(responseJSON)
                            if let statusCode = responseJSON["code"] as? Int, statusCode == 200 {
                                //Login successfully
                                completion(true, nil)
                            } else {
                                //Login failure
                                guard let responseMsg = responseJSON["message"] as? String else {
                                    completion(false, "No message")
                                    return
                                }
                                completion(false, responseMsg)
                            }
                        } else {
                            //Null response data
                            completion(false, "Data is nil")
                        }
                    } catch let error as NSError {
                        //Got error while parsing response data
                        completion(false, error.localizedDescription)
                    }
                } else {
                    //Our server responses with some error
                    completion(false, response.error?.localizedDescription ?? "")
                }
            }
        } catch let error as NSError {
            //Error serialize json data
            completion(false, error.localizedDescription)
            print(error.localizedDescription)
        }
    }

}
