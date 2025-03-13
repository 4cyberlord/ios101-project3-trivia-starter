import UIKit

@IBDesignable
class GradientView: UIView {
    @IBInspectable var startColor: UIColor = .white {
        didSet {
            updateGradient()
        }
    }

    @IBInspectable var endColor: UIColor = .white {
        didSet {
            updateGradient()
        }
    }

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    private func setupGradient() {
        layer.insertSublayer(gradientLayer, at: 0)
        updateGradient()
    }

    private func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
