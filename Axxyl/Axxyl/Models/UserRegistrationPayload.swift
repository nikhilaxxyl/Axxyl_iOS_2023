//
//  UserRegistrationPayload.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 28/09/22.
//

import Foundation

class UserRegistrationPayload : BasePayload {
    var firstName: String = ""
    var lastName : String = ""
    var emailId: String = ""
    var password: String = ""
    var countryCode: String = ""
    var phoneNumber : String = ""
    var usertype : UserType!
    var cardname : String = ""
    var cardnum : String = ""
    var cardcvv : String = ""
    var cardexpmonth : String = ""
    var cardexpyear : String = ""
    var car_number : String = ""
    var carColor : String = ""
    var carModel : String = ""
    var handicapped : Bool = false
    var carTypeId : String =  ""
    var profile_image: Media?
//    var bankname = ""
//    var account_name = ""
//    var account_number = ""
//    var routing_number = ""
//    var account_emailId = ""
    
    
    init() {
        super.init(action: Actions.registration)
    }
    
//    init(firstName: String, lastName: String, emailId: String, password: String, phoneNumber: String, usertype: UserType!, cardname: String, cardnum: String, cardcvv: String, cardexpmonth: String, cardexpyear: String, car_number: String, carColor: String, carModel: String, handicapped: Bool, carTypeId: String = "22", bankname: String, account_name: String, account_number: String, routing_number: String, account_emailId: String) {
    init(firstName: String, lastName: String, emailId: String, password: String, phoneNumber: String, usertype: UserType!, cardname: String, cardnum: String, cardcvv: String, cardexpmonth: String, cardexpyear: String, car_number: String, carColor: String, carModel: String, handicapped: Bool, carTypeId: String = "22") {
        super.init(action: Actions.registration)
        self.firstName = firstName
        self.lastName = lastName
        self.emailId = emailId
        self.password = password
        self.phoneNumber = phoneNumber
        self.usertype = usertype
        self.cardname = cardname
        self.cardnum = cardnum
        self.cardcvv = cardcvv
        self.cardexpmonth = cardexpmonth
        self.cardexpyear = cardexpyear
        self.car_number = car_number
        self.carColor = carColor
        self.carModel = carModel
        self.handicapped = handicapped
        self.carTypeId = carTypeId
//        self.bankname = bankname
//        self.account_name = account_name
//        self.account_number = account_number
//        self.routing_number = routing_number
//        self.account_emailId = account_emailId
    }
    
    
    
    func getSerializableDict() -> GenericDictionary {
        var dt = GenericDictionary()
        dt.updateValue(self.action.rawValue as AnyObject, forKey: "action")
        dt.updateValue(self.emailId as AnyObject, forKey: "emailId")
        dt.updateValue(self.password as AnyObject, forKey: "password")
        dt.updateValue(self.firstName as AnyObject, forKey: "fname")
        dt.updateValue(self.lastName as AnyObject, forKey: "lname")
        dt.updateValue(self.phoneNumber as AnyObject, forKey: "phone")
        dt.updateValue(self.cardname as AnyObject, forKey: "cardname")
        dt.updateValue(self.cardnum as AnyObject, forKey: "cardnum")
        dt.updateValue(self.cardcvv as AnyObject, forKey: "cardcvv")
        dt.updateValue(self.cardexpmonth as AnyObject, forKey: "cardexpmonth")
        dt.updateValue(self.cardexpyear as AnyObject, forKey: "cardexpyear")
        dt.updateValue(self.car_number as AnyObject, forKey: "car_number")
        dt.updateValue(self.carColor as AnyObject, forKey: "carColor")
        dt.updateValue(self.carModel as AnyObject, forKey: "carModel")
        dt.updateValue(self.updatemobile as AnyObject, forKey: "updatemobile")
        dt.updateValue(self.device as AnyObject, forKey: "device")
        dt.updateValue(self.deviceToken as AnyObject, forKey: "deviceToken")
        dt.updateValue(self.usertype.rawValue as AnyObject, forKey: "usertype")
        dt.updateValue(( self.handicapped ? 1 : 0) as AnyObject, forKey: "handicapped")
//        dt.updateValue(self.bankname as AnyObject, forKey: "bankname")
//        dt.updateValue(self.account_name as AnyObject, forKey: "account_name")
//        dt.updateValue(self.account_number as AnyObject, forKey: "account_number")
//        dt.updateValue(self.routing_number as AnyObject, forKey: "routing_number")
//        dt.updateValue(self.account_emailId as AnyObject, forKey: "account_emailId")
        return dt
    }
}

