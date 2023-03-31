//
//  PaymentViewController.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 25/09/22.
//

import UIKit

protocol CardEditProtocol : AnyObject {
    func editCardSuccess(cardDt : UserCard)
}

class AddPaymentViewController: UIViewController {

    weak var editDelegate : CardEditProtocol?
    @IBOutlet weak var cardNumberTxtField: UITextField!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardCVVTxtField: UITextField!
    @IBOutlet weak var cardHolderNameTxtField: UITextField!
    @IBOutlet weak var cancelPayment: GradientButton!
    @IBOutlet weak var savePayment: GradientButton!
    @IBOutlet weak var cardExpiryDateTxtField: UITextField!
    @IBOutlet weak var axxylFeeStackView: UIStackView!
    @IBOutlet weak var headerStepLblTxt: UILabel!
    @IBOutlet weak var editPaymentBtnStackView: UIStackView!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var addPaymentBtn: UIButton!
    @IBOutlet weak var onboardingButtonsStackView: UIStackView!
    @IBOutlet weak var backBtn: UIButton!
    
    var userRegistrationData : UserRegistrationPayload!
    var driverRegistrationData : DriverRegistrationPayload!
    var card: UserCard!
    var isOnboarding:  Bool = false
    var screenMode: CreditCardPaymentScreenMode = CreditCardPaymentScreenMode.addCard
    var titleString = "Payment method"
    var updatedCardData : UserCard?
    var expiryDateTypePickerView : UIPickerView!
    let months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    var years : [String]?
    var selectedMonthRow = 0
    var selectedYearRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if (isOnboarding){
//            self.onboardingButtonsStackView.isHidden = false
//            self.addPaymentBtn.isHidden = true
//            self.backBtn.isHidden = true
//        }else{
//            self.onboardingButtonsStackView.isHidden = true
//            self.addPaymentBtn.isHidden = false
//            self.backBtn.isHidden = false
//        }
        
//        if (card != nil) { // Edit Mode
//            cardNumberTxtField.text = card.cardnum;
////            cardImage.image = UIImage(named: "Visa")
//            cardHolderNameTxtField.text = card.cardname
//            cardExpiryDateTxtField.text = "\(card.cardexpmonth)/\(card.cardexpyear)"
//            cardCVVTxtField.text = ""
//            self.editPaymentBtnStackView.isHidden = false
//            self.backBtn.isHidden = false
//            self.onboardingButtonsStackView.isHidden = true
//            self.addPaymentBtn.isHidden = true
//            self.view.layoutIfNeeded()
//        }
        self.headerLbl.text = titleString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getYearsData()
        updateScreen()
    }
    
    func updateScreen() {
        self.headerStepLblTxt.isHidden = true
        self.axxylFeeStackView.isHidden = true
        switch screenMode {
        case .addCard:
            self.cancelPayment.setTitle("Cancel", for: .normal)
            self.savePayment.setTitle("Save", for: .normal)
            self.onboardingButtonsStackView.isHidden = false
            self.addPaymentBtn.isHidden = true
            self.backBtn.isHidden = true
        case .editCard:
            self.cancelPayment.setTitle("Cancel", for: .normal)
            self.savePayment.setTitle("Save", for: .normal)
            if (card != nil) { // Edit Mode
                cardNumberTxtField.text = card.cardnum;
    //            cardImage.image = UIImage(named: "Visa")
                cardHolderNameTxtField.text = card.cardname
                cardExpiryDateTxtField.text = "\(card.cardexpmonth)/\(card.cardexpyear)"
                selectedMonthRow = months.firstIndex(of: card.cardexpmonth) ?? 0
                selectedYearRow = years?.firstIndex(of: card.cardexpyear) ?? 0
                cardCVVTxtField.text = ""
                self.editPaymentBtnStackView.isHidden = false
                self.backBtn.isHidden = false
                self.onboardingButtonsStackView.isHidden = true
                self.addPaymentBtn.isHidden = true
                self.view.layoutIfNeeded()
            }

        case .registerPassangerCard:
            self.onboardingButtonsStackView.isHidden = false
            self.addPaymentBtn.isHidden = true
            self.backBtn.isHidden = true
            
        case .registerDriverCard:
            self.backBtn.isHidden = true
            self.onboardingButtonsStackView.isHidden = true
            self.headerLbl.text = "Credit Card Details"
            self.headerStepLblTxt.isHidden = false
            self.addPaymentBtn.setTitle("Submit", for: .normal)
            self.addPaymentBtn.isHidden = false
            self.axxylFeeStackView.isHidden = false
            
        case .addPaymentMethod:
            self.onboardingButtonsStackView.isHidden = true
            self.addPaymentBtn.isHidden = false
            self.backBtn.isHidden = true
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func expiryDateInfoBtn(_ sender: Any) {
        AlertManager.showInfoAlert(message: "Please enter expiry date mentioned on your card")
    }
    
    @IBAction func cvvInfoBtn(_ sender: Any) {
        AlertManager.showInfoAlert(message: "Please enter CVV number mentioned on the back side of your card")
    }
    
    @IBAction func skipStepBtn(_ sender: Any) {
        if screenMode == CreditCardPaymentScreenMode.registerPassangerCard {
            self.userRegistrationData.cardcvv = ""
            self.userRegistrationData.cardnum = ""
            self.userRegistrationData.cardname = ""
            self.userRegistrationData.cardexpyear = ""
            self.userRegistrationData.cardexpmonth = ""
            self.sendRegistrationRequest()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func addPaymentBtnPressed(_ sender: Any) {
        guard let cardData = validateForm() else {
            return
        }
        
        if screenMode == CreditCardPaymentScreenMode.registerDriverCard {
            self.driverRegistrationData.cardcvv = cardData.cardcvv
            self.driverRegistrationData.cardnum = cardData.cardnum
            self.driverRegistrationData.cardname = cardData.cardname
            self.driverRegistrationData.cardexpyear = cardData.cardexpyear
            self.driverRegistrationData.cardexpmonth = cardData.cardexpmonth
            self.sendRegistrationRequest()
        } else {
            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            LoginService.instance.addPaymentMethod(cardData: cardData) {[weak self] cardResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if cardResponse.isSuccess() {
                    self?.updatedCardData = cardData
                    self?.navigateBack()
                }else{
                    AlertManager.showErrorAlert(message: cardResponse.msg ?? "Error while adding payment method")
                }
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        }
    }
    
    func loadHome() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            appDelegate.loadHome()
        }
    }
    
    func loadLanding() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            appDelegate.loadLanding()
        }
    }
    
    func getYearsData() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let endYear = currentYear + 10;
        years = (currentYear...endYear).map { String($0) }
    }
    
    func setupPickerViewfor(_ textField : UITextField){

        expiryDateTypePickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        expiryDateTypePickerView.delegate = self
        expiryDateTypePickerView.dataSource = self
        expiryDateTypePickerView.backgroundColor = UIColor.white
        cardExpiryDateTxtField.inputView = expiryDateTypePickerView

        // ToolBar
       // let toolBar = UIToolbar()
        let toolBar: UIToolbar = {
            let v = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 44.0)))
            return v
        }()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92.0/255.0, green: 216.0/255.0, blue: 255.0/255.0, alpha: 1)
        toolBar.sizeToFit()

        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.pickerDoneClicked))
        doneButton.tintColor = .black
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.pickerCancelClicked))
        cancelButton.tintColor = .black
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        cardExpiryDateTxtField.inputAccessoryView = toolBar

    }
    
    @objc func pickerDoneClicked() {
        cardExpiryDateTxtField.resignFirstResponder()
    }
    
    @objc func pickerCancelClicked() {
        cardExpiryDateTxtField.resignFirstResponder()
    }
    
    
    func sendRegistrationRequest() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.passenger.rawValue {
//        if LoginService.instance.currentUserType ==  UserType.passenger {
            LoginService.instance.registerNewUser(data: userRegistrationData) {[weak self] signupResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if signupResponse.isSuccess() {
                    LoginService.instance.setCurrentUser(user: signupResponse.user)
                    self?.loadHome()
                }else{
                    AlertManager.showErrorAlert(message: signupResponse.msg)
                }
            } errorCallBack: { errMg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMg)
            }
        } else {
            DriverService.instance.registerNewUser(data: driverRegistrationData) {[weak self] signupResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if signupResponse.isSuccess() {
                    if signupResponse.user != nil{
                        LoginService.instance.setCurrentUser(user: signupResponse.user)
                        self?.loadHome()
                    } else {
                        let cancleAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { action in
                            self?.loadLanding()
                        }
                        AlertManager.showCustomAlertWith("Information", message: "Registration has been successful.\("\n")Please wait for admin approval.", actions: [cancleAction])
                    }
                   
                }else{
                    AlertManager.showErrorAlert(message: signupResponse.msg)
                }
            } errorCallBack: { errMg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMg)
            }
        }
    }
    
    func navigateBack() {
        
        if editDelegate != nil {
            editDelegate?.editCardSuccess(cardDt: self.updatedCardData!)
        }
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    @IBAction func updatePaymentMethodBtnPressed(_ sender: Any) {
        if let cardData = validateForm() {
            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            LoginService.instance.updatePaymentMethod(cardData: cardData, oldCardNum: card.cardnum) {[weak self] cardResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if cardResponse.isSuccess() {
                    self?.updatedCardData = cardData
                    self?.navigateBack()
                }else{
                    AlertManager.showErrorAlert(message: cardResponse.msg ?? "Error while updating payment method")
                }
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        }
    }
    
    @IBAction func submitBtn(_ sender: Any) {
        if let cardData = validateForm() {
            if screenMode == CreditCardPaymentScreenMode.registerPassangerCard {
                self.userRegistrationData.cardcvv = cardData.cardcvv
                self.userRegistrationData.cardnum = cardData.cardnum
                self.userRegistrationData.cardname = cardData.cardname
                self.userRegistrationData.cardexpyear = cardData.cardexpyear
                self.userRegistrationData.cardexpmonth = cardData.cardexpmonth
                self.sendRegistrationRequest()
            } else {
                LoadingSpinner.manager.showLoadingAnimation(delegate: self)
                LoginService.instance.addPaymentMethod(cardData: cardData) {[weak self] cardResponse in
                    LoadingSpinner.manager.hideLoadingAnimation()
                    if cardResponse.isSuccess() {
                        self?.updatedCardData = cardData
                        self?.navigateBack()
                    }else{
                        AlertManager.showErrorAlert(message: cardResponse.msg ?? "Error while adding payment method")
                    }
                } errorCallBack: { errMsg in
                    LoadingSpinner.manager.hideLoadingAnimation()
                    AlertManager.showErrorAlert(message: errMsg)
                }
            }
        }
    }
    
    private func validateForm() -> UserCard? {
        guard let cardNumber = self.cardNumberTxtField.text, !cardNumber.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter card number mention on the front side of your card")
            return nil
        }
        
        guard let expiryDt = self.cardExpiryDateTxtField.text, !expiryDt.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter expiry month and year")
            return nil
        }
        
        guard let cvv = self.cardCVVTxtField.text, !cvv.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter cvv")
            return nil
        }
        
        guard let name = self.cardHolderNameTxtField.text, !name.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter card holder name")
            return nil
        }
        
        let expiryData = expiryDt.components(separatedBy: "/")
        
        let cardData = UserCard(cardname: name, cardnum: cardNumber, cardcvv: cvv, cardexpmonth: expiryData[0] , cardexpyear: expiryData[1], active: "yes")
        return cardData
    }
   
}

extension AddPaymentViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? months.count : years?.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? months[row] : years?[row] ?? ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedMonthRow = row
        } else if component == 1 {
            selectedYearRow = row
        }
        
        cardExpiryDateTxtField.text = "\(months[selectedMonthRow])/\(years![selectedYearRow])"
    }
}

extension AddPaymentViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == cardExpiryDateTxtField {
            setupPickerViewfor(cardExpiryDateTxtField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cardExpiryDateTxtField {
            cardExpiryDateTxtField.text = "\(String(months[selectedMonthRow]))/\(String(years![selectedYearRow]))"
            return false
        }
        return true
    }
}
