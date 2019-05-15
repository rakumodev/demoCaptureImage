//
//  FocusRectangleView.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/13/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import UIKit

/// A yellow rectangle used to display the last 'tap to focus' point
class FocusRectangleView: UIView {
    convenience init(touchPoint: CGPoint) {
        let originalSize: CGFloat = 200
        let finalSize: CGFloat = 80

        // Here, we create the frame to be the `originalSize`, with it's center being the `touchPoint`.
        self.init(frame: CGRect(x: touchPoint.x - (originalSize / 2), y: touchPoint.y - (originalSize / 2), width: originalSize, height: originalSize))

        backgroundColor = .clear
        layer.borderWidth = 2.0
        layer.cornerRadius = 6.0
        layer.borderColor = UIColor.yellow.cgColor

        // Here, we animate the rectangle from the `originalSize` to the `finalSize` by calculating the difference.
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.frame.origin.x += (originalSize - finalSize) / 2
            self.frame.origin.y += (originalSize - finalSize) / 2

            self.frame.size.width -= (originalSize - finalSize)
            self.frame.size.height -= (originalSize - finalSize)
        })
    }

}
