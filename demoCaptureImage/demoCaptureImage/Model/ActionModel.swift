//
//  ActionModel.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/13/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import UIKit

enum ActionType{
    case CAPTURE_IMAGE
    case OPEN_LIBRARY
    case LOGOUT
}

class ActionModel: NSObject {
    var title: String?
    var icon: UIImage?
    var action: ActionType?
    
    override init(){
        
    }
    
    init(title: String,iconName: String,action: ActionType) {
        self.title = title
        self.icon = UIImage.init(named: iconName)
        self.action = action
    }
    
}
