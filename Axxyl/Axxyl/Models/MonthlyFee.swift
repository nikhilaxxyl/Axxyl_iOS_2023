//
//  MonthlyFee.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 26/01/23.
//

import Foundation

struct MonthlyFee {
    var month: String
    var year: String
    var fee: String
    
    init(month: String, year: String, fee: String) {
        self.month = month
        self.year = year
        self.fee = fee
    }
}
