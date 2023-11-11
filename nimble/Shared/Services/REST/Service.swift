//
//  Service.swift
//  Nimble
//
//  Created by darius vallejo on 11/9/23.
//

import Foundation
import RxSwift
   
protocol UserServices: AnyService {
    func login(email: String, password: String) -> Observable<AuthModel>
}

protocol SurveyServices: UserServices {
    func getSurveyList() -> Observable<[SurveyModel]>
}

class Services: UserServices {
    
    private init() {}
    
    private static var instance: Services = {
        return Services()
    }()
    
    class func shared() -> Services {
        return instance
    }

    func login(email: String, password: String) -> Observable<AuthModel> {
        let body: [String: String?] = [
            "email": email,
            "password": password,
            "client_id": ResourceType.clientId.getConfig(),
            "client_secret": ResourceType.clientSecret.getConfig(),
            "grant_type": "password"
        ]
        let requestBody = try? JSONSerialization.data(withJSONObject: body)
        return post(url: ServiceDefinitions.auth, body: requestBody, type: AuthModel.self)
    }
    
    func 
}
