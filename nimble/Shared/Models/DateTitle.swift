//
//  DateTitle.swift
//  Nimble
//
//  Created by darius vallejo on 11/13/23.
//

import Foundation

struct DateTitle {
    var dateFormatted: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEEE, MMMM d"
        return dateFormatter.string(from: Date()).uppercased()
    }
    
    var today: String {
        return "Today"
    }
}
