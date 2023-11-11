//
//  LoginViewModel.swift
//  nimble
//
//  Created by darius vallejo on 11/8/23.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    
    enum Updates {
        case none
        case requestLogin
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
    
    func loadSurveys() {
        guard let accessToken = KeychainManager.shared.getAccessToken(),
           let refreshToken = KeychainManager.shared.getRefreshToken() else {
            dataSubject.onNext(.requestLogin)
            return
        }   
    }

}
