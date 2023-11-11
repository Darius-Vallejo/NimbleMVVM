//
//  HomeCoordinator.swift
//  Nimble
//
//  Created by darius vallejo on 11/11/23.
//

import Foundation
import UIKit

class HomeCoordinator: Coordinator {
    weak var entry: UINavigationController?
    
    static func start() -> Coordinator {
        var router = HomeCoordinator()
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
