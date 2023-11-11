//
//  AuthenticationCoordinator.swift
//  nimble
//
//  Created by darius vallejo on 11/8/23.
//

import Foundation
import UIKit

struct AuthenticationCoordinator: Coordinator {
    weak var entry: UINavigationController?
    
    static func start() -> Coordinator {
        var router = AuthenticationCoordinator()
        let viewModel = LoginViewModel(services: Services.shared())
        let loginController = LoginViewController(viewModel: viewModel)
        let initialViewController = UIViewController()
        let home = HomePageViewController(transitionStyle: .scroll,
                                          navigationOrientation: .horizontal)
        let navigationController = UINavigationController(rootViewController: home)
        loginController.coordinator = router
        router.entry = navigationController

        return router
    }
    
    func finish(completion: CoordinatorCompletion) {
        entry?.popToRootViewController(animated: false)
        let viewController = UIViewController()
        viewController.view.backgroundColor = .red
        entry?.present(viewController, animated: true)
    }

}
