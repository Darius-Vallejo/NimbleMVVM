//
//  HomeCoordinatorTests.swift
//  NimbleTests
//
//  Created by darius vallejo on 11/14/23.
//

import XCTest
import RxTest
import RxSwift
@testable import Nimble

class HomeCoordinatorTests: XCTestCase {
    
    var coordinator: HomeCoordinator!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        coordinator = HomeCoordinator.start() as? HomeCoordinator
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        coordinator = nil
        scheduler = nil
        disposeBag = nil

        super.tearDown()
    }
    
    func testStart() {
        // Ensure that the coordinator is created successfully
        XCTAssertNotNil(coordinator)
        
        // Ensure that the coordinator has a valid entry point
        XCTAssertNotNil(coordinator.entry)
        
        // Ensure that the root view controller is a HomePageViewController
        XCTAssertTrue(coordinator.entry?.viewControllers.first is HomePageViewController)
    }
    
    func testOpenLoginModule() throws {
        // Given
        let mockCoordinator = MockAuthenticationCoordinator.start()
        let mockAuthCoordinator = try XCTUnwrap(mockCoordinator as? MockAuthenticationCoordinator)
        mockAuthCoordinator.onFinish = {}
        
        // When
        mockAuthCoordinator.open(module: .login)

        
        // Then
        XCTAssertTrue(mockAuthCoordinator.didPresent)
        // Ensure that onFinish closure was set in AuthenticationCoordinator
        XCTAssertNotNil(mockAuthCoordinator.onFinish)
        // Call the onFinish closure to simulate authentication completion
        mockAuthCoordinator.onFinish?()
        // Ensure that handleAuthenticationCompletion was called
        XCTAssertTrue(mockAuthCoordinator.didHandleAuthenticationCompletion)
    }
    
    func testOpenDetailModule() {
        // Given
        let mockDetailViewModel: SurveyViewModel = .init(survey:.init(title: "",
                                                                      description: "",
                                                                      coverImageUrl: ""),
                                                         index: 0,
                                                         surveysQuantity: 0)

        let navigation = MockNavigationController()
        coordinator.entry = navigation
        
        // When
        // Call open with detail module
        coordinator.open(module: .detail(viewModel: mockDetailViewModel))
        
        // Then
        // Ensure that the entry point pushed the detail view controller
        XCTAssertTrue(navigation.isPushed)
    }
    
    func testHandleAuthenticationCompletion() throws {
        // Given
        let coordinator = HomeCoordinator.start(keychainManager: MockManager()) as? HomeCoordinator
        let page = try XCTUnwrap(coordinator?.entry?.viewControllers.first as? HomePageViewController)
        let observer = scheduler.createObserver(HomeViewModel.Updates.self)

        
        // When
        page.viewModel.data
            .bind(to: observer)
            .disposed(by: disposeBag)
        coordinator?.testHooks.handleAuthenticationCompletion()
        scheduler.start()

        // Then
        
        XCTAssertEqual(observer.events, [.next(0, .none), .next(0, .requestLogin)])
    }
}

// Mock classes for testing
fileprivate class MockAuthenticationCoordinator: Coordinator {
    var entry: UINavigationController?
    var onFinish: (() -> Void)?
    var didPresent = false
    var didHandleAuthenticationCompletion = false
    
    static func start(keychainManager: KeychainRecordable = KeychainManager.shared) -> Coordinator {
        return MockAuthenticationCoordinator()
    }
    
    func open(module: Module) {
        didPresent = true
        onFinish = { [weak self] in
            self?.handleAuthenticationCompletion()
        }
    }
    
    func finish(completion: CoordinatorCompletion) { }
    
    private func handleAuthenticationCompletion() {
        // Mock the authentication completion
        didHandleAuthenticationCompletion = true
    }
}

fileprivate class MockDetailViewController: DetailViewController {}

fileprivate class MockNavigationController: UINavigationController {
    var isPushed: Bool = false
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        isPushed = true
        super.pushViewController(viewController, animated: animated)
    }
}

fileprivate class MockHomeViewModel: HomeViewModel {
    var isSurveyLoaded: Bool = false
    override func loadSurveys(reloadToken: Bool = true) {
        super.loadSurveys(reloadToken: reloadToken)
        isSurveyLoaded = true
    }
}

fileprivate class MockManager: KeychainRecordable {
    func saveTokens(_ accessToken: String, refreshToken: String) {
        
    }
    
    func getAccessToken() -> String? {
        return nil
    }
    
    func getRefreshToken() -> String? {
        return nil
    }
    
    
}
