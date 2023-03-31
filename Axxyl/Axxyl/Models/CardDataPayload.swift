//
//  CardDataPayload.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 11/10/22.
//

import Foundation

struct GetCardDataPayload : Encodable {
    var action = Actions.getdatacardDetails.rawValue
    var userId:String
}

struct UpdateCardDataPayload : Encodable {
    var action = Actions.editUserCardDetails.rawValue
    var userId:String
    var cardname:String
    var cardnum:String
    var oldcardnum:String
    var cardcvv:String
    var cardexpmonth:String
    var cardexpyear:String
}

struct AddCardDataPayload : Encodable {
    var action = Actions.addMoreCards.rawValue
    var userId:String
    var cardname:String
    var cardnum:String
    var cardcvv:String
    var cardexpmonth:String
    var cardexpyear:String
}

struct DeleteCardPayload : Encodable {
    var action = Actions.deleteUserCardDetails.rawValue
    var userId:String
    var cardnum:String
}

struct SelectUserCardPayload : Encodable {
    var action = Actions.selectUserCard.rawValue
    var userId:String
    var cardnum:String
}
