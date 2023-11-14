//
//  ServiceDefinitions.swift
//  Nimble
//
//  Created by darius vallejo on 11/9/23.
//

import Foundation

struct ServiceDefinitions {
    static let base: String = {
        let config: String = ResourceType.baseURL.getConfig()!
        return config
    }()
    
    static let auth = "\(base)oauth/token"
    static let surveys = "\(base)surveys"
}
