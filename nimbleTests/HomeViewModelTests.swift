//
//  HomeViewModelTests.swift
//  NimbleTests
//
//  Created by darius vallejo on 11/14/23.
//

import XCTest
import RxSwift
import RxTest
@testable import Nimble

class HomeViewModelTests: XCTestCase {

    var viewModel: HomeViewModel!
    fileprivate var servicesMock: SurveyServicesMock!
    fileprivate var keychainManagerMock: KeychainRecordableMock!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        servicesMock = SurveyServicesMock()
        keychainManagerMock = KeychainRecordableMock()
        viewModel = HomeViewModel(services: servicesMock, keychainManager: keychainManagerMock)
    }

    func testLoadSurveysSuccess() {
        // Given
        let surveys = [SurveyModel(title: "Survey 1",
                                   description: "Description 1",
                                   coverImageUrl: "URL1"),
                       SurveyModel(title: "Survey 2",
                                   description: "Description 2",
                                   coverImageUrl: "URL2")]
        
        keychainManagerMock.saveTokens("T", refreshToken: "T")

        servicesMock.stubbedGetSurveyListResult = .just(surveys)

        // When
        let observer = scheduler.createObserver(HomeViewModel.Updates.self)
        viewModel.data
            .bind(to: observer)
            .disposed(by: disposeBag)

        viewModel.loadSurveys()

        // Then
        scheduler.start()
        XCTAssertEqual(observer.events, [
            .next(0, .none),
            .next(0, .loadSurvey(list: surveys.map { SurveyViewModel(survey: $0, index: 0, surveysQuantity: 2) }))
        ])
    }

    func testLoadSurveysError() {
        // Given
        servicesMock.stubbedGetSurveyListResult = .error(NetworkErrors.unknown)

        // When
        let observer = scheduler.createObserver(HomeViewModel.Updates.self)
        viewModel.data
            .bind(to: observer)
            .disposed(by: disposeBag)

        viewModel.loadSurveys()

        // Then
        scheduler.start()
        XCTAssertEqual(observer.events, [
            .next(0, .none),
            .next(0, .requestLogin)
        ])
    }
    
    func testRenewTokenSuccess() {
         // Given
         let auth = AuthModel(accessToken: "newAccessToken", refreshToken: "newRefreshToken")
         servicesMock.stubbedRenewTokenResult = .just(auth)
        let surveys = [SurveyModel(title: "Survey 1",
                                   description: "Description 1",
                                   coverImageUrl: "URL1"),
                       SurveyModel(title: "Survey 2",
                                   description: "Description 2",
                                   coverImageUrl: "URL2")]

        servicesMock.stubbedGetSurveyListResult = .just(surveys)

         // When
        viewModel.testHooks.renewToken(refreshToken: "oldRefreshToken")

         // Then
        XCTAssertEqual(keychainManagerMock.getAccessToken(), "newAccessToken")
        XCTAssertEqual(keychainManagerMock.getRefreshToken(), "newRefreshToken")
        XCTAssertTrue(servicesMock.renewTokenCalled)
     }

     func testRenewTokenError() throws {
         // Given
         servicesMock.stubbedRenewTokenResult = .error(NetworkErrors.unknown)

         // When
         viewModel.testHooks.renewToken(refreshToken: "oldRefreshToken")
         let data = try XCTUnwrap(viewModel.testHooks.dataSubject.value())

         // Then
         XCTAssertEqual(data, .requestLogin)
     }
    
}

// Mock classes for testing
class SurveyServicesMock: SurveyServices {
    
    var auth: AuthModel?
    var stubbedGetSurveyListResult: Single<[SurveyModel]>!
    var stubbedRenewTokenResult: Single<AuthModel>!
    var renewTokenCalled: Bool = false

    func getSurveyList() -> RxSwift.Observable<[SurveyModel]> {
        return stubbedGetSurveyListResult.asObservable()
    }
    
    func renewToken(refreshToken: String) -> RxSwift.Observable<AuthModel> {
        renewTokenCalled = true
        return stubbedRenewTokenResult.asObservable()
    }
}

fileprivate class KeychainRecordableMock: KeychainRecordable {
    var stubbedGetAccessToken: String?
    var stubbedGetRefreshToken: String?

    func getAccessToken() -> String? {
        return stubbedGetAccessToken
    }

    func getRefreshToken() -> String? {
        return stubbedGetRefreshToken
    }

    func saveTokens(_ accessToken: String, refreshToken: String) {
        stubbedGetRefreshToken = refreshToken
        stubbedGetAccessToken = accessToken
    }
}

