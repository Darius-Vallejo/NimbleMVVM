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

protocol SurveyServices: AnyService {
    func getSurveyList() -> Observable<[SurveyModel]>
    func renewToken(refreshToken: String)  -> Observable<AuthModel>
}

class Services: SurveyServices, UserServices {
    var auth: AuthModel?
    
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
            "grant_type": BodyGrantType.password.rawValue
        ]
        let requestBody = try? JSONSerialization.data(withJSONObject: body)
        return post(url: ServiceDefinitions.auth, body: requestBody, type: AuthModel.self, useAuth: false)
    }
    
    func getSurveyList() -> Observable<[SurveyModel]> {
        let urlString = ServiceDefinitions.surveys
        return rx_get(url: urlString, type: [SurveyModel].self)
    }
    
    func renewToken(refreshToken: String)  -> Observable<AuthModel> {
        let body: [String: String?] = [
            "client_id": ResourceType.clientId.getConfig(),
            "client_secret": ResourceType.clientSecret.getConfig(),
            "grant_type": BodyGrantType.refresh.rawValue,
            "refresh_token": refreshToken
        ]
        let requestBody = try? JSONSerialization.data(withJSONObject: body)
        return post(url: ServiceDefinitions.auth,
                    body: requestBody,
                    type: AuthModel.self,
                    useAuth: false)
    }
}
