//
//  LoginViewModel.swift
//  Nimble
//
//  Created by darius vallejo on 11/11/23.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {

    enum Updates {
        case none
        case finishWith(authentication: AuthModel)
    }

    private let services: UserServices
    private let bag = DisposeBag()
    private let dataSubject = BehaviorSubject<Updates>(value: .none)
    private let keychainManager: KeychainRecordable
    var data: Observable<Updates> {
        return dataSubject.asObservable()
    }

    init(services: UserServices,
         keychainManager: KeychainRecordable = KeychainManager.shared) {
        self.services = services
        self.keychainManager = keychainManager
    }

    func login(email: String, password: String) {
        services
            .login(email: email, password: password)
            .map { [weak self] auth in
                self?.keychainManager.saveTokens(auth.accessToken,
                                                 refreshToken: auth.refreshToken)
                return Updates.finishWith(authentication: auth)
            }
            .bind(to: dataSubject)
            .disposed(by: bag)
    }
    
}

extension LoginViewModel.Updates: Equatable {
    static func == (lhs: LoginViewModel.Updates, rhs: LoginViewModel.Updates) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.finishWith(authentication), .finishWith(rhsAuthentication)):
            return authentication.accessToken == rhsAuthentication.accessToken
        default:
            return false
        }
    }
}

#if DEBUG
extension LoginViewModel {
    var testHooks: TestHooks {
        .init(target: self)
    }

    class TestHooks {
        let target: LoginViewModel
        init(target: LoginViewModel) {
            self.target = target
        }
        
        var dataSubject: BehaviorSubject<Updates> {
            return target.dataSubject
        }
    }
}
#endif
