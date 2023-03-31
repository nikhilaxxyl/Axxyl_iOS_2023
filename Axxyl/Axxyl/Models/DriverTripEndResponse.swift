//
//  DriverTripEndResponse.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 05/02/23.
//

import Foundation

struct DriverTripEndResponse : Decodable {
    var msg : String?
    var status : Int
    var response: TripEndResponse?
    
    func isSuccess() -> Bool {
        return status == 1
    }
}

struct TripEndResponse : Decodable {
    var totalTime: String
    var avgSpeed: String
    var reqId: String
    var totalDistance: String
    var pickupLocation: String
    var pickupTime: String
    var dropLocation: String
    var dropTime: String
    var message: String
    var notificationType: String
    var msgType: String
    var venderId: String
    var geoDropCharge: Double
    var geoPickupCharge: String
    var totalPrice: Double
}

