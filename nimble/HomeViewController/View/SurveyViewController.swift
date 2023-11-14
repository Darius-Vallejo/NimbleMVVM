//
//  SurveyViewController.swift
//  Nimble
//
//  Created by darius vallejo on 11/11/23.
//

import Foundation
import UIKit
import RxSwift

class SurveyViewController: UIViewController {
    let viewModel: SurveyViewModel
    private let bag = DisposeBag()
    
    init(viewModel: SurveyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func backgroundLayer() -> CAGradientLayer {
        let layer0 = CAGradientLayer()
        layer0.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        ]
        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 0.5, ty: 0))
        return layer0
    }
    
    private func backgroundView() -> UIView {
        let backgroundContainer = UIView()
        backgroundContainer.alpha = 0.6
        backgroundContainer.layer.masksToBounds = true

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.load(from: viewModel.survey.hightDefinitionCoverImage, bag: bag)
        backgroundContainer.addSubview(imageView, yConstant: 0, xConstant: 0)
        return backgroundContainer
    }
    
    private func buttonDetail() -> UIView {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(UIImage(named: "goToDetail"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 27
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 56),
            button.widthAnchor.constraint(equalToConstant: 56)
        ])
        return button
    }
    
    private func topStackView() -> UIView {
        let titleLabel = createLabel(withText: viewModel.dateTile.dateFormatted,
                                     size: 13)
        let subtitleLabel = createLabel(withText: viewModel.dateTile.today,
                                        size: 34)
        
        let ovalImageView = createOvalImageView()
        
        let rightView = UIStackView(arrangedSubviews: [UIView(), ovalImageView, UIView()])
        rightView.axis = .vertical
        rightView.alignment = .center
        rightView.distribution = .equalCentering
        
        let leftStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4
        
        let topStackView = UIStackView(arrangedSubviews: [leftStack, UIView(), rightView])
        topStackView.axis = .horizontal
        topStackView.spacing = 16
        topStackView.distribution = .equalCentering
        let topContainer = UIView()
        topContainer.addSubview(topStackView, yConstant: 16, xConstant: 16)
        return topContainer
    }

    private func bottomStackView() -> UIView {
        let bottomContainer = UIView()
        let smallRoundView = createSmallRoundStack()
        let bottomTitleLabel = createLabel(withText: viewModel.survey.title, size: 28)
        let bottomSubtitleLabel = createLabel(withText: viewModel.survey.description,
                                              size: 17,
                                              type: .normal)
        let button = buttonDetail()
        
        let subtitleContainer = UIStackView(arrangedSubviews: [bottomSubtitleLabel, button])
        subtitleContainer.axis = .horizontal
        subtitleContainer.spacing = 20

        let bottomStackView = UIStackView(arrangedSubviews: [smallRoundView,
                                                             bottomTitleLabel,
                                                             subtitleContainer])
        bottomStackView.axis = .vertical
        bottomStackView.spacing = 16
        
        bottomContainer.addSubview(bottomStackView, yConstant: 16, xConstant: 16)
        return bottomContainer
    }
    
    private func setupUI() {
        let topStackView = topStackView()
        let bottomContainer = bottomStackView()
        let mainStackView = UIStackView(arrangedSubviews: [topStackView,
                                                           UIView(),
                                                           bottomContainer])
        mainStackView.axis = .vertical
        mainStackView.spacing = 32
        mainStackView.distribution = .fill
        
        let container = UIView()
        let backgroundContainer = backgroundView()

        container.addSubview(mainStackView, yConstant: 0, xConstant: 0)
        view.addSubview(backgroundContainer, yConstant: 0, xConstant: 0)
        view.addSubview(container, yConstant: 60, xConstant: 16)

        view.layoutIfNeeded()
        let layer0 = backgroundLayer()
        layer0.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)
        layer0.position = view.center
        backgroundContainer.layer.addSublayer(layer0)
    }
    
    private func createLabel(withText text: String, size: CGFloat, type: UIFont.FontType = .heavy) -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.text = text
        label.font = UIFont.customFont(type: type, size: size)
        return label
    }
    
    private func createOvalImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "userImage")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 18
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 36),
            imageView.widthAnchor.constraint(equalToConstant: 36)
        ])

        return imageView
    }
    
    private func createSmallRoundStack() -> UIStackView {
        let roundViews = Array(0..<viewModel.surveysQuantity + 1).map {
            guard $0+1 <= viewModel.surveysQuantity else {
                return UIView()
            }
            let currentIndex = $0 == viewModel.index
            return createSmallRoundView(isCurrentIndex: currentIndex)
        }
        let stackView = UIStackView(arrangedSubviews: roundViews)
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }
    
    private func createSmallRoundView(isCurrentIndex: Bool) -> UIView {
        let smallRoundView = UIView()
        smallRoundView.backgroundColor = .white
        smallRoundView.alpha = isCurrentIndex ? 1 : 0.3
        smallRoundView.layer.cornerRadius = 4
        smallRoundView.clipsToBounds = true
        NSLayoutConstraint.activate([
            smallRoundView.heightAnchor.constraint(equalToConstant: 8),
            smallRoundView.widthAnchor.constraint(equalToConstant: 8)
        ])
        return smallRoundView
    }
    
    @objc private func buttonTapped() {
        
    }
    
}
