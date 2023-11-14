//
//  Errors.swift
//  Nimble
//
//  Created by darius vallejo on 11/11/23.
//

import Foundation

enum NetworkErrors: Error {
    case badContent
    case decode
    case unknown
    case detailed(errors: Errors)
}

struct NimbleError: Decodable {
    enum Code: String, Decodable {
        case invalidToken = "invalid_token"
    }

    let detail: String
    let code: Code
}

struct Errors: Decodable {
    let errors: [NimbleError]
}
