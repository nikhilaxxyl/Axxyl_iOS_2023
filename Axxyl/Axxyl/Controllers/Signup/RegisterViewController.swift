//
//  RegisterViewController.swift
//  axxyl
//
//  Created by Axxyl Inc. on 19/09/22.
//

import UIKit

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var headerView: NewHeaderView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var countryCode: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var reEnteredPassword: UITextField!
    @IBOutlet weak var passwordVisibility: UIButton!
    @IBOutlet weak var reEnteredPasswordVisibility: UIButton!
    @IBOutlet weak var tncTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var wheelChairCheckBoxView: UIStackView!
    @IBOutlet weak var tncCheckBoxBtn: CheckBoxButton!
    @IBOutlet weak var isWheelChairCBBtn: CheckBoxButton!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerView.delegate = self;
        headerView.setConfiguration()
        if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.driver.rawValue {
            wheelChairCheckBoxView.isHidden = true
            tncTopConstraints.constant = -wheelChairCheckBoxView.frame.height - 5
        } 
    }
    
    @IBAction func editImageBtn(_ sender: Any) {
        openImageSelectionActionSheet()
    }
    
    @IBAction func countryCodesBtn(_ sender: Any) {
        let countryCodeVC = CountryListViewController()
        countryCodeVC.delegate = self
        let navController = UINavigationController(rootViewController: countryCodeVC)
        self.present(navController, animated: true)
    }
    
    
    @IBAction func passwordVisibilityBtn(_ sender: Any) {
        if password.isSecureTextEntry {
            passwordVisibility.setImage(UIImage(named: "Visibility_Off.png"), for: .normal)
            password.isSecureTextEntry = false
        } else {
            passwordVisibility.setImage(UIImage(named: "Visibility.png"), for: .normal)
            password.isSecureTextEntry = true
        }
    }
    
    @IBAction func reEnteredPasswordVisibilityBtn(_ sender: Any) {
        if reEnteredPassword.isSecureTextEntry {
            reEnteredPasswordVisibility.setImage(UIImage(named: "Visibility_Off.png"), for: .normal)
            reEnteredPassword.isSecureTextEntry = false
        } else {
            reEnteredPasswordVisibility.setImage(UIImage(named: "Visibility.png"), for: .normal)
            reEnteredPassword.isSecureTextEntry = true
        }
    }
    
    @IBAction func wheelchairCheckboxBtn(_ sender: CheckBoxButton) {
        sender.isChecked = !sender.isChecked
    }
    
    
    @IBAction func termsCondidtionCheckboxBtn(_ sender: CheckBoxButton) {
        sender.isChecked = !sender.isChecked
    }
    
    @IBAction func continueBtn(_ sender: Any) {
        guard let userInfo = validateForm() else {
            return
        }
        if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.passenger.rawValue {
            let sb = UIStoryboard(name: "Payment", bundle: nil)
            let vcToOpen = sb.instantiateViewController(withIdentifier: "AddPaymentViewController") as! AddPaymentViewController
            vcToOpen.userRegistrationData = userInfo
            vcToOpen.isOnboarding = true
            vcToOpen.screenMode = CreditCardPaymentScreenMode.registerPassangerCard
            self.navigationController?.pushViewController(vcToOpen, animated: true)
        } else {
            let sb = UIStoryboard(name: "Signup", bundle: nil)
            let vcToOpen = sb.instantiateViewController(withIdentifier: "VehicleDetailsViewController") as! VehicleDetailsViewController
            vcToOpen.screenMode = VehicleScreenMode.RegisterCar
            vcToOpen.driverRegistrationData = (userInfo as! DriverRegistrationPayload)
            self.navigationController?.pushViewController(vcToOpen, animated: true)
        }
    }

    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    private func validateForm() -> UserRegistrationPayload? {
        guard let firstName_ = self.firstName.text, !firstName_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter first name")
            return nil
        }
        
        guard let lastName_ = self.lastName.text, !lastName_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter last name")
            return nil
        }
        
        guard let phoneNumber_ = self.phoneNumber.text, !phoneNumber_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter phone number")
            return nil
        }
        
        guard let emailId = self.email.text, !emailId.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter email")
            return nil
        }
        
        if !emailId.validateEmail() {
            AlertManager.showErrorAlert(message: "Please enter valid email id")
            return nil
        }
        
        guard let password_ = self.password.text, !password_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter password")
            return nil
        }
        
        guard let confirmPassword = self.reEnteredPassword.text, !confirmPassword.isEmpty else {
            AlertManager.showErrorAlert(message: "Please re-enter password")
            return nil
        }
        
        if password_ != confirmPassword {
            AlertManager.showErrorAlert(message: "Password does not match")
            return nil
        }
    
        if !tncCheckBoxBtn.isChecked {
            AlertManager.showInfoAlert(message: "Please accept AXXYL's Term and Conditions by tapping on checkbox.")
            return nil
        }
        
        /* Commented as it is optional field*/
//        guard let image_ = self.profileImage.image else {
//            AlertManager.showErrorAlert(message: "Please upload image")
//            return nil
//        }
        
        let imageObj = Media(withImage: self.profileImage.image, forKey: "profile_image")
        
        let registrationDt: UserRegistrationPayload!
        if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.passenger.rawValue {
            registrationDt = UserRegistrationPayload()
            registrationDt.handicapped = isWheelChairCBBtn.isChecked
            registrationDt.usertype = UserType(rawValue: UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype) ?? UserType.passenger.rawValue)
        } else {
            registrationDt = DriverRegistrationPayload()
            registrationDt.usertype = UserType(rawValue: UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype) ?? UserType.driver.rawValue)
        }
        registrationDt.emailId = emailId
        registrationDt.firstName = firstName_
        registrationDt.lastName = lastName_
        registrationDt.password = password_
        registrationDt.countryCode = self.countryCode.text ?? "+1"
        registrationDt.phoneNumber = phoneNumber_
        registrationDt.profile_image = imageObj

        return registrationDt
    }
    
    private func openImageSelectionActionSheet() {
        let actionMenu = UIAlertController(title: "Choose User's Photo", message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { (UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        })
        let chooseLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { (UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
            self.dismiss(animated: true)
        })
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            actionMenu.addAction(takePhotoAction)
        }
        actionMenu.addAction(chooseLibraryAction)
        actionMenu.addAction(cancelAction)
        self.present(actionMenu, animated: true, completion: nil)
    }
}

extension RegisterViewController : NewHeaderViewProtocol {
    var headerTitle: String {
        return "Create an account"
    }
    
    var isBackEnabled: Bool {
        return true
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension RegisterViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.image = image
        }
        self.dismiss(animated: true)
    }
}


extension RegisterViewController : CountryCodeSelectionDelegate {
    func didSelectCountry(country: Country) {
        self.countryCode.text = country.dial_code
    }
}
