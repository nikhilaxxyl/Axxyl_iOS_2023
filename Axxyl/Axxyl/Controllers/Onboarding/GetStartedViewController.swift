//
//  GetStartedViewController.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 17/09/22.
//

import UIKit

class GetStartedViewController: UIViewController {

    @IBOutlet weak var backgroundImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func loadHome() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            appDelegate.loadHome()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        if let savedUserInfo = LoginService.instance.checkLoginData() {
            LoginService.instance.loginUser(email: savedUserInfo.emailId, password: savedUserInfo.password2) {[weak self] userLoginResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if userLoginResponse.isSuccess() {
                    LoginService.instance.setCurrentUser(user: userLoginResponse.user)
                    DriverService.instance.isOnline = userLoginResponse.user!.bookingOn == "1" ? true : false
                    self?.loadHome()
                }else{
                    AlertManager.showErrorAlert(message: userLoginResponse.msg)
                }
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        }else{
            LoadingSpinner.manager.hideLoadingAnimation()
        }
    }

}
