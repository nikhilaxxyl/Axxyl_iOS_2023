//
//  DriverOnWayView.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 23/10/22.
//

import UIKit

protocol DriverOnWayViewDelegate : AnyObject {
    func navigateToCurrentLocation()
    func openProfile()
    func openMessageComposer()
    func callDriver()
    func changeDestination()
    func cancelRide()
}

let waitTime : TimeInterval = 5 * 60; // seconds

class DriverOnWayView: UIView {

    @IBOutlet var amountLbl: UILabel!
    @IBOutlet var destinationLbl: UILabel!
    @IBOutlet var originAddressLbl: UILabel!
    @IBOutlet var carNoLbl: UILabel!
    @IBOutlet var carModelLbl: UILabel!
    @IBOutlet var driverNameLbl: UILabel!
    weak var delegate : DriverOnWayViewDelegate?
    @IBOutlet var driverEtaStackView : UIStackView!
    @IBOutlet var driverWaitingStackView: UIStackView!
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    @IBOutlet var driverProfilePhotoBtn: UIButton!
    @IBOutlet var msgBtn: UIButton!
    @IBOutlet var callBtn: UIButton!
    var waitTimer : Timer?
    @IBOutlet var waitingTimeLbl: UILabel!
    var remainingWaitTime : TimeInterval = waitTime
    
    @IBAction func currentLocationBtnTapped(_ sender: Any) {
        print("currentLocationBtnTapped")
        delegate?.navigateToCurrentLocation()
    }
    
    @IBAction func profileBtnTapped(_ sender: Any) {
        print("profileBtnTapped")
        delegate?.openProfile()
    }
    
    @IBAction func messageBtnTapped(_ sender: Any) {
        print("messageBtnTapped")
        delegate?.openMessageComposer()
    }
    
    @IBAction func callBtnTapped(_ sender: Any) {
        print("callBtnTapped")
        delegate?.callDriver()
    }
    
    @IBAction func changeDestinationBtnTapped(_ sender: Any) {
        print("changeDestinationBtnTapped")
        delegate?.changeDestination()
    }
    
    @IBAction func cancelRideBtnTapped(_ sender: Any) {
        print("cancelRideBtnTapped")
        delegate?.cancelRide()
    }
    
    func stringFromTime(interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: interval)!
    }

    @objc func updateWaitTime() {
        if remainingWaitTime > 0 {
            remainingWaitTime = remainingWaitTime - 1
            self.waitingTimeLbl.text = stringFromTime(interval: remainingWaitTime)
        }else{
            self.stopDriverWaitTime()
        }
    }
    
    func startDriverWaitTime() {
        if self.waitTimer != nil {
            self.waitTimer?.invalidate()
            self.waitTimer = nil
        }
        
        self.waitTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateWaitTime), userInfo: nil, repeats: true)
    }
    
    func stopDriverWaitTime() {
        if self.waitTimer != nil {
            self.remainingWaitTime = waitTime
            self.waitTimer?.invalidate()
            self.waitTimer = nil
        }
    }
}
