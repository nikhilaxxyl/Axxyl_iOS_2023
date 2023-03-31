//
//  DriverTripEndPayload.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 05/02/23.
//

import Foundation

struct DriverTripEndPayload : Codable {
    var action = Actions.ariveAndEnd.rawValue
    var vendorId : String
    var reqId : String
    var droplatLong : String
    var dropLocation : String
    var pickupLocation : String
    var vehicle_number : String
    var uid : String
}
