//
//  HomeViewModel.swift
//  nimble
//
//  Created by darius vallejo on 11/8/23.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {
    
    enum Updates {
        case none
        case requestLogin
        case loadSurvey(list: [SurveyViewModel])
    }
    
    private var services: SurveyServices
    private let bag = DisposeBag()
    private let dataSubject = BehaviorSubject<Updates>(value: .none)
    var data: Observable<Updates> {
        return dataSubject.asObservable()
    }

    init(services: SurveyServices) {
        self.services = services
    }
    
    private func renewToken(refreshToken: String) {
        services
            .renewToken(refreshToken: refreshToken)
            .subscribe(onNext: {[weak self] auth in
                KeychainManager
                    .shared
                    .saveTokens(auth.accessToken, refreshToken: auth.refreshToken)
                self?.loadSurveys(reloadToken: false)
            }, onError: { [weak self] _ in
                self?.dataSubject.onNext(.requestLogin)
            }).disposed(by: bag)
    }
    
    func loadSurveys(reloadToken: Bool = true) {
        guard let accessToken = KeychainManager.shared.getAccessToken(),
              let refreshToken = KeychainManager.shared.getRefreshToken() else {
            dataSubject.onNext(.requestLogin)
            return
        }

        services.auth = .init(accessToken: accessToken, refreshToken: refreshToken)
        services
            .getSurveyList()
            .subscribe(onNext: {[weak self] list in
                self?.dataSubject.onNext(.loadSurvey(list: list
                    .enumerated()
                    .map({ .init(survey: $0.element,
                                 index: $0.offset,
                                 surveysQuantity: list.count) })))
            }, onError: { [weak self] customError in
                if let networkError = customError as? NetworkErrors,
                    case .detailed(let errors) = networkError,
                   errors.errors.first(where: { $0.code == .invalidToken }) != nil {
                    self?.renewToken(refreshToken: refreshToken)
                } else {
                    self?.dataSubject.onNext(.requestLogin)
                }
            }).disposed(by: bag)
    }

}
