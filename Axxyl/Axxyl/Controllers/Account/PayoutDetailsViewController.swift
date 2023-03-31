//
//  PayoutDetailsViewController.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 02/10/22.
//

import UIKit

class PayoutDetailsViewController: UIViewController {

    @IBOutlet weak var accountHolderNameTxtFld: UITextField!
    @IBOutlet weak var bankNameTxtFld: UITextField!
    @IBOutlet weak var routingNumTxtFld: UITextField!
    @IBOutlet weak var accountNumTxtFld: UITextField!
    @IBOutlet weak var reEnterAccountNumTxtFld: UITextField!
    @IBOutlet weak var mailingAddrsTxtFld: UITextField!
    @IBOutlet weak var continueBtn: GradientButton!
    @IBOutlet weak var editModeBtnStackView: UIStackView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var headerLblTxt: UILabel!
    @IBOutlet weak var headerStepLblTxt: UILabel!
    
    var driverRegistrationData : DriverRegistrationPayload!
    var payoutDetails: BankAccount!
    var screenMode: PayoutDetaisScreenMode = PayoutDetaisScreenMode.editPayoutDetails
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateScreen()
    }
    
    func updateScreen() {
        
        switch screenMode {
        case .registerDriverPayoutDetails:
            self.headerLblTxt.text = "Payout details"
            self.backBtn.isHidden = true
            self.headerStepLblTxt.isHidden = false
            self.editModeBtnStackView.isHidden = true
            self.continueBtn.isHidden = false
        case .editPayoutDetails:
            self.headerLblTxt.text = "Edit payout details"
            self.backBtn.isHidden = false
            self.headerStepLblTxt.isHidden = true
            self.editModeBtnStackView.isHidden = false
            self.continueBtn.isHidden = true
            if (payoutDetails != nil) { // Edit Mode
                self.accountHolderNameTxtFld.text = payoutDetails.name
                self.accountNumTxtFld.text = payoutDetails.account_number
                self.bankNameTxtFld.text = payoutDetails.bankname
                self.routingNumTxtFld.text = payoutDetails.routing_number
                self.mailingAddrsTxtFld.text = payoutDetails.email
            }
        }
    }
    

    @IBAction func useDirectDepositPressed(_ sender: Any) {
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        guard let bankAccount = validateForm() else {
            return
        }
        driverRegistrationData.bankname = bankAccount.bankname
        driverRegistrationData.account_name = bankAccount.name
        driverRegistrationData.account_number = bankAccount.account_number
        driverRegistrationData.routing_number = bankAccount.routing_number
        driverRegistrationData.account_emailId = bankAccount.email
        let sb = UIStoryboard(name: "Payment", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "AddPaymentViewController") as! AddPaymentViewController
        vcToOpen.driverRegistrationData = driverRegistrationData
        vcToOpen.screenMode = CreditCardPaymentScreenMode.registerDriverCard
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    @IBAction func saveChangesBtnClicked(_ sender: Any) {
        guard let bankAccount = validateForm() else {
            return
        }
        if bankAccount != payoutDetails {
            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            DriverService.instance.editDriverPayoutDetails(accountData: bankAccount) {[weak self] payoutDetailsResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if payoutDetailsResponse.isSuccess() {
                    let cancleAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { action in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    AlertManager.showCustomAlertWith("Success", message: payoutDetailsResponse.msg ?? "Driver payout details updated successfully.", actions: [cancleAction])
                }else{
                    AlertManager.showErrorAlert(message: payoutDetailsResponse.msg ?? "Error while adding car")
                }
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        } else {
            print("send update request")
        }
    }
    
    private func validateForm() -> BankAccount? {
        guard let bankName_ = self.bankNameTxtFld.text, !bankName_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter bank name")
            return nil
        }
        
        guard let accountName_ = self.accountHolderNameTxtFld.text, !accountName_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter account name")
            return nil
        }
        
        guard let routingNumber_ = self.routingNumTxtFld.text, !routingNumber_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter routing number")
            return nil
        }
        
        guard let accountNumber_ = self.accountNumTxtFld.text, !accountNumber_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter account number")
            return nil
        }
        
        guard let reEnteredAcoountNumber_ = self.reEnterAccountNumTxtFld.text, !reEnteredAcoountNumber_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please re-enter account number")
            return nil
        }
        
        if accountNumber_ != reEnteredAcoountNumber_ {
            AlertManager.showErrorAlert(message: "Account number and re-entered account number does not match")
            return nil
        }
        
//        guard let email_ = self.mailingAddrsTxtFld.text, !email_.isEmpty else {
//            AlertManager.showErrorAlert(message: "Please enter email id")
//            return nil
//        }

        guard let email_ = self.mailingAddrsTxtFld.text else {
            return nil
        }
        
        if email_ != "", !email_.validateEmail() {
            AlertManager.showErrorAlert(message: "Please enter valid email id")
        }
        
        return BankAccount(bankname: bankName_, name: accountName_, account_number: accountNumber_, routing_number: routingNumber_, email: email_, active: "Yes")
    }

}


extension PayoutDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



