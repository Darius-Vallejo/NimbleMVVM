//
//  ResourceType.swift
//  Nimble
//
//  Created by darius vallejo on 11/10/23.
//

import Foundation

enum ResourceType: String {
    case clientId
    case clientSecret
    case baseURL
    
    func getConfig() -> String? {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path) as? [String: Any] {
            return config[self.rawValue] as? String
        }
        return nil
    }
}
