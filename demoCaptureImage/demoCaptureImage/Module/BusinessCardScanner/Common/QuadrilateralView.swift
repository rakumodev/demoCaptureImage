import Foundation
import AVFoundation
import UIKit

/// Simple enum to keep track of the position of the corners of a quadrilateral.
enum CornerPosition {
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft
}

/// The `QuadrilateralView` is a simple `UIView` subclass that can draw a quadrilateral, and optionally edit it.
class QuadrilateralView: UIView {

    let quadLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 1.0
        layer.opacity = 1.0
        layer.isHidden = true

        return layer
    }()

    /// We want the corner views to be displayed under the outline of the quadrilateral.
    /// Because of that, we need the quadrilateral to be drawn on a UIView above them.
    let quadView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// The quadrilateral drawn on the view.
    var quads: [Quadrilateral]?
    var quadPrevious: Quadrilateral?
    var quadSelected: Quadrilateral?
    
    var editable = false {
        didSet {
            cornerViews(hidden: !editable)
            quadLayer.fillColor = editable ? UIColor(white: 0.0, alpha: 0.6).cgColor : UIColor(white: 1.0, alpha: 0.5).cgColor
            guard let quads = quads else {
                return
            }
            drawQuad(quads, animated: false)
            quads.forEach { (quad) in
                layoutCornerViews(forQuad: quad)
            }
        }
    }

    var isHighlighted = false {
        didSet (oldValue) {
            guard oldValue != isHighlighted else {
                return
            }
            quadLayer.fillColor = isHighlighted ? UIColor.clear.cgColor : UIColor(white: 0.0, alpha: 0.6).cgColor
            isHighlighted ? bringSubviewToFront(quadView) : sendSubviewToBack(quadView)
        }
    }

    lazy var topLeftCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topLeft)
    }()

    lazy var topRightCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topRight)
    }()

    lazy var bottomRightCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomRight)
    }()

    lazy var bottomLeftCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomLeft)
    }()

    let highlightedCornerViewSize = CGSize(width: 75.0, height: 75.0)
    let cornerViewSize = CGSize(width: 20.0, height: 20.0)
    var combinedPath = CGMutablePath()
    var previousPoint: CGPoint?
    // MARK: - Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInit() {
        addSubview(quadView)
        setupCornerViews()
        setupConstraints()
        quadView.layer.addSublayer(quadLayer)
    }

    func setupConstraints() {
        let quadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: topAnchor),
            quadView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            trailingAnchor.constraint(equalTo: quadView.trailingAnchor)
        ]

        NSLayoutConstraint.activate(quadViewConstraints)
    }

    func setupCornerViews() {
        addSubview(topLeftCornerView)
        addSubview(topRightCornerView)
        addSubview(bottomRightCornerView)
        addSubview(bottomLeftCornerView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard quadLayer.frame != bounds else {
            return
        }

        quadLayer.frame = bounds
        if let quads = quads {
            drawQuadrilateral(quads: quads, animated: false)
        }
    }

    // MARK: - Drawings

    /// Draws the passed in quadrilateral.
    ///
    /// - Parameters:
    ///   - quads: List of quadrilateral to draw on the view. It should be in the coordinates of the current `QuadrilateralView` instance.
    func drawQuadrilateral(quads: [Quadrilateral], animated: Bool) {
        removeQuadrilateral()
        self.quads = quads
        drawQuad(quads, animated: animated)
        if editable {
            cornerViews(hidden: false)
            if let quadSelected = quadSelected {
                layoutCornerViews(forQuad: quadSelected)
            }
        }
    }

    func drawQuad(_ quads: [Quadrilateral], animated: Bool) {
        removeQuadrilateral()
        quads.forEach { (quad) in
            
            var path = quad.path
            
            if editable {
                path = path.reversing()
                let rectPath = UIBezierPath(rect: bounds)
                path.append(rectPath)
            }
            combinedPath.addPath(path.cgPath)
        }
//        if animated == false {
//            let pathAnimation = CABasicAnimation(keyPath: "path")
//            pathAnimation.duration = 0.2
//            quadLayer.add(pathAnimation, forKey: "path")
//        }
        quadLayer.path = combinedPath
        quadLayer.isHidden = false

    }

    func layoutCornerViews(forQuad quad: Quadrilateral) {
        topLeftCornerView.center = quad.topLeft
        topRightCornerView.center = quad.topRight
        bottomLeftCornerView.center = quad.bottomLeft
        bottomRightCornerView.center = quad.bottomRight
    }

    func removeQuadrilateral() {
        combinedPath = CGMutablePath()
        quadLayer.path = nil
        quadLayer.isHidden = true
    }
    
    func editNextQuad() -> Bool {
        cornerViews(hidden: false)
        for index in 0..<(quads ?? []).count where quads?[index].editable == false {
            quads?[index].editable = true
            quadPrevious = quads?[index]
            break
        }
        let filter = (quads ?? []).filter {$0.editable == false}
        if filter.count == 0 {
            return false
        } else {
            if let quad = filter.first {
                quadSelected = quad
                layoutCornerViews(forQuad: quad)
            }
            return true
        }
    }
    
    func editPrevQuad() -> Bool {
        for index in 0..<(quads?.reversed() ?? []).count where quads?[index].editable == true {
            quads?[index].editable = false
            if let quad = quads?[index] {
                quadSelected = quad
                layoutCornerViews(forQuad: quad)
            }
            let filter = (quads ?? []).filter {$0.editable == true}
            print("count = \(filter.count)")
            if index < (quads?.reversed() ?? []).count - 2 {
                quadPrevious = quads?[index + 1]
                return true
            } else {
                return false
            }
        }
        return false
    }

    // MARK: - Actions

    func moveCorner(cornerView: EditScanCornerView, atPoint point: CGPoint) {
        guard let quads = quads else {
            return
        }
        let validPoint = self.validPoint(point, forCornerViewOfSize: cornerView.bounds.size, inView: self)

         cornerView.center = validPoint
        var updatedQuads: [Quadrilateral] = []
        quads.forEach { (quad) in
            if quad == quadSelected && quad.checkPoint(previousPoint ?? point) {
                let updatedQuad = update(quad, withPosition: validPoint, forCorner: cornerView.position)
                quadSelected = updatedQuad
                updatedQuads.append(updatedQuad)
            } else {
                updatedQuads.append(quad)
            }
        }
        previousPoint = point
        self.quads = updatedQuads
        drawQuad(updatedQuads, animated: false)
    }

    func highlightCornerAtPosition(position: CornerPosition, with image: UIImage) {
        guard editable else {
            return
        }
        isHighlighted = true

        let cornerView = cornerViewForCornerPosition(position: position)
        guard cornerView.isHighlighted == false else {
            cornerView.highlightWithImage(image)
            return
        }

        let origin = CGPoint(x: cornerView.frame.origin.x - (highlightedCornerViewSize.width - cornerViewSize.width) / 2.0,
                             y: cornerView.frame.origin.y - (highlightedCornerViewSize.height - cornerViewSize.height) / 2.0)
        cornerView.frame = CGRect(origin: origin, size: highlightedCornerViewSize)
        cornerView.highlightWithImage(image)
    }

    func resetHighlightedCornerViews() {
        isHighlighted = false
        resetHighlightedCornerViews(cornerViews: [topLeftCornerView, topRightCornerView, bottomLeftCornerView, bottomRightCornerView])
    }

    func resetHighlightedCornerViews(cornerViews: [EditScanCornerView]) {
        cornerViews.forEach { (cornerView) in
            resetHightlightedCornerView(cornerView: cornerView)
        }
    }

    func resetHightlightedCornerView(cornerView: EditScanCornerView) {
        cornerView.reset()
        let origin = CGPoint(x: cornerView.frame.origin.x + (cornerView.frame.size.width - cornerViewSize.width) / 2.0,
                             y: cornerView.frame.origin.y + (cornerView.frame.size.height - cornerViewSize.width) / 2.0)
        cornerView.frame = CGRect(origin: origin, size: cornerViewSize)
        cornerView.setNeedsDisplay()
    }

    // MARK: Validation

    /// Ensures that the given point is valid - meaning that it is within the bounds of the passed in `UIView`.
    ///
    /// - Parameters:
    ///   - point: The point that needs to be validated.
    ///   - cornerViewSize: The size of the corner view representing the given point.
    ///   - view: The view which should include the point.
    /// - Returns: A new point which is within the passed in view.
    func validPoint(_ point: CGPoint, forCornerViewOfSize cornerViewSize: CGSize, inView view: UIView) -> CGPoint {
        var validPoint = point

        if point.x > view.bounds.width {
            validPoint.x = view.bounds.width
        } else if point.x < 0.0 {
            validPoint.x = 0.0
        }

        if point.y > view.bounds.height {
            validPoint.y = view.bounds.height
        } else if point.y < 0.0 {
            validPoint.y = 0.0
        }

        return validPoint
    }

    // MARK: - Convenience

    func cornerViews(hidden: Bool) {
        topLeftCornerView.isHidden = hidden
        topRightCornerView.isHidden = hidden
        bottomRightCornerView.isHidden = hidden
        bottomLeftCornerView.isHidden = hidden
    }

    func update(_ quad: Quadrilateral, withPosition position: CGPoint, forCorner corner: CornerPosition) -> Quadrilateral {
        var quad = quad

        switch corner {
        case .topLeft:
            quad.topLeft = position
        case .topRight:
            quad.topRight = position
        case .bottomRight:
            quad.bottomRight = position
        case .bottomLeft:
            quad.bottomLeft = position
        }

        return quad
    }

    func cornerViewForCornerPosition(position: CornerPosition) -> EditScanCornerView {
        switch position {
        case .topLeft:
            return topLeftCornerView
        case .topRight:
            return topRightCornerView
        case .bottomLeft:
            return bottomLeftCornerView
        case .bottomRight:
            return bottomRightCornerView
        }
    }
}
