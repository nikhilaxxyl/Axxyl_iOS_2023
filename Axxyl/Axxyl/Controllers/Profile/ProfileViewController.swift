//
//  ProfileViewController.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 29/09/22.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController {

    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUIWithValues()
    }
    
    func updateUIWithValues() {
        if let currentUser = LoginService.instance.getCurrentUser() {
            self.fullNameLbl.text = currentUser.name
            self.phoneNumberLbl.text = currentUser.phone
            self.emailLbl.text = currentUser.emailId
            self.profileImgView.kf.setImage(with: URL(string: currentUser.profile_image))
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
