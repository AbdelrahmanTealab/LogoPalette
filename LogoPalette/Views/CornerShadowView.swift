import UIKit

final class CornerShadowView: UIView {

    private var shadowLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 4

            layer.insertSublayer(shadowLayer, at: 0)
            
        }
    }

}


//cellView.clipsToBounds = true
//
//cellView.layer.shadowColor = UIColor.black.cgColor
//cellView.layer.shadowRadius = 3.0
//cellView.layer.shadowOpacity = 1
//cellView.layer.masksToBounds = false
