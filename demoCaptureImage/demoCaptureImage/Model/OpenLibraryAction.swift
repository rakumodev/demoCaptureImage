//
//  OpenLibraryAction.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/13/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import UIKit

class OpenLibraryAction: ActionModel {

    override init() {
        super.init()
        self.title = "Open Library"
        self.icon = UIImage.init(named: "openLibrary_icon")
        self.action = .OPEN_LIBRARY
    }

}
