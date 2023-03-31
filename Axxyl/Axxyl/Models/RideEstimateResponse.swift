//
//  RideEstimateResponse.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 26/11/22.
//

import Foundation

struct CarCategory : Decodable {
    var ID : String
    var name : String
    var seats : String
    var price : String
    var total: Double
    
    func displayTotalPrice() -> String {
        return "$\(total)"
    }
}

//struct Response : Decodable {
//    var basePrice : Double
//    var distance : String
//    var estimatePrice : String
//    var geoPickPrice = 0
//    var geoDropPrice = 0
//    var time : String
//    var number_of_seat : String
//}

struct RideEstimateResponse : Decodable {
    var msg : String?
    var status : Int
    var catPriceList : [CarCategory]?
//    var response : Response?
    func isSuccess() -> Bool {
        return status == 1
    }
}
