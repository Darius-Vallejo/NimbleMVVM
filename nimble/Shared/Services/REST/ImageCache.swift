//
//  ImageCache.swift
//  Nimble
//
//  Created by darius vallejo on 11/10/23.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()
    private let disposeBag = DisposeBag()

    private init() {}

    func loadImage(with urlString: String) -> Observable<UIImage?> {
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            return Observable.just(cachedImage)
        }

        return Observable.create { observer in
            guard let url = URL(string: urlString) else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil, let downloadedImage = UIImage(data: data) else {
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
                }

                self.cache.setObject(downloadedImage, forKey: urlString as NSString)
                observer.onNext(downloadedImage)
                observer.onCompleted()
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }
}
