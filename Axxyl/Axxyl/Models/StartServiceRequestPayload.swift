//
//  StartServiceRequestPayload.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 05/02/23.
//

import Foundation

struct StartServiceRequestPayload : Codable {
    var action = Actions.startReqestServices.rawValue
    var vendorId : String
    var pickuplatLong : String
    var vehicle_number : String
    var reqId : String
    var uid : String
}
