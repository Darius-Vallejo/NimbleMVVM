//
//  Coordinator.swift
//  nimble
//
//  Created by darius vallejo on 11/8/23.
//

import Foundation
import UIKit

enum CoordinatorCompletion {
    case loggedUser(auth: AuthModel)
}

enum Module {
    case login
    case detail(viewModel: SurveyViewModel)
}

protocol Coordinator {
    var entry: UINavigationController? { get }
    var onFinish: (() -> Void)? { get set }
    static func start(keychainManager: KeychainRecordable) -> Coordinator
    func finish(completion: CoordinatorCompletion)
    func open(module: Module)
}

extension Coordinator {
    func open(module: Module) { }
}
