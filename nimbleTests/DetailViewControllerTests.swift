//
//  DetailViewControllerTests.swift
//  NimbleTests
//
//  Created by darius vallejo on 11/14/23.
//

import XCTest

import XCTest
import RxSwift
import RxTest
@testable import Nimble

final class DetailViewControllerTests: XCTestCase {

    var viewModel: SurveyViewModel!
    var viewController: DetailViewController!
    var testScheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        viewModel = SurveyViewModel(survey: .init(title: "",
                                                  description: "",
                                                  coverImageUrl: ""),
                                    index: 0,
                                    surveysQuantity: 1)
        viewController = DetailViewController(viewModel: viewModel)
        testScheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        super.tearDown()
        viewModel = nil
        viewController = nil
        testScheduler = nil
        disposeBag = nil
    }

    func testBackgroundLayer() {
        // Given
        let testHooks = viewController.testHooks
        let expectedColors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        ]

        // When
        let layer = testHooks.backgroundLayer()

        // Then
        XCTAssertEqual(layer.colors as? [CGColor], expectedColors)
        XCTAssertEqual(layer.locations, [0, 1])
        XCTAssertEqual(layer.startPoint, CGPoint(x: 0.25, y: 0.5))
        XCTAssertEqual(layer.endPoint, CGPoint(x: 0.75, y: 0.5))
    }

    func testBackgroundView() {
        // Given
        let testHooks = viewController.testHooks

        // When
        let backgroundView = testHooks.backgroundView()

        // Then
        XCTAssertTrue(backgroundView.layer.masksToBounds)
        XCTAssertNotNil(backgroundView.subviews.first as? UIImageView)
    }

    func testTopStackView() {
        // Given
        let testHooks = viewController.testHooks

        // When
        let topStackView = testHooks.topStackView()

        // Then
        XCTAssertEqual(topStackView.subviews.count, 1)
        XCTAssertEqual(topStackView.subviews[0].subviews.count, 2)
        XCTAssertTrue(topStackView.subviews[0].subviews[0] is UILabel)
        XCTAssertTrue(topStackView.subviews[0].subviews[1] is UILabel)
        XCTAssertEqual((topStackView.subviews[0].subviews[0] as? UILabel)?.text,
                       viewModel.survey.title)
        XCTAssertEqual((topStackView.subviews[0].subviews[1] as? UILabel)?.text,
                       viewModel.survey.description)
    }

    func testSetupUI() {
        // Given
        let testHooks = viewController.testHooks

        // When
        testHooks.setupUI()

        // Then
        XCTAssertEqual(viewController.view.subviews.count, 4)
    }
}
