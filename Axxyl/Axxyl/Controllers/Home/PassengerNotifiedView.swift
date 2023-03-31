//
//  PassengerNotifiedView.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 28/01/23.
//

import UIKit

protocol PassengerNotifiedProtocol : NSObject {
    func startRide()
    func driverCancelsRide()
    func pncallPassenger()
    func pnsmsPassenger()
}

class PassengerNotifiedView: UIView {
    @IBOutlet weak var driverNameLbl : UILabel!
    @IBOutlet weak var driverPhoneNoLbl : UILabel!
    @IBOutlet weak var pickupAddressLbl : UILabel!
    @IBOutlet weak var dropAddressLbl : UILabel!
    @IBOutlet weak var userProfileBtn : UIButton!
    weak var delegate : PassengerNotifiedProtocol?
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    var userId : String = ""
    var pickupLatLong : String = ""
    
    @IBAction func startRideBtnPressed(sender : UIButton) {
        self.delegate?.startRide()
    }
    
    @IBAction func noShowBtnPressed(sender : UIButton) {
        self.delegate?.driverCancelsRide()
    }
    
    @IBAction func smsBtnPressed(sender : UIButton) {
        self.delegate?.pnsmsPassenger()
    }
    
    @IBAction func callBtnPressed(sender : UIButton) {
        self.delegate?.pncallPassenger()
    }
    
    func attachData(data : DriverReceivedRideRequestNotificationData) {
        self.driverNameLbl.text = data.UserName
        self.driverPhoneNoLbl.text = data.UserPhone
        self.pickupAddressLbl.text = data.pickupLocation
        self.dropAddressLbl.text = data.dropLocation
        self.userId = data.userId
        self.pickupLatLong = data.pickuplatLong
        if let imgURL = URL(string: data.UserImage) {
            self.userProfileBtn.kf.setImage(with: imgURL, for: .normal)
        }
    }
}
