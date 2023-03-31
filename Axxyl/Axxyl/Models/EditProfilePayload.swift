//
//  EditProfilePayload.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 01/10/22.
//

import Foundation


struct EditProfilePayload {
    var action = Actions.editprofile.rawValue
    var userId: String
    var fname: String
    var lname: String
    var phone: String
    var countryCode: String
    var handicapped: String
    var profile_image: Media?
}
