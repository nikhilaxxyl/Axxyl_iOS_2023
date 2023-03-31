//
//  DriverDocumentsViewController.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 02/10/22.
//

import UIKit
import Kingfisher

class DriverDocumentsViewController: UIViewController {
    
    @IBOutlet weak var tlcHireBtn1_del: UIButton!
    @IBOutlet weak var commercialVehicleRegBtn2_del: UIButton!
    @IBOutlet weak var commercialVehicleRegBtn1_del: UIButton!
    @IBOutlet weak var insuranceCertBtn1_del: UIButton!
    @IBOutlet weak var vehicleRegBtn1_del: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var driverLicenseBtn1_del: UIButton!
    @IBOutlet weak var tlcHireBtn1: UIButton!
    @IBOutlet weak var headerStepLbl: UILabel!
    @IBOutlet weak var commercialVehicleRegBtn1: UIButton!
    @IBOutlet weak var insuranceCertBtn1: UIButton!
    @IBOutlet weak var vehicleRegBtn1: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var driverLicenseBtn1: UIButton!
    
    var userRegistrationData : UserRegistrationPayload!
    var imagePicker = UIImagePickerController()
    var driverDocument : GetDriverDocumentResponse?
    var driverLicenseImage : UIImage?
    var vehicleRegestrationImage : UIImage?
    var insuranceCertificationImage : UIImage?
    var commercialVehicleRegImage : UIImage?
    var tlcHireImage : UIImage?
    
    var imageTag : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDriverDocuments()
    }
    
    func getDriverDocuments() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.getDriverDocuments { [weak self] documentResponse in
            LoadingSpinner.manager.hideLoadingAnimation()
            guard let weakSelf = self else { return }
            if (documentResponse.isSuccess()){
//                DispatchQueue.main.async {
//                    weakSelf.setupScreen(data: documentResponse)
//                }
            }else{
//                DispatchQueue.main.async {
//                    weakSelf.setupScreen(data: documentResponse)
//                }
                AlertManager.showErrorAlert(message: documentResponse.msg ?? "Error fetching the documents, please try after sometime.")
            }
            weakSelf.driverDocument = documentResponse
            weakSelf.downloadDriverDocs()
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func downloadDriverDocs() {
        if let data = driverDocument, data.isDriverLicencePresent() {
            self.downloadImage(with: (driverDocument?.DriverLicence)!) { image in
                self.driverLicenseImage = image
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            } errorCallBack: { error in
                print("error downloading image")
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            }
        }
        
        if let data = driverDocument, data.isTlcLicencePresent() {
            self.downloadImage(with: (driverDocument?.TlcLicence)!) { image in
                self.tlcHireImage = image
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            } errorCallBack: { error in
                print("error downloading image")
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            }
        }
        
        if let data = driverDocument, data.isInsuranceCertificatePresent() {
            self.downloadImage(with: (driverDocument?.InsuranceCertificate)!) { image in
                self.insuranceCertificationImage = image
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            } errorCallBack: { error in
                print("error downloading image")
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            }
        }
        
        if let data = driverDocument, data.isRegistrationCertificatePresent() {
            self.downloadImage(with: (driverDocument?.RegistrationCertificate)!) { image in
                self.vehicleRegestrationImage = image
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            } errorCallBack: { error in
                print("error downloading image")
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            }
        }
        
        if let data = driverDocument, data.isCertificateofRegistrationCarriagePermitPresent() {
            self.downloadImage(with: (driverDocument?.CertificateofRegistrationCarriagePermit)!) { image in
                self.commercialVehicleRegImage = image
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            } errorCallBack: { error in
                print("error downloading image")
                DispatchQueue.main.async {
                    self.upDateScreen()
                }
            }
        }
    }
    
    func upDateScreen() {

        if let data = driverLicenseImage {
            driverLicenseBtn1.setBackgroundImage(data, for: .normal)
         //   driverLicenseBtn1_del.isHidden = false
        } else {
            driverLicenseBtn1.setBackgroundImage(UIImage(named: "Document_Upload.png"), for: .normal)
            driverLicenseBtn1_del.isHidden = true
        }
        
        if let data = vehicleRegestrationImage {
            vehicleRegBtn1.setBackgroundImage(data, for: .normal)
         //   vehicleRegBtn1_del.isHidden = false
        } else {
            vehicleRegBtn1.setBackgroundImage(UIImage(named: "Document_Upload.png"), for: .normal)
            vehicleRegBtn1_del.isHidden = true
        }
        
        if let data = insuranceCertificationImage {
            insuranceCertBtn1.setBackgroundImage(data, for: .normal)
         //   insuranceCertBtn1_del.isHidden = false
        } else {
            insuranceCertBtn1.setBackgroundImage(UIImage(named: "Document_Upload.png"), for: .normal)
            insuranceCertBtn1_del.isHidden = true
        }
        
        if let data = commercialVehicleRegImage {
            commercialVehicleRegBtn1.setBackgroundImage(data, for: .normal)
        //    commercialVehicleRegBtn1_del.isHidden = false
        } else {
            commercialVehicleRegBtn1.setBackgroundImage(UIImage(named: "Document_Upload.png"), for: .normal)
            commercialVehicleRegBtn1_del.isHidden = true
        }
        
        if let data = tlcHireImage {
            tlcHireBtn1.setBackgroundImage(data, for: .normal)
          //  tlcHireBtn1_del.isHidden = false
        } else {
            tlcHireBtn1.setBackgroundImage(UIImage(named: "Document_Upload.png"), for: .normal)
            tlcHireBtn1_del.isHidden = true
        }
        
    }
    
    @IBAction func imageUploadBtnClicked(_ sender: UIButton) {
        imageTag = sender.tag
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
    
    @IBAction func imageDeleteBtnClicked(_ sender: UIButton) {
        switch sender.tag {
        case 11:
            driverLicenseBtn1.setBackgroundImage(driverLicenseImage != sender.backgroundImage(for: .normal) ? driverLicenseImage : UIImage(named: "Document_Upload"), for: .normal)
            driverLicenseBtn1_del.isHidden = true
        case 21:
            vehicleRegBtn1.setBackgroundImage(vehicleRegestrationImage != sender.backgroundImage(for: .normal) ? vehicleRegestrationImage : UIImage(named: "Document_Upload"), for: .normal)
            vehicleRegBtn1_del.isHidden = true
        case 31:
            insuranceCertBtn1.setBackgroundImage(insuranceCertificationImage != sender.backgroundImage(for: .normal) ? insuranceCertificationImage : UIImage(named: "Document_Upload"), for: .normal)
            insuranceCertBtn1_del.isHidden = true
        case 41:
            commercialVehicleRegBtn1.setBackgroundImage(commercialVehicleRegImage != sender.backgroundImage(for: .normal) ? commercialVehicleRegImage : UIImage(named: "Document_Upload"), for: .normal)
            commercialVehicleRegBtn1_del.isHidden = true
        case 51:
            tlcHireBtn1.setBackgroundImage(tlcHireImage != sender.backgroundImage(for: .normal) ? tlcHireImage : UIImage(named: "Document_Upload"), for: .normal)
            tlcHireBtn1_del.isHidden = true
        default :
            print("Default case")
        }
    }
    
    @IBAction func continueBtnClicked(_ sender: Any) {
        var mediaArray: [Media] = []
        let driverLic_ = Media(withImage: driverLicenseBtn1.backgroundImage(for: .normal), forKey: "file1")
        let vehicleReg_ = Media(withImage: vehicleRegBtn1.backgroundImage(for: .normal), forKey: "file2")
        let insurenceCert_ = Media(withImage: insuranceCertBtn1.backgroundImage(for: .normal), forKey: "file3")
        let commercialVehicleReg_ = Media(withImage: commercialVehicleRegBtn1.backgroundImage(for: .normal), forKey: "file4")
        let tlcHire_ = Media(withImage: tlcHireBtn1.backgroundImage(for: .normal), forKey: "file5")
//        if driverLicenseBtn1.backgroundImage(for: .normal) != UIImage(named: "Document_Upload") {
//            if let data = driverLicenseImage, data == driverLicenseBtn1.backgroundImage(for: .normal) {
//               print("No image change")
//            } else {
//                mediaArray.append(driverLic_!)
//            }
//        }
        
        if !driverLicenseBtn1_del.isHidden {
            mediaArray.append(driverLic_!)
        }
        
        if !vehicleRegBtn1_del.isHidden {
            mediaArray.append(vehicleReg_!)
        }
        
        if !insuranceCertBtn1_del.isHidden {
            mediaArray.append(insurenceCert_!)
        }
        
        if !commercialVehicleRegBtn1_del.isHidden {
            mediaArray.append(commercialVehicleReg_!)
        }
        
        if !tlcHireBtn1_del.isHidden {
            mediaArray.append(tlcHire_!)
        }

        if !mediaArray.isEmpty {
            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.uploadDriverDocument(documents: mediaArray) {  uploadResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if uploadResponse.isSuccess() {
                    DispatchQueue.main.async {
                        LoadingSpinner.manager.hideLoadingAnimation()
                        AlertManager.showInfoAlert(message: "Documents Updated Successfully!")
                    }
                }else{
                    LoadingSpinner.manager.hideLoadingAnimation()
                    AlertManager.showErrorAlert(message: uploadResponse.msg ?? "Document upload failed")
                }

            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        } else {
            AlertManager.showInfoAlert(message: "No Image change to upload")
        }
   // }
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension DriverDocumentsViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            switch imageTag {
            case 111:
                driverLicenseBtn1.setBackgroundImage(image, for: .normal)
                driverLicenseBtn1_del.isHidden = false
            case 211:
                vehicleRegBtn1.setBackgroundImage(image, for: .normal)
                vehicleRegBtn1_del.isHidden = false
            case 311:
                insuranceCertBtn1.setBackgroundImage(image, for: .normal)
                insuranceCertBtn1_del.isHidden = false
            case 411:
                commercialVehicleRegBtn1.setBackgroundImage(image, for: .normal)
                commercialVehicleRegBtn1_del.isHidden = false
            case 511:
                tlcHireBtn1.setBackgroundImage(image, for: .normal)
                tlcHireBtn1_del.isHidden = false
            default :
                print("Default case")
            }
        }
        self.dismiss(animated: true)
    }
    
    func downloadImage(`with` urlString : String, successCallBack: @escaping (UIImage) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let url = URL.init(string: urlString) else {
            return
        }
        let resource = ImageResource(downloadURL: url)

        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
                print("Image: \(value.image). Got from: \(value.cacheType)")
                successCallBack(value.image)
            case .failure(let error):
                print("Error: \(error)")
                errorCallBack(error.localizedDescription)
            }
        }
    }
}
