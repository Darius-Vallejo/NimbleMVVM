//
//  AnyService.swift
//  Nimble
//
//  Created by darius vallejo on 11/11/23.
//

import Foundation
import RxSwift

protocol AnyService {
    var auth: AuthModel? { get set }
    func post<Model>(url: String, body: Data?, type: Model.Type, useAuth: Bool) -> Observable<Model> where Model: Decodable
    func rx_get<Model>(url: String, type: Model.Type, useAuth: Bool) -> Observable<Model> where Model: Decodable
}

extension AnyService {
    func post<Model>(url: String,
                     body: Data?,
                     type: Model.Type,
                     useAuth: Bool = true) -> Observable<Model> where Model: Decodable {
        return Observable.create { observer in
            guard let urlForSession = URL(string: url) else {
                observer.onError(NetworkErrors.unknown)
                return Disposables.create()
            }
            var urlRequest = URLRequest(url: urlForSession)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = body
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = auth?.authToken, useAuth {
                urlRequest.setValue("Authorization", forHTTPHeaderField: token)
            }
            let cancellable = URLSession
                .shared
                .dataTask(with: urlRequest, completionHandler: { data, _, error in
                    if let error = error {
                        print(error)
                        if error is URLError {
                            observer.onError(NetworkErrors.badContent)
                        } else {
                            observer.onError(NetworkErrors.unknown)
                        }
                        return
                    }

                    DispatchQueue.global().async {
                        do {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let decodedData = try decoder.decode(DataResponse<Model>.self, from: data!)
                            observer.onNext(decodedData.data)
                            observer.onCompleted()
                        } catch {
                            print(error)
                            observer.onError(NetworkErrors.decode)
                        }
                    }
                })

            cancellable.resume()

            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
    
    func rx_get<Model>(url: String,
                       type: Model.Type,
                       useAuth: Bool = true) -> Observable<Model> where Model: Decodable {
        return Observable.create { observer in
            guard let urlForSession = URL(string: url) else {
                observer.onError(NetworkErrors.unknown)
                return Disposables.create()
            }
            var urlRequest = URLRequest(url: urlForSession)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = auth?.authToken, useAuth {
                urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            }
            let cancellable = URLSession
                .shared
                .dataTask(with: urlRequest, completionHandler: { data, _, error in
                    if let error = error {
                        print(error)
                        if error is URLError {
                            observer.onError(NetworkErrors.badContent)
                        } else {
                            observer.onError(NetworkErrors.unknown)
                        }
                        return
                    }

                    DispatchQueue.global().async {
                        do {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let decodedData = try decoder.decode(DataResponse<Model>.self, from: data!)
                            observer.onNext(decodedData.data)
                            observer.onCompleted()
                        } catch {
                            print(error)
                            if let decodedData = try? JSONDecoder().decode(Errors.self, from: data!) {
                                observer.onError(NetworkErrors.detailed(errors: decodedData))
                            } else {
                                observer.onError(NetworkErrors.decode)
                            }
                        }
                    }
                })

            cancellable.resume()

            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
}
