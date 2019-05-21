//
//  LogoutAction.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/13/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import UIKit

class LogoutAction: ActionModel {

    override init() {
        super.init()
        self.title = "Logout"
        self.icon = UIImage.init(named: "logout_icon")
        self.action = .LOGOUT
    }

}
