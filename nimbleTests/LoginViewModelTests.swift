//
//  LoginViewModelTests.swift
//  NimbleTests
//
//  Created by darius vallejo on 11/14/23.
//

import XCTest
import RxSwift
import RxTest
@testable import Nimble

class LoginViewModelTests: XCTestCase {

    var viewModel: LoginViewModel!
    fileprivate var servicesMock: UserServicesMock!
    fileprivate var keychainManagerMock: KeychainRecordableMock!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        servicesMock = UserServicesMock()
        keychainManagerMock = KeychainRecordableMock()
        viewModel = LoginViewModel(services: servicesMock, keychainManager: keychainManagerMock)
    }

    func testLoginSuccess() throws {
        // Given
        let auth = AuthModel(accessToken: "accessToken", refreshToken: "refreshToken")
        servicesMock.stubbedLoginResult = .just(auth)

        // When
        viewModel.login(email: "test@example.com", password: "password")

        // Then
        let data = try XCTUnwrap(viewModel.testHooks.dataSubject.value())
        XCTAssertEqual(data,
                       .finishWith(authentication: auth))
        XCTAssertEqual(keychainManagerMock.savedTokens?.accessToken, "accessToken")
        XCTAssertEqual(keychainManagerMock.savedTokens?.refreshToken, "refreshToken")
    }

    func testLoginError() throws {
        // Given
        servicesMock.stubbedLoginResult = .error(NetworkErrors.unknown)

        // When
        viewModel.login(email: "test@example.com", password: "password")
        let observer = scheduler.createObserver(LoginViewModel.Updates.self)
        viewModel.data
            .bind(to: observer)
            .disposed(by: disposeBag)

        // Then
        XCTAssertEqual(observer.events.map { $0.value }, [.error(NetworkErrors.unknown)])
    }
}

// Mock class for testing
private class UserServicesMock: UserServices {
    var auth: Nimble.AuthModel?
    var stubbedLoginResult: Observable<AuthModel>!

    func login(email: String, password: String) -> Observable<AuthModel> {
        return stubbedLoginResult
    }
}

private class KeychainRecordableMock: KeychainRecordable {
    var stubbedGetAccessToken: String?
    var stubbedGetRefreshToken: String?
    var savedTokens: (accessToken: String, refreshToken: String)?

    func getAccessToken() -> String? {
        return stubbedGetAccessToken
    }

    func getRefreshToken() -> String? {
        return stubbedGetRefreshToken
    }

    func saveTokens(_ accessToken: String, refreshToken: String) {
        savedTokens = (accessToken, refreshToken)
    }
}
