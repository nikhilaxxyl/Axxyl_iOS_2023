//
//  DriverTripStarted.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 28/01/23.
//

import UIKit

protocol DriverTripStartProtocol : NSObject {
    func driverEndsRide()
}

class DriverTripStarted: UIView {

    @IBOutlet weak var estimatedCostLbl : UILabel!
    @IBOutlet weak var dropAddressLbl : UILabel!
    weak var delegate : DriverTripStartProtocol?
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    var userId : String = ""
    
    @IBAction func endRideBtnPressed(sender : UIButton) {
        self.delegate?.driverEndsRide()
    }
    
    func attachData(data : DriverReceivedRideRequestNotificationData) {
        self.estimatedCostLbl.text = data.userPrice
        self.dropAddressLbl.text = data.dropLocation
        self.userId = data.userId
    }
}
