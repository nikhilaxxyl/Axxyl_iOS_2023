//
//  HomeViewController.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 29/09/22.
//

import UIKit
import CoreLocation
import MapKit
import Kingfisher
import MessageUI

enum HomeState : Int {
    case search
    case etaDriver
    case driverWaiting
    case tripStarted
    
    
    case empty
    case driverHome
    case driverNewRideRequest
    case driverArriving
    case passengerNotified
    case driverTripStarted
}

class HomeViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profileBtn: UIButton!
    
    @IBOutlet weak var driverOnWayView: DriverOnWayView!
    @IBOutlet weak var tripStartForUserView: TripStartedView!
    @IBOutlet weak var welcomeDriverView: WelcomeDriverView!
    @IBOutlet weak var welcomePassengerView: WelcomePassengerView!
    @IBOutlet weak var rideRequestReceivedView: NewRequestReceivedView!
    @IBOutlet weak var driverArrivingView: DriverArrivingView!
    @IBOutlet weak var passengerNotifiedView: PassengerNotifiedView!
    @IBOutlet weak var driverTripStartedView: DriverTripStarted!
    
    var myCurrentLocation: MapLocation?
    var destinationLocation = MapLocation(id: 1)
    lazy var geocoder = CLGeocoder()
    
    var notificationData : CommonNotificationData?
    
    let currentUserType = LoginService.instance.currentUserType
    
    var currentLocation : CLLocation?
    
    var driverPoolingTimer: Timer?
    
    var homeState : HomeState = .empty {
        didSet {
            updateScreenState()
        }
    }
    
    lazy var locationManager: CLLocationManager = {
        var manager = CLLocationManager()
        manager.distanceFilter = 10
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        profileBtn.imageView?.layer.masksToBounds = true
        profileBtn.imageView?.layer.cornerRadius = profileBtn.frame.width/2
        profileBtn.imageView?.layer.borderWidth = 2
        profileBtn.imageView?.layer.borderColor = UIColor(red: 77.0/255.0, green: 35.0/255.0, blue: 229.0/255.0, alpha: 0.5).cgColor
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        
        welcomePassengerView.delegate = self
        driverOnWayView.delegate = self
        welcomeDriverView.delegate = self
        rideRequestReceivedView.delegate = self
        driverArrivingView.delegate = self
        passengerNotifiedView.delegate = self
        driverTripStartedView.delegate = self
        
        if self.currentUserType == .passenger {
            self.addPassengerNotificationListener()
        }else if self.currentUserType == .driver {
            self.addDriverNotificationListener()
        }
        
        self.homeState = self.currentUserType == .passenger ? HomeState.search : HomeState.driverHome
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUIWithValues()
        if self.currentUserType == .driver {
            self.getDriverStatus()
        }
    }
    
    func addPassengerNotificationListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPassengerNotifications), name: NSNotification.Name(PushNotificationTypes.arrived.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPassengerNotifications), name: NSNotification.Name(PushNotificationTypes.tripStarted.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPassengerNotifications), name: NSNotification.Name(PushNotificationTypes.ariveEnd.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPassengerNotifications), name: NSNotification.Name(PushNotificationTypes.cancle.rawValue), object: nil)
    }
    
    func addDriverNotificationListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDriverNotifications), name: NSNotification.Name(PushNotificationTypes.sentReq.rawValue), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func receivedPassengerNotifications(_ notification : Notification) {
        if let data = notification.object as? NotificationData {
            if data.msgType == PushNotificationTypes.arrived.rawValue {
                self.notificationData = data
                self.homeState = .driverWaiting
                self.stopDriverLocationPooling()
            } else if data.msgType == PushNotificationTypes.tripStarted.rawValue {
                self.notificationData = data
                self.homeState = .tripStarted
            }
        } else if let data = notification.object as? CancelEndNotificationData {
            if data.msgType == PushNotificationTypes.cancle.rawValue {
                self.notificationData = data
                self.rideCanceledStateUpdate()
                self.homeState = .search
                self.stopDriverLocationPooling()
                AlertManager.showInfoAlert(message: "Ride has been cancelled")
            }
        } else if let data = notification.object as? ArrivedEndNotificationData {
            if data.msgType == PushNotificationTypes.ariveEnd.rawValue {
                self.notificationData = data
                self.homeState = .empty
                self.removePassengerRoutes()
                self.tripEndedForPassenger()
            }
        }
    }
    
    @objc func receivedDriverNotifications(_ notification : Notification) {
        if let data = notification.object as? CommonNotificationData {
            if data.msgType == PushNotificationTypes.sentReq.rawValue {
                self.notificationData = data
                self.homeState = .driverNewRideRequest
            }
        }
    }
    
    func updateScreenStateForDriver() {
        if homeState == .driverHome {
            self.welcomeDriverView.bottomConstriant.constant = 20
            self.welcomeDriverView.onlineOfflineSwitch.setOn(DriverService.instance.isOnline, animated: true)
            self.rideRequestReceivedView.bottomConstriant.constant = -420
            self.passengerNotifiedView.bottomConstriant.constant = -520
            self.driverTripStartedView.bottomConstriant.constant = -320
            UIView.animate(withDuration: 0.5, delay: 1) {
                self.view.layoutIfNeeded()
            }
        }else if homeState == .driverNewRideRequest {
            self.welcomeDriverView.bottomConstriant.constant = -420
            self.rideRequestReceivedView.bottomConstriant.constant = 20
            UIView.animate(withDuration: 0.5, delay: 1) {
                self.view.layoutIfNeeded()
            }
            if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
                updateDriverRideRequestReceived(data)
            }
        }else if homeState == .driverArriving {
            self.rideRequestReceivedView.bottomConstriant.constant = -420
            self.driverArrivingView.bottomConstriant.constant = 20
            UIView.animate(withDuration: 0.5, delay: 1) {
                self.view.layoutIfNeeded()
            }
            if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
                updateDriverArriving(data)
            }
        }else if homeState == .passengerNotified {
            self.driverArrivingView.bottomConstriant.constant = -420
            self.passengerNotifiedView.bottomConstriant.constant = 20
            UIView.animate(withDuration: 0.5, delay: 1) {
                self.view.layoutIfNeeded()
            }
            if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
                updatePassengerNotified(data)
            }
        }else if homeState == .driverTripStarted {
            self.driverTripStartedView.bottomConstriant.constant = 20
            self.passengerNotifiedView.bottomConstriant.constant = -520
            UIView.animate(withDuration: 0.5, delay: 1) {
                self.view.layoutIfNeeded()
            }
            if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
                updateDriverTripStarted(data)
            }
        }
    }
    
    func updateScreenState() {
        if currentUserType == .passenger {
            self.updateScreenStateForPassenger()
            // Stop driver pooling if driver is not on the way to passenger location
//            if homeState != .etaDriver {
//                self.stopDriverLocationPooling()
//            }
        } else if currentUserType == .driver {
            self.updateScreenStateForDriver()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateScreenState()
        if let user = LoginService.instance.getCurrentUser() {
            welcomePassengerView.headerTitleLbl.text = "Good morning, " + user.name
        }
    }
    
    func updateUIWithValues() {
        if let currentUser = LoginService.instance.getCurrentUser() {
            if let imgURL = URL(string: currentUser.profile_image) {
                self.profileBtn.kf.setImage(with: imgURL, for: .normal)
            }
        }
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        let sb = UIStoryboard(name: "Profile", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    @IBAction func humburgerBtnPressed(_ sender: Any) {
        let sb = UIStoryboard(name: "Menu", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    func presentSearchViewController() {
        let sb = UIStoryboard(name: "Home", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vcToOpen.delegate = self
        vcToOpen.mapView = mapView
        if myCurrentLocation != nil {
            vcToOpen.stopLocationItems.removeAll()
            myCurrentLocation?.id = 0
            vcToOpen.stopLocationItems.append(myCurrentLocation!)
            vcToOpen.stopLocationItems.append(destinationLocation)
        }
        vcToOpen.modalPresentationStyle = .fullScreen
        present(vcToOpen, animated: true)
    }
    
    func presentTipsViewController() {
        let sb = UIStoryboard(name: "Home", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "tipsviewcontroller") as! TipsViewController
        vcToOpen.modalPresentationStyle = .pageSheet
        vcToOpen.delegate = self
        if #available(iOS 15.0, *) {
            if let sheet = vcToOpen.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                // sheet.largestUndimmedDetentIdentifier = .medium
            }
        } else {
            // Fallback on earlier versions
        }
        present(vcToOpen,animated: true)
    }
    
    func navigateToPassengerTripPaymentViewController() {
        let sb = UIStoryboard(name: "Home", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "PassengerTripPaymentViewController") as! PassengerTripPaymentViewController
        vcToOpen.delegate = self
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    func getDriverStatus() {
        DriverService.instance.getDriverStatus {[weak self] response in
            if response.isSuccess() {
                DriverService.instance.isOnline = response.bookingOn == "1" ? true : false
            }
            DispatchQueue.main.async {
                self?.updateUIWithDriverStatus()
            }
        } errorCallBack: { errMsg in
            print("failed to load driver status... check why it is happening - \(errMsg)")
        }
    }
    
    func sendSmsToNumber(_ number : String) {
        guard MFMessageComposeViewController.canSendText() else {
            print("Unable to send messages.")
            return
        }
        
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = self
        controller.recipients = ["+\(number)"]
        controller.body = ""
        present(controller, animated: true)
    }
    
    func makeACallToNumber(_ number : String) {
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.updateDriverLocation(newLocation: locations.last)
        
        self.updatePassengerLocation(newLocation: locations.last)
        
        print("LOCATION UPDATE --> \(String(describing: locations.last?.coordinate))")
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Unable to Reverse Geocode Location (\(error))")
                } else {
                    if let placemarks = placemarks, let placemark = placemarks.first {
                        self.myCurrentLocation = LocationManager.managerObj.parseLocationPlaceMark(placemark: placemark, isCurrentLocation: true)
                    } else {
                        print("No Matching Addresses Found")
                    }
                }
            }
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009))
            mapView.setRegion(region, animated: true)
        }
        self.showNearByCarsOnMap()
    }
}

// MARK:- MapViewDelegate
extension HomeViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let pinImage: UIImage?
        let title = annotation.subtitle!! + "_Route.png"
        pinImage = UIImage(named: title)
        annotationView!.image = pinImage
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.lineWidth = 2
        renderer.strokeColor = UIColor.black
        return renderer
    }
}


extension HomeViewController : WelcomePassengerViewDelegate {
    func viewPastTrips() {
        let sb = UIStoryboard(name: "Menu", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "BookingHistoryViewController")
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    func searchTxtFieldDidBeginEditing() {
        presentSearchViewController()
    }
    
}

extension HomeViewController: RouteLocationDelegate {
    func pushSelectVehicleWithRouteArray(routeLocations: [MapLocation]) {
        let routeArray = routeLocations.filter({ $0.latitude != nil })
        if routeArray.count > 1 {
            let sb = UIStoryboard(name: "Home", bundle: nil)
            let vcToOpen = sb.instantiateViewController(withIdentifier: "SelectVehicleTypeViewController") as! SelectVehicleTypeViewController
            vcToOpen.routeLocations = routeArray
            BookingService.instance.routeLocations = routeArray
            self.navigationController?.pushViewController(vcToOpen, animated: true)
        }
    }
}


extension HomeViewController : DriverOnWayViewDelegate {
    func navigateToCurrentLocation() {
        
    }
    
    func openProfile() {
        
    }
    
    func openMessageComposer() {
        
        guard let data = self.notificationData as? NotificationData else {
            return
        }
        
        self.sendSmsToNumber(data.vendorPhone)
    }
    
    func callDriver() {
        if let data = self.notificationData as? NotificationData {
            self.makeACallToNumber(data.vendorPhone)
        }
    }
    
    func changeDestination() {
        AlertManager.showErrorAlert(message: "This feature will be implemented in next phase.")
    }
    
    func cancelRide() {
        // TODO : show confirmation pop up
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        BookingService.instance.cancelRideInProgress { res in
            LoadingSpinner.manager.hideLoadingAnimation()
            if res.isSuccess() {
                DispatchQueue.main.async {
                    self.homeState = .search
                }
            }else{
                AlertManager.showErrorAlert(message: res.msg ?? "Failed to cancel ride request")
            }
            
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
        
    }
    
}

extension HomeViewController : MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
}

extension HomeViewController : TipsSelectionDelegate {
    func skipTip() {
        BookingService.instance.tipAmount = "0"
        self.navigateToPassengerTripPaymentViewController()
    }
    
    func addTipWithPercentage(percentage: Int) {
        let totalFare = BookingService.instance.currentVehicleType?.total ?? 0.0
        let tipAmount : Double = (totalFare * Double(percentage)) / 100.0
        BookingService.instance.tipAmount = "\(tipAmount)"
        self.navigateToPassengerTripPaymentViewController()
    }
    
    func addTipAsAmount(amount: String) {
        BookingService.instance.tipAmount = amount
        self.navigateToPassengerTripPaymentViewController()
    }
}

extension HomeViewController : DriverStatusProtocol {
    func driverStatusChanged(online: Bool) {
        self.updateDriverStatus(online: online)
    }
    
    func updateDriverLocation(newLocation: CLLocation?){
        
        guard let loc = newLocation else {
            return
        }
        
        guard let clLoc = self.currentLocation else {
            self.currentLocation = loc
            self.sendDriverLocationToBackend(cord: loc.coordinate)
            return
        }
        
        
        let distance = loc.distance(from: clLoc)
        print("changed distance : \(distance)")
        if distance > 10 {
            print("Driver moved more than \(distance) mtr so updating the location on backend")
            self.sendDriverLocationToBackend(cord: loc.coordinate)
            self.currentLocation = newLocation
        }
    }
    
    func sendDriverLocationToBackend(cord: CLLocationCoordinate2D) {
        if LoginService.instance.currentUserType == .driver && DriverService.instance.isOnline {
            DriverService.instance.updateDriverLocation(cordinates: cord) { response in
                if response.isSuccess() {
                    // TODO : nothing to do?
                }
            } errorCallBack: { errMsg in
                // Nothing to show?
                print("Failed to update driver's location, check why it is happening?")
            }
        }
    }
    
    func updateDriverStatus(online: Bool) {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        
        DriverService.instance.updateDriverStatus(isOnline: online) { response in
            LoadingSpinner.manager.hideLoadingAnimation()
            if response.isSuccess() {
                DriverService.instance.isOnline = online
                if online, let curLoc = self.currentLocation {
                    // Send the current location immediately to update the driver location
                    self.sendDriverLocationToBackend(cord: curLoc.coordinate)
                }
            }else{
                self.welcomeDriverView.resetSwitchStatus(isOn: !online)
                AlertManager.showErrorAlert(message: response.msg ?? "Could not update your status")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
        
    }
}

extension HomeViewController : DriverRideAcceptRejectProtocol {
    func declinedRide() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.declineRide(rideId: self.rideRequestReceivedView.currentRideId) { response in
            LoadingSpinner.manager.hideLoadingAnimation()
            if response.isSuccess() {
                self.homeState = .driverHome
                DriverService.instance.driverRideIdInProgress = nil
                APNNotificationService.instance.clearCachedNotifications()
            }else{
                AlertManager.showErrorAlert(message: response.msg ?? "Failed to cancel the ride")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
        
    }
    
    func acceptedRide() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.acceptRideRequest(reqId: self.rideRequestReceivedView.currentRideId, userId: self.rideRequestReceivedView.userId, coordinates: self.currentLocation!.coordinate) { response in
            LoadingSpinner.manager.hideLoadingAnimation()
            if response.isSuccess() {
                self.homeState = .driverArriving
            }else{
                AlertManager.showErrorAlert(message: response.msg ?? "Failed to accept the ride")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
}

extension HomeViewController: DriverArrivingProtocol {
    func ihavearrived() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.driverArrivedAtUserLocationSendNotificationRequest(userId: self.driverArrivingView.userId, coordinates: self.currentLocation!.coordinate) { response in
            LoadingSpinner.manager.hideLoadingAnimation()
            if response.isSuccess() {
                self.homeState = .passengerNotified
            }else{
                AlertManager.showErrorAlert(message: response.msg ?? "Failed to mark arrival")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
        
    }
    
    func callPassenger() {
        if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
            self.makeACallToNumber(data.UserPhone)
        }
    }
    
    func smsPassenger() {
        guard let data = self.notificationData as? DriverReceivedRideRequestNotificationData else {
            return
        }
        self.sendSmsToNumber(data.UserPhone)
    }
}

extension HomeViewController : PassengerNotifiedProtocol {
    func openMapInDrivingMode() {
        if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
            
            let components = data.pickuplatLong.components(separatedBy: ",")
            
            if components.count == 0 || components.count > 2 {
                print("Pick up lat long are either empty or more comma separated values are more than 2")
            }
            
            let source = MKMapItem(coordinate: CLLocationCoordinate2D(latitude: Double(components[0].replacingOccurrences(of: " ", with: "")) ?? 0.0, longitude: Double(components[1].replacingOccurrences(of: " ", with: "")) ?? 0.0), name: data.pickupLocation)
            
            let components_drop = data.droplatLong.components(separatedBy: ",")
            
            if components_drop.count == 0 || components_drop.count > 2 {
                print("Drop lat long are either empty or more comma separated values are more than 2")
            }
            
            let destination = MKMapItem(coordinate: CLLocationCoordinate2D(latitude: Double(components_drop[0].replacingOccurrences(of: " ", with: "")) ?? 0.0, longitude: Double(components_drop[1].replacingOccurrences(of: " ", with: "")) ?? 0.0), name: data.dropLocation)
            
            MKMapItem.openMaps(
                with: [source, destination],
                launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            )
        }
    }
    
    func startRide() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.startServiceRequest(vendorId: self.passengerNotifiedView.userId, pickup: self.passengerNotifiedView.pickupLatLong) {[weak self] response in
            LoadingSpinner.manager.hideLoadingAnimation()
            if response.isSuccess() {
                self?.homeState = .driverTripStarted
                DispatchQueue.main.async {
                    self?.openMapInDrivingMode()
                }
            }else{
                AlertManager.showErrorAlert(message: response.msg ?? "Failed to start the ride")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func driverCancelsRide() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.cancelRideInProgress { response in
            LoadingSpinner.manager.hideLoadingAnimation()
            if response.isSuccess() {
                self.homeState = .driverHome
                DriverService.instance.driverRideIdInProgress = nil
                APNNotificationService.instance.clearCachedNotifications()
            }else{
                AlertManager.showErrorAlert(message: response.msg ?? "Failed to cancel the ride")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func pnsmsPassenger() {
        guard let data = self.notificationData as? DriverReceivedRideRequestNotificationData else {
            return
        }
        self.sendSmsToNumber(data.UserPhone)
    }
    
    func pncallPassenger() {
        if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
            self.makeACallToNumber(data.UserPhone)
        }
    }
}

extension HomeViewController : DriverTripStartProtocol {
    func driverEndsRide() {
        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { action in
            self.endRideForDriver()
        }
        
        AlertManager.showCustomAlertWith("Are you sure you want to end this ride?", message: "", actions: [noAction, yesAction])
    }
    
    func navigateToTripDetailsScreen(data: DriverTripEndResponse) {
        let sb = UIStoryboard(name: "Home", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "driverridedetailsViewController") as! DriverRideDetailsViewController
        vcToOpen.tripData = data
        vcToOpen.delegate = self
        if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
            vcToOpen.emailId = data.userEmail
        }
        vcToOpen.modalPresentationStyle = .fullScreen
        self.present(vcToOpen,animated: true)
    }
    
    func endRideForDriver(){
        if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            DriverService.instance.driverEndRide(vendorId: self.driverTripStartedView.userId, droplatLong:data.droplatLong , dropLocation: data.dropLocation, pickupLocation: data.pickupLocation) {[weak self] response in
                LoadingSpinner.manager.hideLoadingAnimation()
                if response.isSuccess() {
                    DispatchQueue.main.async {
                        self?.navigateToTripDetailsScreen(data: response)
                    }
                    //                    self.homeState = .driverHome
                }else{
                    AlertManager.showErrorAlert(message: response.msg ?? "Failed to end the ride")
                }
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        }
        
    }
}

// Passenger UI Updates
extension HomeViewController {
    
    func updateDriverLocationOnMap(response: DriverLocationResponse) {
        
        if self.homeState != .etaDriver {
            return
        }
        
        guard let loc =  response.response else {
            return
        }
        
        print("updating driver location on map \(String(describing: loc.lat)) :: \(String(describing: loc.long))")
        
        let driverLoc = MapLocation(id: 1234, latitude: Double(loc.lat) ?? 0.0, longitude: Double(loc.long) ?? 0.0)
//        let driverLoc = MapLocation(id: 1234, latitude: 18.5678638, longitude: 73.7726889)
        
        guard let myloc = self.myCurrentLocation else {
            fatalError("my current location maplocation object is null")
        }
        
        LocationManager.managerObj.addAnnotationOnMap(searchMode:false, mapview: self.mapView, locationArray: [driverLoc, myloc])
        LocationManager.managerObj.showRouteOnMap(mapView: self.mapView, locationArray: [driverLoc, myloc])
    }
    
    @objc func findWhereDriverIs(driverId:String) {
        print("Pooling driver's location")
        BookingService.instance.getDriversLocation(driverId: driverId) {[weak self] driverResponse in
            DispatchQueue.main.async {
                self?.updateDriverLocationOnMap(response: driverResponse)
            }
        } errorCallBack: { errMsg in
            print("Driver location not pooling, check why it is happening")
        }
    }
    
    func startPoolingDriverLocation(driverId: String) {
        self.findWhereDriverIs(driverId: driverId)
        self.driverPoolingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {[weak self] timer in
            self?.findWhereDriverIs(driverId: driverId)
        })
    }
    
    func stopDriverLocationPooling() {
        if self.driverPoolingTimer != nil {
            self.driverPoolingTimer?.invalidate()
            self.driverPoolingTimer = nil
        }
        LocationManager.managerObj.clearOverlay(mapView: self.mapView)
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    func updateDriverOnWayView(_ data : NotificationData) {
        if homeState == .etaDriver {
            if let rideDetails = BookingService.instance.currentVehicleType {
                driverOnWayView.amountLbl.text = rideDetails.displayTotalPrice()
                driverOnWayView.destinationLbl.text = "To " + BookingService.instance.getDestinationAddress()
                driverOnWayView.originAddressLbl.text = "From " + BookingService.instance.getOriginAddress()
                driverOnWayView.carNoLbl.text = data.car_number + " (\(data.carColor))"
                driverOnWayView.carModelLbl.text = data.carModel
                driverOnWayView.driverNameLbl.text = "Driver : \(data.vendorName)"
                if let imgURL = URL(string: data.vendorImage) {
                    driverOnWayView.driverProfilePhotoBtn.kf.setImage(with: imgURL, for: .normal)
                }
            }
            
            self.startPoolingDriverLocation(driverId: data.vendorId)
        }
    }
    
    func removePassengerRoutes() {
        LocationManager.managerObj.clearOverlay(mapView: self.mapView)
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    func updatePassengerLocation(newLocation: CLLocation?){
        
        if LoginService.instance.currentUserType == .passenger && homeState == .tripStarted {
            guard let loc = newLocation else {
                return
            }
            
            guard let clLoc = self.currentLocation else {
                self.currentLocation = loc
                return
            }
            
            let distance = loc.distance(from: clLoc)
            
            print("changed distance : \(distance)")
            
            if distance > 50 {
                print("Passenger moved more than \(distance) mtr so updating the route on the map")
                self.currentLocation = newLocation
                self.routeFromPassengerToDropLocation()
            }
        }
    }
    
    func routeFromPassengerToDropLocation() {
        
        let coord = BookingService.instance.getDestinationCoordinates()
        let dropLocation = MapLocation(id: 1235, name: "Stop", latitude: coord.latitude, longitude: coord.longitude)
//        let driverLoc = MapLocation(id: 1234, latitude: 18.5678638, longitude: 73.7726889)
        
        guard let myloc = self.currentLocation else {
            fatalError("my current location maplocation object is null")
        }
        
        let myMap = MapLocation(id: 1423, name: "NearByDriver", latitude: myloc.coordinate.latitude, longitude: myloc.coordinate.longitude)
        
        LocationManager.managerObj.addAnnotationOnMap(searchMode:false, mapview: self.mapView, locationArray: [myMap, dropLocation])
        LocationManager.managerObj.showRouteOnMap(mapView: self.mapView, locationArray: [myMap, dropLocation])
    }
    
    func updateTripStartedView(_ data : NotificationData) {
        if homeState == .tripStarted {
            if let rideDetails = BookingService.instance.currentVehicleType {
                tripStartForUserView.amountLbl.text = rideDetails.displayTotalPrice()
                tripStartForUserView.destinationLbl.text = "To " + BookingService.instance.getDestinationAddress()
                tripStartForUserView.originLbl.text = "From " + BookingService.instance.getOriginAddress()
                tripStartForUserView.cardNumberLbl.text = "Visa : \(BookingService.instance.currentPaymentMethod!.cardnum.getMaskedCardNum(longLength: false))"
            }
        }
    }
    
    func updateScreenStateForPassenger() {
        if homeState == .search {
            self.welcomePassengerView.bottomConstriant.constant = 20
            self.driverOnWayView.bottomConstriant.constant = -550
            UIView.animate(withDuration: 0.5, delay: 1) {
                self.view.layoutIfNeeded()
            }
        }else if homeState == .driverWaiting {
            self.welcomePassengerView.bottomConstriant.constant = -320
            self.driverOnWayView.driverEtaStackView.isHidden = true
            self.driverOnWayView.driverWaitingStackView.isHidden = false
            self.driverOnWayView.bottomConstriant.constant = 20
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.view.layoutIfNeeded()
            }
            self.driverOnWayView.startDriverWaitTime()
        }else if homeState == .etaDriver {
            
            self.welcomePassengerView.bottomConstriant.constant = -320
            self.driverOnWayView.driverWaitingStackView.isHidden = true
            self.driverOnWayView.driverEtaStackView.isHidden = false
            self.driverOnWayView.bottomConstriant.constant = 20
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.view.layoutIfNeeded()
            }
            if let data = self.notificationData as? NotificationData {
                updateDriverOnWayView(data)
            }
        }else if homeState == .tripStarted {
            self.tripStartForUserView.bottomConstriant.constant = 20
            self.driverOnWayView.stopDriverWaitTime()
            self.driverOnWayView.bottomConstriant.constant = -550
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.view.layoutIfNeeded()
            }
            if let data = self.notificationData as? NotificationData {
                updateTripStartedView(data)
                routeFromPassengerToDropLocation()
            }
        } else { // Empty State
            self.tripStartForUserView.bottomConstriant.constant = -320
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func rideCanceledStateUpdate() {
        if self.homeState == .driverWaiting {
            self.driverOnWayView.stopDriverWaitTime()
            self.driverOnWayView.bottomConstriant.constant = -550
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func tripEndedForPassenger() {
        self.presentTipsViewController()
    }
    
    func showNearByCarsOnMap() {
        if self.homeState == .search && LoginService.instance.currentUserType ==  UserType.passenger {
            BookingService.instance.getdriversNearby(location: self.currentLocation!) {  uploadResponse in
                if uploadResponse.isSuccess() {
                    DispatchQueue.main.async {
                        var driverLocArray : [CLLocationCoordinate2D] = []
                        for nearDriver in uploadResponse.vendor {
                            if let latCordindates = Double(nearDriver.lat) , let longCordinates = Double(nearDriver.long) {
                                let latitude = CLLocationDegrees(latCordindates)
                                let longitude = CLLocationDegrees(longCordinates)
                                let obj = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                driverLocArray.append(obj)
                            }
                        }
                        LocationManager.managerObj.addCarAnnotationOnMap(mapview: self.mapView, driversLocationArray: driverLocArray)
                    }
                }else{
                    print("Show Drivers Near By Error: \(String(describing: uploadResponse.msg))")
                }
                
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        }
    }
}


// Driver UI Updates
extension HomeViewController {
    func updateUIWithDriverStatus() {
        if self.homeState == .driverHome {
            self.welcomeDriverView.changeOnlineStatus(isOn: DriverService.instance.isOnline)
        }
    }
    
    func updateDriverRideRequestReceived(_ data : DriverReceivedRideRequestNotificationData) {
        if homeState == .driverNewRideRequest {
            self.rideRequestReceivedView.attachData(data: data)
        }
    }
    
    func updateDriverArriving(_ data : DriverReceivedRideRequestNotificationData) {
        if homeState == .driverArriving {
            self.driverArrivingView.attachData(data: data)
        }
    }
    
    func updatePassengerNotified(_ data : DriverReceivedRideRequestNotificationData) {
        if homeState == .passengerNotified {
            self.passengerNotifiedView.attachData(data: data)
        }
    }
    
    func updateDriverTripStarted(_ data : DriverReceivedRideRequestNotificationData) {
        if homeState == .driverTripStarted {
            self.driverTripStartedView.attachData(data: data)
        }
    }
}

extension HomeViewController : DriverEndRideProtocol {
    func onTripEnd() {
        self.homeState = .driverHome
    }
}

extension HomeViewController : PassengerTripEnd {
    func tripEndedForPassengerAfterPayment() {
        self.homeState = .search
    }
}
