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
    var data: Observable<Updates> {
        return dataSubject.asObservable()
    }

    init(services: UserServices) {
        self.services = services
    }

    func login(email: String, password: String) {
        services
            .login(email: email, password: password)
            .map { auth in
                KeychainManager.shared.saveTokens(auth.accessToken, refreshToken: auth.refreshToken)
                return Updates.finishWith(authentication: auth)
            }
            .bind(to: dataSubject)
            .disposed(by: bag)
    }
    
}
