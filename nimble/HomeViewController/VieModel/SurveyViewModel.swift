//
//  SurveyViewModel.swift
//  Nimble
//
//  Created by darius vallejo on 11/11/23.
//

import Foundation

class SurveyViewModel {
    let survey: SurveyModel
    let dateTile = DateTitle()
    let index: Int
    let surveysQuantity: Int
    let isLoading: Bool

    init(survey: SurveyModel, index: Int, surveysQuantity: Int, isLoading: Bool = false) {
        self.index = index
        self.survey = survey
        self.surveysQuantity = surveysQuantity
        self.isLoading = isLoading
    }
}

extension SurveyViewModel {
    private static var defaultCoverImage = "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_l"
    convenience init(isLoading: Bool) {
        self.init(survey: .init(title: "...",
                                description: "...",
                                coverImageUrl: SurveyViewModel.defaultCoverImage),
                  index: 0,
                  surveysQuantity: 0,
                  isLoading: isLoading)
    }
}
