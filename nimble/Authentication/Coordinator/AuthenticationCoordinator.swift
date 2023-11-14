//
//  AuthenticationCoordinator.swift
//  nimble
//
//  Created by darius vallejo on 11/8/23.
//

import Foundation
import UIKit

class AuthenticationCoordinator: Coordinator {
    weak var entry: UINavigationController?
    var onFinish: (() -> Void)?
    
    static func start(keychainManager: KeychainRecordable = KeychainManager.shared) -> Coordinator {
        let router = AuthenticationCoordinator()
        let viewModel = LoginViewModel(services: Services.shared())
        let loginController = LoginViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: loginController)
        loginController.coordinator = router
        router.entry = navigationController

        return router
    }
    
    func finish(completion: CoordinatorCompletion) {
        entry?.dismiss(animated: true)
        onFinish?()
    }

}
