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
    private let keychainManager: KeychainRecordable
    var data: Observable<Updates> {
        return dataSubject.asObservable()
    }

    init(services: SurveyServices,
         keychainManager: KeychainRecordable = KeychainManager.shared) {
        self.services = services
        self.keychainManager = keychainManager
    }
    
    private func renewToken(refreshToken: String) {
        services
            .renewToken(refreshToken: refreshToken)
            .subscribe(onNext: {[weak self] auth in
                self?.keychainManager.saveTokens(auth.accessToken, refreshToken: auth.refreshToken)
                self?.loadSurveys(reloadToken: false)
            }, onError: { [weak self] _ in
                self?.dataSubject.onNext(.requestLogin)
            }).disposed(by: bag)
    }
    
    func loadSurveys(reloadToken: Bool = true) {
        guard let accessToken = keychainManager.getAccessToken(),
              let refreshToken = keychainManager.getRefreshToken() else {
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
    
    func getLoadingSurvey() -> SurveyViewModel {
        return .init(isLoading: true)
    }

}

extension HomeViewModel.Updates: Equatable {
    static func == (lhs: HomeViewModel.Updates, rhs: HomeViewModel.Updates) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none),
             (.requestLogin, .requestLogin):
            return true
        case let (.loadSurvey(list1), .loadSurvey(list2)):
            return list1.first?.survey.title == list2.first?.survey.title
        default:
            return false
        }
    }
}

#if DEBUG
extension HomeViewModel {
    var testHooks: TestHooks {
        .init(target: self)
    }

    class TestHooks {
        let target: HomeViewModel
        init(target: HomeViewModel) {
            self.target = target
        }
        
        var dataSubject: BehaviorSubject<Updates> {
            return target.dataSubject
        }

        func renewToken(refreshToken: String) {
            target.renewToken(refreshToken: refreshToken)
        }
    }
}
#endif
