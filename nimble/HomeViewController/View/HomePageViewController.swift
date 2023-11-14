//
//  HomePageViewController.swift
//  Nimble
//
//  Created by darius vallejo on 11/10/23.
//

import Foundation
import UIKit
import RxSwift

class HomePageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var coordinator: Coordinator?
    private let bag = DisposeBag()

    let viewModel: HomeViewModel
    private var viewControllerList: [UIViewController] = []
    
    init(viewModel: HomeViewModel, transitionStyle: UIPageViewController.TransitionStyle) {
        self.viewModel = viewModel
        super.init(transitionStyle: transitionStyle, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        setupViewModel()
        viewModel.loadSurveys()
        loadSurveys(list: [])
    }
    
    private func setupViewModel() {
        viewModel
            .data
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                switch $0 {
                case .loadSurvey(let surveys):
                    self?.loadSurveys(list: surveys)
                case .requestLogin:
                    self?.coordinator?.open(module: .login)
                case .none:
                    break
                }
            })
            .disposed(by: bag)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllerList.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }

        return viewControllerList[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllerList.firstIndex(of: viewController), currentIndex < viewControllerList.count - 1 else {
            return nil
        }

        return viewControllerList[currentIndex + 1]
    }

    func loadSurveys(list: [SurveyViewModel]) {
        viewControllerList = list.map {
            let controller = SurveyViewController(viewModel: $0)
            controller.coordinator = coordinator
            return controller
        }
        if let firstViewController = viewControllerList.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: false,
                               completion: nil)
        } else {
            let loadingController = SurveyViewController(viewModel: viewModel.getLoadingSurvey())
            viewControllerList = [loadingController]
            setViewControllers([loadingController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
}

#if DEBUG
extension HomePageViewController {
    var testHooks: TestHooks {
        .init(target: self)
    }

    class TestHooks {
        let target: HomePageViewController
        init(target: HomePageViewController) {
            self.target = target
        }

        var viewControllerList: [UIViewController] {
            return target.viewControllerList
        }
        
    }
}
#endif
