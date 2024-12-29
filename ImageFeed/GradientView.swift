import Foundation
import UIKit

final class GradientView: UIView {

    // MARK: - Private Properties

    private let gradientLayer = CAGradientLayer()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    // MARK: - Overrides Methods

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    // MARK: - Private Methods

    private func setupGradient() {
        self.layer.addSublayer(gradientLayer)
        gradientLayer.colors = [UIColor.gradientColor2.cgColor,UIColor.gradientColor1.cgColor]
    }
}
