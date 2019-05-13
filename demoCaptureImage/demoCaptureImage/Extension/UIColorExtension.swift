//
//  UIColorExtension.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/10/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String, alpha:CGFloat? = 1.0) {
        var hexInt: UInt32 = 0
        let scanner = Scanner(string: hexString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt32(&hexInt)
        
        let red = CGFloat((hexInt & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexInt & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexInt & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
