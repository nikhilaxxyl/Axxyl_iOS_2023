//
//  CardDataResponse.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 11/10/22.
//

import Foundation

struct UserCard  : Decodable {
    var cardname: String
    var cardnum: String
    var cardcvv: String
    var cardexpmonth: String
    var cardexpyear: String
    var active:String
    
    func isActive() -> Bool{
        return self.active.lowercased() == "yes"
    }
}

struct CardDataResponse: Decodable {
    var status : String
    var carDetails : [UserCard]?
    var msg : String?
    func isSuccess() -> Bool {
        return status == "1"
    }
}


struct UpdateCardDataResponse: Decodable {
    var status : String
    var carDetails : UserCard?
    var msg : String?
    func isSuccess() -> Bool {
        return status == "1"
    }
}
