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
    

    init(survey: SurveyModel, index: Int, surveysQuantity: Int) {
        self.index = index
        self.survey = survey
        self.surveysQuantity = surveysQuantity
    }
}
