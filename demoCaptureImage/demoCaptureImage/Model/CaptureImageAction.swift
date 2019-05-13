//
//  CaptureImageAction.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/13/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import UIKit

class CaptureImageAction: ActionModel {
    
    override init() {
        super.init()
        self.title = "Capture Image"
        self.icon = UIImage.init(named: "captureImage_icon")
        self.action = .CAPTURE_IMAGE
    }
    
}
