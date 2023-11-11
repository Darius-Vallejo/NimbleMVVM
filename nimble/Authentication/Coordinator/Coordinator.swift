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

protocol Coordinator {
    var entry: UINavigationController? { get }
    static func start() -> Coordinator
    func finish(completion: CoordinatorCompletion)
}
