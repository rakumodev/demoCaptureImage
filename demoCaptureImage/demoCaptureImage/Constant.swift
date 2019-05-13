//
//  Constant.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/10/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import Foundation

enum RequestMethod: String {
    case POST = "POST"
    case GET = "GET"
}

struct Constant {
    static let SEVER_API_URL = "http://192.168.1.89:81/check-api/v1/login-with-google"
    static let GOOGLE_CLIENT_ID = "295425154996-9bmdofgb2619o6pc8q3gbq27o2bpa5eo.apps.googleusercontent.com"
    static let LOGGED_IN = "logged_in"
    static let LOGIN_SCREEN_IDENTIFER = "LoginViewController"
    static let HOME_SCREEN_IDENTIFER = "HomeViewController"
}

