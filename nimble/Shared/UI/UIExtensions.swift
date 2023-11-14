//
//  UIExtensions.swift
//  Nimble
//
//  Created by darius vallejo on 11/13/23.
//

import Foundation
import UIKit
import RxSwift

extension UIImageView {
    func load(from url: String, bag: DisposeBag) {
        ImageCache.shared.loadImage(with: url)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                if let image = image {
                    UIView.animate(withDuration: 0.5, delay: 0) {
                        self?.image = image
                    }
                } else {
                    self?.backgroundColor = .white
                    print("URL Error")
                }
            })
            .disposed(by: bag)
    }
}

extension UIImage {
    static func load(from url: String) -> Observable<UIImage?> {
        return ImageCache.shared.loadImage(with: url)
            .observe(on: MainScheduler.instance)
    }
}

extension UIView {
    func addSubview(_ subview: UIView, yConstant: CGFloat, xConstant: CGFloat) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: yConstant),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: xConstant),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -xConstant),
            subview.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor,
                                            constant: -yConstant)
        ])
    }
}

extension UIFont {
    
    enum FontType {
        case heavy
        case normal
    }

    static func printNames() {
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
    }
    
    static func customFont(type: FontType, size: CGFloat) -> UIFont {
        let name = type == .heavy ? "NeuzeitSLTStd-BookHeavy" : "NeuzeitSLTStd-Book"
        guard let customFont = UIFont(name: name, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return customFont
    }
}
