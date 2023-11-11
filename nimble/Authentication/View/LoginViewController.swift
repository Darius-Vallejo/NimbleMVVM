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
    
    private var viewModel: LoginViewModel {
        didSet {
            viewModel
                .data
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
    }
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.text = "your_email@example.com"
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.text = "12345678"
        return textField
    }()

    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 5
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupActions()
    }

    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [usernameTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)
        ])
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }

    @objc private func loginButtonTapped() {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text else {
            // Handle empty text fields error
            return
        }

        viewModel.login(email: username, password: password)
//        if viewModel.validateCredentials(username: username, password: password) {
//            viewModel.login(username: username, password: password) { success, error in
//                if success {
//                    // Handle successful login
//                    coordinator?.didLogin()
//                } else {
//                    // Handle login error
//                    if let error = error {
//                        // Display error message to the user
//                        print("Login Error: \(error.localizedDescription)")
//                    }
//                }
//            }
//        } else {
//            // Handle invalid credentials error
//            print("Invalid credentials")
//        }
    }
}
