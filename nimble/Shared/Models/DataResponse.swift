//
//  DataResponse.swift
//  Nimble
//
//  Created by darius vallejo on 11/10/23.
//

import Foundation

struct DataResponse<Model: Decodable>: Decodable {
    let data: Model
}
