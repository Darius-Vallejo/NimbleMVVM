//
//  AuthenticationCoordinatorTests.swift
//  NimbleTests
//
//  Created by darius vallejo on 11/14/23.
//

import XCTest
@testable import Nimble

class AuthenticationCoordinatorTests: XCTestCase {

    var coordinator: AuthenticationCoordinator!
    var navigationController: UINavigationControllerMock!
    
    override func setUp() {
        super.setUp()
        coordinator = AuthenticationCoordinator()
        navigationController = UINavigationControllerMock()
        coordinator.entry = navigationController
    }

    override func tearDown() {
        super.tearDown()
        coordinator = nil
        navigationController = nil
    }

    func testStart() {
        // When
        let coordinator = AuthenticationCoordinator.start()

        // Then
        XCTAssertNotNil(coordinator.entry)
        XCTAssertTrue(coordinator.entry?.viewControllers.first is LoginViewController)
    }

    func testFinish() {
        // Given
        let expectation = XCTestExpectation(description: "Finish completion called")

        // When
        coordinator.onFinish = {
            expectation.fulfill()
        }
        coordinator.finish(completion: .loggedUser(auth: .init(accessToken: "", refreshToken: "")))

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(navigationController.dismissAnimatedCalled)
    }
}

// Mock classes for testing
class UINavigationControllerMock: UINavigationController {
    var dismissAnimatedCalled = false

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissAnimatedCalled = true
        super.dismiss(animated: flag, completion: completion)
    }
}
