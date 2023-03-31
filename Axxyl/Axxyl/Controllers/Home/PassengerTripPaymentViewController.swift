//
//  PassengerTripPaymentViewController.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 10/12/22.
//

import UIKit

protocol PassengerTripEnd : NSObject {
    func tripEndedForPassengerAfterPayment()
}

class PassengerTripPaymentViewController: UIViewController {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var carModelLbl: UILabel!
    @IBOutlet weak var mapsSnapshotImgView: UIImageView!
    @IBOutlet weak var driverProfileImgView: UIImageView!
    @IBOutlet weak var startAddressLbl: UILabel!
    @IBOutlet weak var endAddressLbl: UILabel!
    @IBOutlet weak var totalAmountLbl: UILabel!
    @IBOutlet weak var cardNumberLbl: UILabel!
    var rideStatus : RideStatusResponse?
    var selectedCard : UserCard?
    weak var delegate : PassengerTripEnd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getRideStatus()
        self.getUserCards()
        if let imgDt = UserDefaults.standard.data(forKey: "SNAPSHOT_IMAGE") {
            self.mapsSnapshotImgView.image = UIImage(data: imgDt)
        }
    }
    
    func getRideStatus() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        BookingService.instance.getRideStatus(user_type: "rider", rideId: BookingService.instance.rideIdInProgress!) { [weak self] rideStatus in
            LoadingSpinner.manager.hideLoadingAnimation()
            self?.rideStatus = rideStatus
            DispatchQueue.main.async {
                self?.updateUI()
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
        }
    }
    
    func updateUICardInfo(cards : [UserCard]?){
        guard let allCards = cards else {
            return
        }
        
        for card in allCards {
            if card.isActive() {
                self.cardNumberLbl.text = card.cardnum.getMaskedCardNum(longLength: false)
                break
            }
        }
    }
    
    func getUserCards() {
        LoginService.instance.getCardData {[weak self] cardResponse in
            if cardResponse.isSuccess() {
                if cardResponse.carDetails != nil {
                    DispatchQueue.main.async {
                        self?.updateUICardInfo(cards: cardResponse.carDetails)
                    }
                }else{
                    // TODO : show cards found yet
                }
            }else{
                AlertManager.showErrorAlert(message: cardResponse.msg ?? "Error occurred!!!")
            }
        } errorCallBack: { errMsg in
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func updateUI() {
        
        guard let rStatus = self.rideStatus else {
            AlertManager.showErrorAlert(message: "Failed to laod Ride Status")
            return
        }
        
        // Data used from getrideStatus API
        self.carModelLbl.text = (rStatus.Car?.carModel ?? "") + "(" + (rStatus.Car?.car_number ?? "") + ")"
        self.driverProfileImgView.kf.setImage(with: URL(string: rStatus.User!.profile_image))
        
        if let rideinfo = rStatus.Ride {
            self.startAddressLbl.text = rideinfo.pickupLocation
            self.endAddressLbl.text = rideinfo.dropLocation
        }else{
            //fatalError("Ride info not found in ride status api")
            print("Ride info not found in ride status api")
            return
        }
        
        // from arriveEnd notification
        guard let arriveEndNotiData = APNNotificationService.instance.getNotificationData(notificationType: PushNotificationTypes.ariveEnd) as? ArrivedEndNotificationData else {
            //fatalError("Should not come to this screen if no arrive END is being received")
            print("Should not come to this screen if no arrive END is being received")
            return
        }
        
        self.dateLbl.text = arriveEndNotiData.dropTime
        
        self.totalAmountLbl.text = "$" + self.getTotalAmount(totalPrice: arriveEndNotiData.totalPrice)
    }
    
    func getTotalAmount(totalPrice : String) -> String {
        let total : Double = Double(totalPrice) ?? 0.0
        let tip : Double = Double(BookingService.instance.tipAmount) ?? 0.0
        let final = total + tip
        return "\(final)"
    }
    
    @IBAction func showFareDetailsBtnPressed(_ sender: Any) {
        let sb = UIStoryboard(name: "Home", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "FareDetailsViewController") as! FareDetailsViewController
        
        if let arriveEndNotiData = APNNotificationService.instance.getNotificationData(notificationType: PushNotificationTypes.ariveEnd) as? ArrivedEndNotificationData {
            vcToOpen.totalAmount = self.getTotalAmount(totalPrice: arriveEndNotiData.totalPrice)
            vcToOpen.tipAmount = BookingService.instance.tipAmount
        }
        
        vcToOpen.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = vcToOpen.sheetPresentationController {
                sheet.detents = [.medium()]
            }
        } else {
            // Fallback on earlier versions
        }
        present(vcToOpen,animated: true)
    }
    
    @IBAction func makePaymentBtnClicked(_ sender: Any) {
        self.delegate?.tripEndedForPassengerAfterPayment()
        self.navigationController?.popToRootViewController(animated: true)
    }
}
