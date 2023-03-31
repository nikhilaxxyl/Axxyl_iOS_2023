//
//  UserLoginResponse.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 28/09/22.
//

import Foundation

struct UserInfo : Codable {
    var handicapped: String
    var id: String
    var name: String
    var emailId: String
    var country: String?
    var phone: String
    var password2: String
    var usertype: String
    var bookingOn: String
    var car_number:String
    var profile_image: String
    var docUploaded: String
}

struct UserLoginResponse : Codable {
    var status: Int
    var price: String?
    var msg: String
    var userType: String?
    var deviceToken_avaibility:String?
    var user : UserInfo?
    
    func isSuccess() -> Bool {
        return status == 1
    }
}
