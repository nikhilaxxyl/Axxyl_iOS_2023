//
//  LocationManager.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 12/10/22.
//

import Foundation
import MapKit

class LocationManager: NSObject {
    
    static let managerObj = LocationManager()
//    private var routePolylineArray: [MKRoute] = []
    typealias CompletionHandler = (_ route:MKRoute?) -> Void
    private var isMapRectLoaded = false
    private var currentOverlay : MKOverlay?
    
    private override init() {
        super.init()
    }
    
    func parseLocationObj(mapItem: MKMapItem) -> MapLocation {
        var mapLocation = MapLocation()
        if let name = mapItem.name {
            mapLocation.name = name
        }
        
        if let phoneNumber = mapItem.phoneNumber {
            mapLocation.phoneNumber = phoneNumber
        }
        
        mapLocation.address = getFormattedAddress(placemark: mapItem.placemark)
        
        if let location = mapItem.placemark.coordinate as CLLocationCoordinate2D? {
            mapLocation.latitude = location.latitude
            mapLocation.longitude = location.longitude
        }
        
        return mapLocation
    }
    
    func parseLocationPlaceMark(placemark: CLPlacemark, isCurrentLocation: Bool) -> MapLocation {
        var maploc = MapLocation()
        var name = placemark.name
        let address = getFormattedAddress(placemark: placemark)
        if isCurrentLocation {
            name = "Your Location: \(address)"
        }
        maploc.name = name
        maploc.address = address
        if let loc = placemark.location {
            maploc.latitude = loc.coordinate.latitude
            maploc.longitude = loc.coordinate.longitude
        }
        return maploc
    }
    
    func addAnnotationOnMap(searchMode: Bool = true, mapview: MKMapView, locationArray: [MapLocation]) {
        mapview.removeAnnotations(mapview.annotations)
        for location in locationArray {
            let annotation = MKPointAnnotation()
            annotation.subtitle = ""
            if location.name == locationArray.first?.name {
                annotation.subtitle = "NearByDriver"
                if searchMode {
                    annotation.subtitle = "Start"
                }
            }
           /* TO show alll stops */
//            else {
//                annotation.subtitle = "Stop"
//            }
            if location.name == locationArray.last?.name {
                annotation.subtitle = "Start"
                if searchMode {
                    annotation.subtitle = "Stop"
                }
            }
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!)
            mapview.addAnnotation(annotation)
        }
    }
    
    func addCarAnnotationOnMap(mapview: MKMapView, driversLocationArray: [CLLocationCoordinate2D]) {
        mapview.removeAnnotations(mapview.annotations)
        for location in driversLocationArray {
            let annotation = MKPointAnnotation()
            annotation.subtitle = "NearByDriver"
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude:location.longitude)
            mapview.addAnnotation(annotation)
        }
    }
    
    func clearOverlay(mapView: MKMapView) {
        if let ol = self.currentOverlay {
            mapView.removeOverlay(ol)
        }
    }

    
    func showRouteOnMap(mapView: MKMapView, locationArray: [MapLocation]) {
//        routePolylineArray.removeAll()
        self.clearOverlay(mapView: mapView)
        
        var mapRect = MKMapRect()
        for locationObj in locationArray {
            let index = locationArray.firstIndex(of: locationObj)
            if index != locationArray.count - 1 {
                let nextIndex = index! + 1
                let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (locationObj.latitude)!, longitude: (locationObj.longitude)!))
                let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (locationArray[nextIndex].latitude)!, longitude: (locationArray[nextIndex].longitude)!))
                getRouteBetween(source: sourcePlaceMark, destination: destPlaceMark, completionHandler: {route in
                    if route != nil {
                        //self.routePolylineArray.append(route!)
                        print("Route dist: \(route?.distance) \n rout desc: \(route?.description)")
                        mapView.addOverlay(route!.polyline)
                        mapView.setVisibleMapRect(route!.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 40.0, left: 40.0, bottom: 500.0, right: 40.0), animated: true)
                        mapRect = mapView.visibleMapRect.union(route!.polyline.boundingMapRect)
                        self.isMapRectLoaded = true
                        self.currentOverlay = route?.polyline
                    }
                })
            }
            if index == locationArray.count - 1 && isMapRectLoaded {
                mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets.init(top: 20.0, left: 40.0, bottom: 400.0, right: 40.0), animated: true)
            }
            
        }
    }
    
    /* All Private Methods */
    private func getFormattedAddress(placemark: CLPlacemark) -> String {
        let address = "\(placemark.subThoroughfare ?? "NO Content") \(placemark.thoroughfare ?? "NO Content"), \(placemark.locality ?? "NO Content"), \(placemark.administrativeArea ?? "NO Content"), \(placemark.postalCode ?? "NO Content"), \(placemark.country ?? "NO Content")"
        let baseFormat = address.components(separatedBy: "NO Content, ").joined()
        let formattedAddress = baseFormat.components(separatedBy: "NO Content ").joined()
        
        return formattedAddress;
    }
    
    private func getRouteBetween(source: MKPlacemark, destination: MKPlacemark, completionHandler: @escaping CompletionHandler) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: source)
        request.destination = MKMapItem(placemark: destination)
        //request.requestsAlternateRoutes = true
        request.transportType = [.automobile]
        var route: MKRoute?
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "No error specified").")
                return
            }
            
            route = response.routes[0]
            completionHandler(route)
        }
    }
}

