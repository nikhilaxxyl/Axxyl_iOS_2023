//
//  BookingService.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 02/10/22.
//

import Foundation
import CoreLocation

class BookingService : NSObject {
    
    static let instance = BookingService()
 
    var currentVehicleType : CarCategory?
    var currentPaymentMethod : UserCard?
    var routeLocations: [MapLocation]?
    var rideIdInProgress : String?
    var tipAmount : String = ""
    
    private override init() {
        super.init()
    }
    
    func getOriginAddress() -> String {
        guard let routes = self.routeLocations, routes.count > 1 else {
            return "Origin address not set"
        }
        
        return routes.first!.address ?? ""
    }
    
    func getDestinationAddress() -> String {
        guard let routes = self.routeLocations, routes.count > 1 else {
            return "Destination address not set"
        }
        return routes.last!.address ?? ""
    }
    
    func getDestinationCoordinates() -> CLLocationCoordinate2D {
        guard let routes = self.routeLocations, routes.count > 1 else {
            print("[WARN] Destination lat longs are not found... this should not happend")
            return CLLocationCoordinate2DMake(0.0, 0.0)
        }
        return CLLocationCoordinate2DMake(routes.last!.latitude ?? 0.0, routes.last!.longitude ?? 0.0)
    }
    
    func getBookingHistory(successCallBack: @escaping (BookingHistoryResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let bookingHistoryPayload = BookingHistoryPayload(action: Actions.userHistory.rawValue, userId: currentUser.id, usertype: currentUser.usertype)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(bookingHistoryPayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(BookingHistoryResponse.self,
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
    
    func getCarType(successCallBack: @escaping (CarTypeResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let carTypePayload = CarTypePayload(handicapped: currentUser.handicapped)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(carTypePayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(CarTypeResponse.self,
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
    
    func getEstimatedPriceDetails(successCallBack: @escaping (RideEstimateResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let routes = self.routeLocations, routes.count > 1 else {
            errorCallBack("Pick-up and drop-off location not set")
            return
        }
        
        let pickup = "\(routes.first!.latitude ?? 0.0), \(routes.first!.longitude ?? 0.0)"
        let dropoff = "\(routes.last!.latitude ?? 0.0), \(routes.last!.longitude ?? 0.0)"
        
        let estimatePayload = RideEstimatedPricePayload(carId: "", pickuplatLong: pickup, droplatLong_1: "", droplatLong_2: "", droplatLong: dropoff, origin: getOriginAddress(), destination: getDestinationAddress())
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(estimatePayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(RideEstimateResponse.self,
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
    
    

    func requestAPickup(successCallBack: @escaping (PickupResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        guard let carType = self.currentVehicleType else {
            errorCallBack("Car Type not selected")
            return
        }
        
        guard let routes = self.routeLocations, routes.count > 1 else {
            errorCallBack("Pick-up and drop-off location not set")
            return
        }
        
        let pickup = "\(routes.first!.latitude ?? 0.0),\(routes.first!.longitude ?? 0.0)"
        let dropoff = "\(routes.last!.latitude ?? 0.0),\(routes.last!.longitude ?? 0.0)"
        
        let payload = PickupRequestPayload(userId: currentUser.id, lat: routes.first!.latitude ?? 0.0, long: routes.first!.longitude ?? 0.0, carTypeId: carType.ID, pickuplatLong: pickup, droplatLong: dropoff, pickupLocation: getOriginAddress(), sourcestate: "", dropLocation: getDestinationAddress())
        
        print(payload)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(payload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(PickupResponse.self,
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
    
    func cancelRideInProgress(successCallBack: @escaping (GeneralResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        guard let reqId = self.rideIdInProgress else {
            errorCallBack("ReqId Not found")
            return
        }
        
        let payload = CancelRideRequestPayload(userId: currentUser.id, reqId: reqId)
        
        print(payload)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(payload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(GeneralResponse.self,
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
    
    func getRideStatus(user_type:String, rideId:String, successCallBack: @escaping (RideStatusResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let getRideStatus = RideStatusPayload(userId: currentUser.id, user_type: user_type, rideId: rideId)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(getRideStatus)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(RideStatusResponse.self,
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
    
    func getdriversNearby(location: CLLocation, successCallBack: @escaping (DriversNearByResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let getRideStatus = DriversNearByPayload(userId: currentUser.id, lat: location.coordinate.latitude, long: location.coordinate.longitude)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(getRideStatus)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(DriversNearByResponse.self,
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
    
    func getDriversLocation(driverId:String, successCallBack: @escaping (DriverLocationResponse) -> (), errorCallBack: @escaping (String) -> ()) {
            
            let driverLoc = DriversCurrentLocationPayload(userId: driverId)
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(driverLoc)
                let networkManager = NetworkManager()
                networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                    do {
                        let jsonDecoder = JSONDecoder()
                        let decodedResponse = try jsonDecoder.decode(DriverLocationResponse.self,
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

