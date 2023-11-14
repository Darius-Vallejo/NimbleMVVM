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
    var onFinish: (() -> Void)?
    
    static func start(keychainManager: KeychainRecordable = KeychainManager.shared) -> Coordinator {
        let router = HomeCoordinator()
        let viewModel = HomeViewModel(services: Services.shared(), keychainManager: keychainManager)
        let homeController = HomePageViewController(viewModel: viewModel, transitionStyle: .scroll)
        let navigationController = UINavigationController(rootViewController: homeController)
        homeController.coordinator = router
        router.entry = navigationController
        
        return router
    }
    
    func open(module: Module) {
        switch module {
        case .login:
            var router = AuthenticationCoordinator.start()
            if let authenticatorNavigation = router.entry {
                authenticatorNavigation.modalPresentationStyle = .fullScreen
                entry?.present(authenticatorNavigation, animated: true)
                router.onFinish = {[weak self] in
                    self?.handleAuthenticationCompletion()
                }
            }
        case .detail(let viewModel):
            let viewController = DetailViewController(viewModel: viewModel)
            entry?.pushViewController(viewController, animated: true)
        }
    }
    
    func finish(completion: CoordinatorCompletion) { }
    
    // Reloading surveys in the HomeViewModel
    // Aaccessing the viewModel from the entry point
    // and calling a method to trigger the reload
    private func handleAuthenticationCompletion() {
        if let homeViewController = entry?.viewControllers.first as? HomePageViewController {
            homeViewController.viewModel.loadSurveys()
        }
    }
}

#if DEBUG
extension HomeCoordinator {
    var testHooks: TestHooks {
        .init(target: self)
    }

    class TestHooks {
        let target: HomeCoordinator
        init(target: HomeCoordinator) {
            self.target = target
        }

        func handleAuthenticationCompletion() {
            target.handleAuthenticationCompletion()
        }
    }
}
#endif
