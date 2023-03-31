//
//  GeneralResponse.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 30/11/22.
//

import Foundation
struct GeneralResponse : Decodable {
    var msg : String?
    var status : Int?
    
    func isSuccess() -> Bool {
        return status == 1
    }
}
