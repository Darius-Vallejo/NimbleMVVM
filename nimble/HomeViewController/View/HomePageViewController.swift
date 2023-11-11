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
    let bag = DisposeBag()

    private var viewModel: HomeViewModel {
        didSet {
            
        }
    }
    
    init(viewModel: HomeViewModel, transitionStyle: UIPageViewController.TransitionStyle) {
        self.viewModel = viewModel
        super.init(transitionStyle: transitionStyle, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var viewControllerList: [UIViewController] = {
        let firstViewController = UIViewController()
        firstViewController.view.backgroundColor = .red

        let secondViewController = UIViewController()
        secondViewController.view.backgroundColor = .green

        let thirdViewController = UIViewController()
        thirdViewController.view.backgroundColor = .blue

        return [firstViewController, secondViewController, thirdViewController]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self

        if let firstViewController = viewControllerList.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
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
}
