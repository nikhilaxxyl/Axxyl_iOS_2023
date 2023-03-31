//
//  LoginService.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 24/09/22.
//

import Foundation

typealias GenericDictionary = Dictionary<String, AnyObject>

class LoginService : NSObject {
    static let instance = LoginService()
    private var currentUser : UserInfo?
    private override init() {
        super.init()
    }
    
    func setCurrentUser(user : UserInfo?) {
        self.currentUser = user
        if let userInfo = user {
            do {
                let encoder = JSONEncoder()
                let userData = try encoder.encode(userInfo)
                UserDefaults.standard.setValue(userData, forKey: AppUserDefaultsKeys.currentUserData)
            } catch {
                print("error saving user information")
            }
        }
    }
    
    func logoutCurrentUser(){
        UserDefaults.standard.removeObject(forKey: AppUserDefaultsKeys.currentUserData)
        setCurrentUser(user: nil)
        APNNotificationService.instance.clearCachedNotifications()
    }
    
    func checkLoginData() -> UserInfo? {
        if let currentUserDt = UserDefaults.standard.data(forKey: AppUserDefaultsKeys.currentUserData) {
            do {
                let jsonDecoder = JSONDecoder()
                let decodedResponse = try jsonDecoder.decode(UserInfo.self,
                                                             from: currentUserDt)
                return decodedResponse
            } catch {
                print("error saving user information")
            }
        }
        return nil
    }
    
    func getCurrentUser() -> UserInfo? {
        return currentUser
    }
    
    var currentUserType : UserType {
        if let user = currentUser {
            return UserType(rawValue: user.usertype) ?? .passenger
        }
        return .passenger
    }
    
    func loginUser(email:String, password:String, success : @escaping (UserLoginResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        var payloadDict = GenericDictionary();
        payloadDict.updateValue(Actions.login.rawValue as AnyObject, forKey: "action");
        payloadDict.updateValue(email as AnyObject, forKey: "emailId")
        payloadDict.updateValue(password as AnyObject, forKey: "password")
        payloadDict.updateValue("ios" as AnyObject, forKey: "device")
        payloadDict.updateValue("version: 1" as AnyObject, forKey: "updatemobile")
        
        guard let devToken = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.deviceToken) else {
            errorCallBack("Notification not enabled, please allow notifications from Settings.")
            return
        }
        payloadDict.updateValue(devToken as AnyObject, forKey: "deviceToken")
        
        print("Login with User Info \(payloadDict)")
        
        let networkManager = NetworkManager()
        networkManager.post(AppURLS.baseURL, data: payloadDict as AnyObject) { responseData in
            do {
                let jsonDecoder = JSONDecoder()
                let decodedResponse = try jsonDecoder.decode(UserLoginResponse.self,
                                                             from: responseData)
                
                print(decodedResponse)
                success(decodedResponse)
            } catch let error {
                print(error)
                errorCallBack("Failed to parse the login response")
            }
            
        } error: { errorMsg, isNetworkError in
            errorCallBack(errorMsg)
        }
        
    }
    
    func registerNewUser(data : UserRegistrationPayload, successCallBack: @escaping (UserLoginResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        let networkManager = NetworkManager()
        networkManager.post(AppURLS.baseURL, data: data.getSerializableDict() as AnyObject) { responseData in
            do {
                let jsonDecoder = JSONDecoder()
                let decodedResponse = try jsonDecoder.decode(UserLoginResponse.self,
                                                             from: responseData)
                
                print(decodedResponse)
                successCallBack(decodedResponse)
            } catch let error {
                print(error)
                errorCallBack("Failed to parse the response")
            }
            
        } error: { errorMsg, isNetworkError in
            errorCallBack(errorMsg)
        }
    }
    
    func forgotPassword(email:String, successCallBack: @escaping (ForgotPasswordResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        let resetPassword = ForgotPasswordRequest(emailId: email)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(resetPassword)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(ForgotPasswordResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    successCallBack(decodedResponse)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
    
//    func editProfile(updatedProfile:EditProfilePayload, successCallBack: @escaping (UserLoginResponse) -> (), errorCallBack: @escaping (String) -> ()) {
//        do {
//            let encoder = JSONEncoder()
//            let data = try encoder.encode(updatedProfile)
//            let networkManager = NetworkManager()
//            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
//                do {
//                    let jsonDecoder = JSONDecoder()
//                    let decodedResponse = try jsonDecoder.decode(UserLoginResponse.self,
//                                                                 from: responseData)
//                    print(decodedResponse)
//                    successCallBack(decodedResponse)
//                } catch let error {
//                    print(error)
//                    errorCallBack("Failed to parse the response")
//                }
//                
//            } error: { errorMsg, isNetworkError in
//                errorCallBack(errorMsg)
//            }
//        } catch {
//            errorCallBack("Failed to encode data")
//        }
//    }
    
    func changePassword(payload: ChangePasswordPayload, successCallBack: @escaping (UserLoginResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(payload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(UserLoginResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    successCallBack(decodedResponse)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
    
    func getCardData(successCallBack: @escaping (CardDataResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        do {
            let payload = GetCardDataPayload(userId: currentUser.id)
            let encoder = JSONEncoder()
            let data = try encoder.encode(payload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(CardDataResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    successCallBack(decodedResponse)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
    
    func selectUserCardData(cardNum: String, successCallBack: @escaping (CardDataResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        do {
            let payload = SelectUserCardPayload(userId: currentUser.id, cardnum: cardNum)
            let encoder = JSONEncoder()
            let data = try encoder.encode(payload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(CardDataResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    successCallBack(decodedResponse)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
    
//    func updatePaymentMethod(cardData:UserCard, successCallBack: @escaping (CardDataResponse) -> (), errorCallBack: @escaping (String) -> ()) {
//        guard let currentUser = LoginService.instance.getCurrentUser() else {
//            errorCallBack("Could not load user info")
//            return
//        }
//        let updatedCard = UpdateCardDataPayload(userId: currentUser.id, cardname: cardData.cardname, cardnum: cardData.cardnum, cardcvv: cardData.cardcvv, cardexpmonth: cardData.cardexpmonth, cardexpyear: cardData.cardexpyear)
//        do {
//            let encoder = JSONEncoder()
//            let data = try encoder.encode(updatedCard)
//            let networkManager = NetworkManager()
//            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
//                do {
//                    let jsonDecoder = JSONDecoder()
//                    let decodedResponse = try jsonDecoder.decode(CardDataResponse.self,
//                                                                 from: responseData)
//                    print(decodedResponse)
//                    successCallBack(decodedResponse)
//                } catch let error {
//                    print(error)
//                    errorCallBack("Failed to parse the response")
//                }
//
//            } error: { errorMsg, isNetworkError in
//                errorCallBack(errorMsg)
//            }
//        } catch {
//            errorCallBack("Failed to encode data")
//        }
//    }
    
    func updatePaymentMethod(cardData:UserCard, oldCardNum: String, successCallBack: @escaping (UpdateCardDataResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        let updatedCard = UpdateCardDataPayload(userId: currentUser.id, cardname: cardData.cardname, cardnum: cardData.cardnum, oldcardnum: oldCardNum, cardcvv: cardData.cardcvv, cardexpmonth: cardData.cardexpmonth, cardexpyear: cardData.cardexpyear)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(updatedCard)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(UpdateCardDataResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    successCallBack(decodedResponse)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
    
    func addPaymentMethod(cardData:UserCard, successCallBack: @escaping (CardDataResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        let addCard = AddCardDataPayload(action: Actions.addMoreCards.rawValue, userId: currentUser.id, cardname: cardData.cardname, cardnum: cardData.cardnum, cardcvv: cardData.cardcvv, cardexpmonth: cardData.cardexpmonth, cardexpyear: cardData.cardexpyear)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(addCard)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(CardDataResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    successCallBack(decodedResponse)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
    
    func deletePaymentMethod(cardnum:String, successCallBack: @escaping (CardDataResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        let cardToDelete = DeleteCardPayload(userId: currentUser.id, cardnum: cardnum)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(cardToDelete)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(CardDataResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    successCallBack(decodedResponse)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
    
    
}
