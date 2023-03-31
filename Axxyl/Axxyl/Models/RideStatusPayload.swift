//
//  RideStatusPayload.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 22/01/23.
//

import Foundation

struct RideStatusPayload : Encodable {
    var action = Actions.getRideStatus.rawValue
    var userId : String
    var user_type : String
    var rideId : String
}
