//
//  EditProfileViewController.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 30/09/22.
//

import UIKit
import Kingfisher

class EditProfileViewController: UIViewController {

    @IBOutlet weak var headerView: NewHeaderView!
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var countryCodeTxtField: UILabel!
    @IBOutlet weak var phoneNumberTxtField: UITextField!
    @IBOutlet weak var saveChangesBtnPressed: GradientButton!
    @IBOutlet weak var profileImgView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    let myuser = LoginService.instance.getCurrentUser()
    var profileImage: UIImage!
    var isImageChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
        //self.saveChangesBtnPressed.addTarget(self, action: #selector(EditProfileViewController.saveChangesBtnClicked), for: UIControl.Event.touchUpInside)
        self.headerView.delegate = self
        self.headerView.setConfiguration()
    }
    
    func setInitialValues() {
        if let currentUser = LoginService.instance.getCurrentUser() {
            var nameComponents = currentUser.name.components(separatedBy: " ")
            self.firstNameTxtField.text = nameComponents.removeFirst()
            self.lastNameTxtField.text = nameComponents.joined(separator: " ")
            self.countryCodeTxtField.text = currentUser.country
            self.phoneNumberTxtField.text = currentUser.phone
            self.emailTxtField.text = currentUser.emailId
            self.profileImgView.kf.setImage(with: URL(string: currentUser.profile_image))
            self.profileImage = self.profileImgView.image
        }
    }
    
    func openImageSelectionActionSheet() {
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
    
    @IBAction func uploadImageClicked(_ sender: Any) {
        openImageSelectionActionSheet()
    }
    
    @IBAction func countryCodeSelectionClicked(_ sender: Any) {
        let countryCodeVC = CountryListViewController()
        countryCodeVC.delegate = self
        let navController = UINavigationController(rootViewController: countryCodeVC)
        self.present(navController, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveChangesBtnClicked(_ sender : GradientButton) {
        guard let firstName_ = self.firstNameTxtField.text, !firstName_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter first name")
            return
        }
        
        guard let lastName_ = self.lastNameTxtField.text, !lastName_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter last name")
            return
        }
        
        guard let countryCode_ = self.countryCodeTxtField.text, !countryCode_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select valid country code")
            return
        }
        
        guard let phoneNumber_ = self.phoneNumberTxtField.text, !phoneNumber_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter phone number")
            return
        }
        
        guard let emailId = self.emailTxtField.text, !emailId.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter email")
            return
        }
        
        if !emailId.validateEmail() {
            AlertManager.showErrorAlert(message: "Please enter valid email id")
            return
        }
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            AlertManager.showErrorAlert(message: "Failed to load profile")
            return
        }
        
        let username = currentUser.name.components(separatedBy: " ")
        
        if let imageData = profileImgView.image, profileImage == nil || imageData.pngData() != profileImage.pngData() {
            isImageChanged = true
        }
        
        if (firstName_ != username[0] || lastName_ != username[1] || countryCode_ != currentUser.country || phoneNumber_ != currentUser.phone || emailId != currentUser.emailId) || isImageChanged {
            let editedProfile = EditProfilePayload(userId: currentUser.id, fname: firstName_, lname: lastName_, phone: phoneNumber_, countryCode: countryCode_, handicapped: currentUser.handicapped, profile_image: Media(withImage: profileImgView.image, forKey: "profile_image"))

            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            //LoginService.instance.editProfile(updatedProfile: editedProfile) { [weak self] updatedLoginResponse in
            DriverService.instance.updateDriver(data: editedProfile) { [weak self] updatedLoginResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if updatedLoginResponse.isSuccess() {
                    LoginService.instance.setCurrentUser(user: updatedLoginResponse.user)
                    DispatchQueue.main.async {
                        self?.backAction(UIButton())
                    }
                }else{
                    AlertManager.showErrorAlert(message: updatedLoginResponse.msg)
                }

            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        } else {
            AlertManager.showInfoAlert(message: "No data changed to update the profile")
        }
    }
    
//    func uploadImage() {
//        let urlPath = "Your URL"
//        guard let endpoint = URL(string: "https://axxyl.com/webservices_android") else {
//            print("Error creating endpoint")
//            return
//        }
//        var request = URLRequest(url: endpoint)
//        request.httpMethod = "POST"
//        let boundary = "Boundary-\(UUID().uuidString)"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        let mimeType = "image/jpg"
//        let body = NSMutableData()
//        let boundaryPrefix = " — \(boundary)\r\n"
//        body.append(boundaryPrefix.data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"\("action")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\(Actions.editprofile.rawValue)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"\("userId")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\("1271")\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"\("fname")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\("Mike")\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"\("lname")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\("Hussy")\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"\("phone")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\("1234567890")\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"\("handicapped")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\("0")\r\n".data(using: .utf8)!)
//        let imageData = profileImgView.image!.jpegData(compressionQuality: 1.0)!
//        var filename = "MKTestImage"
//        body.append("Content-Disposition: form-data; name=\"\("profile_image")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\("1271")\r\n".data(using: .utf8)!)
//
//        body.append(boundaryPrefix.data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
//        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
//        body.append(imageData)
//        body.append("\r\n".data(using: .utf8)!)
//        let str = " — ".appending(boundary.appending(" — "))
//        body.append(str.data(using: .utf8)!)
//        request.httpBody = body.base64EncodedData()
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            do {
//                LoadingSpinner.manager.hideLoadingAnimation()
//                print("\(String(describing: response))")
//                print("\(String(describing: error))")
//            }
//        }
//    }
//
//    func uploadImageToServer() {
//       let parameters = Parameters(name: "MyTestFile123321", id: "1271")// ["name": "MyTestFile123321","id": "12345"]
//        guard let mediaImage = Media(withImage: profileImgView.image!, forKey: "profile_image") else { return }
//       guard let url = URL(string: "https://axxyl.com/webservices_android") else { return }
//       var request = URLRequest(url: url)
//       request.httpMethod = "POST"
//       //create boundary
//       let boundary = generateBoundary()
//       //set content type
//       request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//       //call createDataBody method
//       let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
//       request.httpBody = dataBody
//       let session = URLSession.shared
//       session.dataTask(with: request) { (data, response, error) in
//          if let response = response {
//             print(response)
//          }
//          if let data = data {
//             do {
//                let json = try JSONSerialization.jsonObject(with: data, options: [])
//                print(json)
//                 LoadingSpinner.manager.hideLoadingAnimation()
//             } catch {
//                print(error)
//             }
//          }
//       }.resume()
//    }
//
//    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
//       let lineBreak = "\r\n"
//       var body = Data()
//       if let parameters = params {
//           // driver document upload
////           body.append("--\(boundary + lineBreak)")
////           body.append("Content-Disposition: form-data; name=\"\("action")\"\(lineBreak + lineBreak)")
////           body.append("\("uploadDoc" + lineBreak)")
////
////           body.append("--\(boundary + lineBreak)")
////           body.append("Content-Disposition: form-data; name=\"\("userId")\"\(lineBreak + lineBreak)")
////           body.append("\("1337" + lineBreak)") //1239
//
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("action")\"\(lineBreak + lineBreak)")
//           body.append("\("editprofile" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("userId")\"\(lineBreak + lineBreak)")
//           body.append("\("1239" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("fname")\"\(lineBreak + lineBreak)")
//           body.append("\("max" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("lname")\"\(lineBreak + lineBreak)")
//           body.append("\("payne" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("phone")\"\(lineBreak + lineBreak)")
//           body.append("\("123456789" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("handicapped")\"\(lineBreak + lineBreak)")
//           body.append("\("0" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("car_number")\"\(lineBreak + lineBreak)")
//           body.append("\("GB16879" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("carTypeId")\"\(lineBreak + lineBreak)")
//           body.append("\("22" + lineBreak)") //1239
//       }
//       if let media = media {
//          for photo in media {
//             body.append("--\(boundary + lineBreak)")
//             body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
//             body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
//             body.append(photo.data)
//             body.append(lineBreak)
//          }
//       }
//       body.append("--\(boundary)--\(lineBreak)")
//       return body
//    }
}

extension EditProfileViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EditProfileViewController : NewHeaderViewProtocol {
    var headerTitle: String {
        return "Edit Profile"
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    var isBackEnabled: Bool {
        return true
    }
}

extension EditProfileViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImgView.image = image
        }
        self.dismiss(animated: true)
    }
}

extension EditProfileViewController : CountryCodeSelectionDelegate {
    func didSelectCountry(country: Country) {
        self.countryCodeTxtField.text = country.dial_code
    }
}
