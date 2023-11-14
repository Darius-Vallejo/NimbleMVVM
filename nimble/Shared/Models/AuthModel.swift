//
//  AuthModel.swift
//  Nimble
//
//  Created by darius vallejo on 11/10/23.
//

import Foundation

struct AuthModel {
    let accessToken: String
    let tokenType: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case attributes
    }

    enum AttributesKeys: String, CodingKey {
        case accessToken
        case tokenType
        case refreshToken
    }
    
    init(accessToken: String, tokenType: String = "Bearer", refreshToken: String) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.refreshToken = refreshToken
    }

    var authToken: String {
        return "\(tokenType) \(accessToken)"
    }
}

extension AuthModel: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let attributes = try values.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        accessToken = try attributes.decode(String.self, forKey: .accessToken)
        tokenType = try attributes.decode(String.self, forKey: .tokenType)
        refreshToken = try attributes.decode(String.self, forKey: .refreshToken)
    }
}
