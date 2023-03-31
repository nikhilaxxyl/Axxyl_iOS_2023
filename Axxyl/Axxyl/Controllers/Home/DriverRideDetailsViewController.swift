//
//  DriverRideDetailsViewController.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 28/01/23.
//

import UIKit

protocol DriverEndRideProtocol : NSObject {
    func onTripEnd()
}

class DriverRideDetailsViewController: UIViewController {

    @IBOutlet weak var paymentCompletedStatusLbl: UILabel!
    @IBOutlet weak var totalAmountLbl: UILabel!
    @IBOutlet weak var tripIdLbl: UILabel!
    @IBOutlet weak var tripDateLbl: UILabel!
    @IBOutlet weak var pickupAddressLbl: UILabel!
    @IBOutlet weak var dropAddressLbl: UILabel!
    @IBOutlet weak var fareAmtLbl: UILabel!
    @IBOutlet weak var taxesLbl: UILabel!
    @IBOutlet weak var waitingChargesLbl: UILabel!
    @IBOutlet weak var tipLbl: UILabel!
    @IBOutlet weak var finaltotalAmountLbl: UILabel!
    var tripData : DriverTripEndResponse?
    weak var delegate : DriverEndRideProtocol?
    var emailId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    
    func updateUI() {
        guard let data = tripData?.response else {
           // fatalError("Trip data did not found, this should not happen.")
            print("Trip data did not found, this should not happen.")
            return
        }
        
        self.totalAmountLbl.text = "$\(data.totalPrice)"
        self.tripIdLbl.text = "Trip ID : \(data.reqId)"
        self.tripDateLbl.text = data.dropTime
        self.pickupAddressLbl.text = data.pickupLocation
        self.dropAddressLbl.text = data.dropLocation
        self.fareAmtLbl.text = "$\(data.totalPrice)"
        self.taxesLbl.text = "$0.0"
        self.tipLbl.text = "$0.0"
        self.waitingChargesLbl.text = "$0.0"
        self.finaltotalAmountLbl.text = "$\(data.totalPrice)"
    }
    
    @IBAction func goToHomeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
        self.delegate?.onTripEnd()
    }

    @IBAction func emailBtnPressed(_ sender: Any) {
        if let email = self.emailId, let url = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
