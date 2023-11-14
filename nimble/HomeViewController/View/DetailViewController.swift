//
//  DetailViewController.swift
//  Nimble
//
//  Created by darius vallejo on 11/14/23.
//

import Foundation
import UIKit
import RxSwift

class DetailViewController: UIViewController {
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

    private func topStackView() -> UIView {
        let titleLabel = createLabel(withText: viewModel.survey.title,
                                     size: 34)
        let subtitleLabel = createLabel(withText: viewModel.survey.description,
                                        size: 17,
                                        type: .normal)
        
        let topStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        topStackView.axis = .vertical
        topStackView.spacing = 16
        topStackView.distribution = .equalCentering
        let topContainer = UIView()
        topContainer.addSubview(topStackView, yConstant: 108, xConstant: 20)
        return topContainer
    }
    
    private func setupUI() {
        let topStackView = topStackView()
        let mainStackView = UIStackView(arrangedSubviews: [topStackView,
                                                           UIView()])
        mainStackView.axis = .vertical
        mainStackView.spacing = 32
        mainStackView.distribution = .fill
        
        let container = UIView()
        let backgroundContainer = backgroundView()

        container.addSubview(mainStackView, yConstant: 0, xConstant: 0)
        view.addSubview(backgroundContainer, yConstant: 0, xConstant: 0)
        view.addSubview(container, yConstant: 60, xConstant: 16)
        view.layer.masksToBounds = true
        view.layoutIfNeeded()
        let layer0 = backgroundLayer()
        layer0.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)
        layer0.position = view.center
        backgroundContainer.layer.addSublayer(layer0)
    }
}

#if DEBUG
extension DetailViewController {
    var testHooks: TestHooks {
        .init(target: self)
    }

    class TestHooks {
        let target: DetailViewController
        init(target: DetailViewController) {
            self.target = target
        }
        
        func backgroundLayer() -> CAGradientLayer {
            return target.backgroundLayer()
        }
        
        func backgroundView() -> UIView {
            return target.backgroundView()
        }
        
        func topStackView() -> UIView {
            return target.topStackView()
        }
        
        func setupUI() {
            target.setupUI()
        }
    }
}
#endif
