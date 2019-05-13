//
//  Environment.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/9/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import Foundation

enum PlistKey {
    case LABEL_COLOR
    case BACKGROUND_COLOR
    var value: String {
        switch self {
        case .LABEL_COLOR:
            return "LABEL_COLOR"
        case .BACKGROUND_COLOR:
            return "BACKGROUND_COLOR"
        }
    }
}

struct Environment {
    
    var infoDict: [String: Any] {
        get {
            if let dict = Bundle.main.infoDictionary {
                return dict
            }
            fatalError("Plist file not found")
        }
    }
    
    func configuration(_ key: PlistKey) -> String {
        switch key {
        case .LABEL_COLOR:
            return infoDict[PlistKey.LABEL_COLOR.value] as! String
        case .BACKGROUND_COLOR:
            return infoDict[PlistKey.BACKGROUND_COLOR.value] as! String
        }
    }
}
