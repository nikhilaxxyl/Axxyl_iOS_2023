//
//  ConfirmRideDetailsViewController.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 12/10/22.
//

import UIKit

protocol ConfirmRideProtocol : AnyObject {
    func editAddress()
    func confirmRide()
    func changePaymentMethod()
}

class ConfirmRideDetailsViewController: UIViewController {

    weak var confirmDelegate : ConfirmRideProtocol?
    @IBOutlet weak var confirmRiderBtn: GradientButton!
    @IBOutlet weak var endAddressLbl: UILabel!
    @IBOutlet weak var startAddressLbl: UILabel!
    
    @IBOutlet weak var totalAmountLbl: UILabel!
    @IBOutlet weak var carTypeNameLbl: UILabel!
    @IBOutlet weak var carTypeIconImgView: UIImageView!
    @IBOutlet weak var noOfSeatsLbl: UILabel!
    @IBOutlet weak var maskedCardNoLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.confirmRiderBtn.addTarget(self, action: #selector(confirmRidePressed), for: UIControl.Event.touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUIWithValues()
    }
    
    func updateUIWithValues() {
        guard let routes = BookingService.instance.routeLocations, routes.count > 1 else {
            return
        }
        
        let startLoc = routes.first!
        let endLoc = routes.last!
        startAddressLbl.text = (startLoc.name ?? "") + " - " + (startLoc.address ?? "")
        endAddressLbl.text = (endLoc.name  ?? "") + " - " + (endLoc.address ?? "")
        
        guard let vehType = BookingService.instance.currentVehicleType else {
            return
        }
        carTypeNameLbl.text = vehType.name
        carTypeIconImgView.image = UIImage(named: "\(vehType.name)_Car.png")//kf.setImage(with: URL(string: vehType.carTypeIcon))
        noOfSeatsLbl.text = vehType.seats + " Seats"
        
        guard let paymentmethod = BookingService.instance.currentPaymentMethod else {
            return
        }
        
        totalAmountLbl.text = "$ \((BookingService.instance.currentVehicleType?.total ?? 0))" 
        
        let subStr = paymentmethod.cardnum.suffix(4)
        maskedCardNoLbl.text = "Visa : **** " + String(subStr)
    }
    
    @IBAction func editLocation(_ sender: Any) {
        self.dismiss(animated: true) {
            self.confirmDelegate?.editAddress()
        }
    }
    
    @IBAction func changePaymentMethodBtnPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.confirmDelegate?.changePaymentMethod()
        }
        let sb = UIStoryboard(name: "Payment", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "PaymentsViewController") as! PaymentsViewController
        vcToOpen.selectionMode = true
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    @IBAction func changeVehicleType(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func goBackBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func confirmRidePressed() {
        self.dismiss(animated: true) {
            self.confirmDelegate?.confirmRide()
        }
    }
    
}
