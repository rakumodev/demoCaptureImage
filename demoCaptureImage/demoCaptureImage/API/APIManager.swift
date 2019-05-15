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
    func login(with idToken: String, and imageURL: String, completion: @escaping(_ success: Bool, _ errorMsg: String?) -> Void) {
        let serverUrl = Environment().configuration(PlistKey.SERVER_URL)
        let loginAPI = ConstantAPI.LOGIN_API
        let requestURLStr = String(format: "%@/%@", serverUrl, loginAPI)
        print(requestURLStr)
        //Prepare parameters
        let params = ["idToken": idToken ,
                      "imageURL": imageURL]
        //Perform multipart form data POST request with Alamofire
        AF.upload(multipartFormData: { (formData) in
            //Append parameters data
            for (key, value) in params {
                formData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: requestURLStr, method: .post).response { (response) in
            if response.error == nil {
                //Make a request successfully
                do {
                    if let responseData = response.data {
                        //Handle repsonse data
                        guard let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                            completion(false, "Cannot serializable json object")
                            return
                        }
                        print(responseJSON)
                        if let statusCode = responseJSON["statusCode"] as? Int, statusCode == 200 {
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
                //Make a request failure
                completion(false, response.error?.localizedDescription ?? "")
            }
        }
    }

}
