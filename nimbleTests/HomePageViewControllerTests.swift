//
//  HomePageViewControllerTests.swift
//  NimbleTests
//
//  Created by darius vallejo on 11/14/23.
//

import XCTest
import RxSwift
import RxTest
@testable import Nimble

final class HomePageViewControllerTests: XCTestCase {

    var viewModel: HomeViewModel!
    var coordinator: CoordinatorMock!
    var viewController: HomePageViewController!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        viewModel = HomeViewModelMock(services: SurveyServicesMock())
        coordinator = CoordinatorMock()
        viewController = HomePageViewController(viewModel: viewModel, transitionStyle: .scroll)
        viewController.coordinator = coordinator
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        super.tearDown()
        viewModel = nil
        coordinator = nil
        viewController = nil
        scheduler = nil
        disposeBag = nil
    }

    func testLoadSurveys() {
        // Given
        let surveys = [
            SurveyViewModel(survey: SurveyModel(title: "Survey 1", description: "Description 1", coverImageUrl: "URL 1"), index: 0, surveysQuantity: 2),
            SurveyViewModel(survey: SurveyModel(title: "Survey 2", description: "Description 2", coverImageUrl: "URL 2"), index: 1, surveysQuantity: 2)
        ]

        // When
        viewController.loadSurveys(list: surveys)

        // Then
        XCTAssertEqual(viewController.testHooks.viewControllerList.count, 2)
        XCTAssertNotNil(viewController.testHooks.viewControllerList.first as? SurveyViewController)
    }

    func testPageViewControllerDataSource() {
        // Given
        let surveys = [
            SurveyViewModel(survey: SurveyModel(title: "Survey 1", description: "Description 1", coverImageUrl: "URL 1"), index: 0, surveysQuantity: 2),
            SurveyViewModel(survey: SurveyModel(title: "Survey 2", description: "Description 2", coverImageUrl: "URL 2"), index: 1, surveysQuantity: 2)
        ]
        viewController.loadSurveys(list: surveys)

        // When
        let beforeViewController = viewController.pageViewController(viewController,
                                                                     viewControllerBefore: viewController.testHooks.viewControllerList[1])
        let afterViewController = viewController.pageViewController(viewController, viewControllerAfter: viewController.testHooks.viewControllerList[0])

        // Then
        XCTAssertNotNil(beforeViewController)
        XCTAssertEqual((beforeViewController as? SurveyViewController)?.viewModel.survey.title, "Survey 1")

        XCTAssertNotNil(afterViewController)
        XCTAssertEqual((afterViewController as? SurveyViewController)?.viewModel.survey.title, "Survey 2")
    }
}

// Mock classes for testing
class HomeViewModelMock: HomeViewModel {
    override func loadSurveys(reloadToken: Bool = true) {
        testHooks.dataSubject.onNext(.loadSurvey(list: [
            SurveyViewModel(survey: SurveyModel(title: "Mock Survey", description: "Mock Description", coverImageUrl: "Mock URL"), index: 0, surveysQuantity: 1)
        ]))
    }
}

class CoordinatorMock: Coordinator {
    var entry: UINavigationController?
    
    var onFinish: (() -> Void)?
    
    static func start(keychainManager: KeychainRecordable) -> Coordinator {
        return CoordinatorMock()
    }
    
    var openModuleCalled = false
    func open(module: Module) {
        openModuleCalled = true
    }

    func finish(completion: CoordinatorCompletion) {}
}
