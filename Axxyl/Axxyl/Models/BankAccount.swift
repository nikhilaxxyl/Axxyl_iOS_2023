//
//  BankAccount.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 22/01/23.
//

import Foundation

struct BankAccount: Decodable, Equatable {
    var name: String
    var bankname: String
    var routing_number: String
    var account_number: String
    var email: String
    var active: String
    
    init(bankname: String, name: String, account_number: String, routing_number: String, email: String, active: String) {
        self.bankname = bankname
        self.name = name
        self.account_number = account_number
        self.routing_number = routing_number
        self.email = email
        self.active = active
    }
}

struct PayoutDetailsPaylaod: Encodable {
    var action = Actions.getDriverPayoutDetails.rawValue
    var userId:String
}

struct PayoutDetailsResponse: Decodable {
    var status : String
    var PayoutDetails : [BankAccount]?
    var msg : String?
    
    func isSuccess() -> Bool {
        return status == "1"
    }
}

struct EditDriverPayoutDetails: Encodable {
    var action = Actions.editDriverPayoutDetails.rawValue
    var userId:String
    var name: String
    var bankname: String
    var routing_number: String
    var account_number: String
    var email: String
}

struct EditDriverPayoutDetailseResponse: Decodable {
    var status : Int
    var msg : String?
    
    func isSuccess() -> Bool {
        return status == 1
    }
}
