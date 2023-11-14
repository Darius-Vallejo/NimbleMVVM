//
//  SurveyModel.swift
//  Nimble
//
//  Created by darius vallejo on 11/11/23.
//

import Foundation

struct SurveyModel {
    let title: String
    let description: String
    let coverImageUrl: String

    enum CodingKeys: String, CodingKey {
        case attributes
    }

    enum AttributesKeys: String, CodingKey {
        case title
        case description
        case coverImageUrl
    }
    
    var hightDefinitionCoverImage: String {
        return coverImageUrl + "l"
    }
}

extension SurveyModel: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let attributes = try values.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        title = try attributes.decode(String.self, forKey: .title)
        description = try attributes.decode(String.self, forKey: .description)
        coverImageUrl = try attributes.decode(String.self, forKey: .coverImageUrl)
    }
}
