//
//  LoginViewController.swift
//  nimble
//
//  Created by darius vallejo on 11/8/23.
//

import Foundation
import UIKit
import RxSwift

class LoginViewController: UIViewController {
    var coordinator: Coordinator?
    let bag = DisposeBag()
    let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let backgroundView: UIView = {
        let backgroundContainer = UIView()
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "background")
        backgroundContainer.addSubview(imageView, yConstant: 0, xConstant: 0)
        
        return backgroundContainer
    }()
    
    private let logo: UIImageView = {
        let textField = UIImageView()
        textField.image = UIImage(named: "logo")
        textField.contentMode = .scaleAspectFit
        return textField
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.text = "your_email@example.com"
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.18)
        textField.font = UIFont.customFont(type: .normal, size: 17)
        textField.layer.cornerRadius = 12
        textField.textColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 56)
        ])
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.text = "12345678"
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.18)
        textField.font = UIFont.customFont(type: .normal, size: 17)
        textField.layer.cornerRadius = 12
        textField.textColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 56)
        ])
        return textField
    }()

    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.titleLabel?.font = UIFont.customFont(type: .heavy, size: 18)
        button.setTitleColor(UIColor(red: 21/255,
                                     green: 21/255,
                                     blue: 26/255,
                                     alpha: 1), for: .normal)
        button.layer.cornerRadius = 5
        button.layer.backgroundColor = UIColor(red: 1,
                                               green: 1,
                                               blue: 1,
                                               alpha: 1).cgColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 56)
        ])
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupViews()
    }

    private func setupViewModel() {
        viewModel
            .data
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                switch $0 {
                case .finishWith(authentication: let auth):
                    self?.coordinator?.finish(completion: .loggedUser(auth: auth))
                case .none:
                    break
                }
            })
            .disposed(by: bag)
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
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0,
                                                                              b: 1,
                                                                              c: -1,
                                                                              d: 0,
                                                                              tx: 0.5,
                                                                              ty: 0))
        return layer0
    }
    
    private func setupBackgroundLayer() {
        view.layoutIfNeeded()
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(backgroundView, yConstant: 0, xConstant: 0)
        let layer0 = backgroundLayer()
        layer0.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width,
                                            dy: -0.5*view.bounds.size.height)
        layer0.position = view.center
        backgroundView.layer.addSublayer(layer0)
        backgroundView.addSubview(blurEffectView, yConstant: 0, xConstant: 0)
    }

    private func setupViews() {
        let spaceView = UIView()
        spaceView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spaceView.heightAnchor.constraint(equalToConstant: 109)
        ])
        let stackView = UIStackView(arrangedSubviews: [logo,
                                                       spaceView,
                                                       usernameTextField,
                                                       passwordTextField,
                                                       loginButton,
                                                       UIView()])
        stackView.axis = .vertical
        stackView.spacing = 20

        setupBackgroundLayer()
        let stackContainer = UIView()
        stackContainer.addSubview(stackView, yConstant: 0, xConstant: 0)
        view.addSubview(stackContainer, yConstant: 153, xConstant: 24)
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    @objc private func loginButtonTapped() {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text else {
            return
        }

        viewModel.login(email: username, password: password)
    }
}
