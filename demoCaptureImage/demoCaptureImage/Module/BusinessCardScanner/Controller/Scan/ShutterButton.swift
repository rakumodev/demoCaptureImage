//
//  ShutterButton.swift
//  demoCaptureImage
//
//  Created by phat nguyen on 5/13/19.
//  Copyright © 2019 phatnt. All rights reserved.
//

import UIKit

/// A simple button used for the shutter.
class ShutterButton: UIControl {
    
    let outterRingLayer = CAShapeLayer()
    let innerCircleLayer = CAShapeLayer()
    
    let outterRingRatio: CGFloat = 0.80
    let innerRingRatio: CGFloat = 0.75
    
    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted {
                animateInnerCircleLayer(forHighlightedState: isHighlighted)
            }
        }
    }
    
    // MARL: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(outterRingLayer)
        layer.addSublayer(innerCircleLayer)
        backgroundColor = .clear
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.button
        impactFeedbackGenerator.prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        outterRingLayer.frame = rect
        outterRingLayer.path = pathForOutterRing(inRect: rect).cgPath
        outterRingLayer.fillColor = UIColor.white.cgColor
        outterRingLayer.rasterizationScale = UIScreen.main.scale
        outterRingLayer.shouldRasterize = true
        
        innerCircleLayer.frame = rect
        innerCircleLayer.path = pathForInnerCircle(inRect: rect).cgPath
        innerCircleLayer.fillColor = UIColor.white.cgColor
        innerCircleLayer.rasterizationScale = UIScreen.main.scale
        innerCircleLayer.shouldRasterize = true
    }
    
    // MARK: - Animation
    
    func animateInnerCircleLayer(forHighlightedState isHighlighted: Bool) {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        var values = [CATransform3DMakeScale(1.0, 1.0, 1.0), CATransform3DMakeScale(0.9, 0.9, 0.9), CATransform3DMakeScale(0.93, 0.93, 0.93), CATransform3DMakeScale(0.9, 0.9, 0.9)]
        if isHighlighted == false {
            values = [CATransform3DMakeScale(0.9, 0.9, 0.9), CATransform3DMakeScale(1.0, 1.0, 1.0)]
        }
        animation.values = values
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.duration = isHighlighted ? 0.35 : 0.10
        
        innerCircleLayer.add(animation, forKey: "transform")
        impactFeedbackGenerator.impactOccurred()
    }
    
    // MARK: - Paths
    
    func pathForOutterRing(inRect rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath(ovalIn: rect)
        
        let innerRect = rect.scaleAndCenter(withRatio: outterRingRatio)
        let innerPath = UIBezierPath(ovalIn: innerRect).reversing()
        
        path.append(innerPath)
        
        return path
    }
    
    func pathForInnerCircle(inRect rect: CGRect) -> UIBezierPath {
        let rect = rect.scaleAndCenter(withRatio: innerRingRatio)
        let path = UIBezierPath(ovalIn: rect)
        
        return path
    }
    
}
