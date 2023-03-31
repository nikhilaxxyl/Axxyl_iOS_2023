//
//  CancelRideRequestPayload.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 30/11/22.
//

import Foundation

struct CancelRideRequestPayload : Encodable {
    var action = Actions.canclerequest.rawValue
    var userId: String
    var reqId : String
}
