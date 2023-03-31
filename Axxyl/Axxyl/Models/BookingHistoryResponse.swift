//
//  BookingHistoryResponse.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 02/10/22.
//

import Foundation

struct BookingHistoryResponse : Codable {
    var status : Int
    var msg: String
    var history : [BookingHistoryItem]?
    var pending : [BookingHistoryItem]?
    
    func isSuccess() -> Bool {
        return status == 1
    }
}
