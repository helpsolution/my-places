//
//  MapManager.swift
//  MyPlaces
//
//  Created by freelance on 05/11/2019.
//  Copyright © 2019 freelance. All rights reserved.
//


import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
   
    private var placeCoordinate : CLLocationCoordinate2D?
    private let regionInMeters = 1000.00
    private var directionsArray : [MKDirections] = []
 
    //marker of place
    
    func setupPlacemark(place : Place, mapView : MKMapView){
        
        guard let location = place.location else {return}
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location) { (placemarks, error ) in
            
            if let error = error {
                print (error)
                return
            }
            
            guard let placemarks = placemarks else {return}
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
 
    //check availability of geolocation's services
    
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () ->()){
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView,
                                       segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.showAlert(
                    title: "Location services are disabled",
                    message: "To enable it go: Settings -> Privacy -> Location services and turn on")
            }
        }
    }
    
    // check authorization of app for using geolocation's services
    
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" {showUserLocation(mapView: mapView)}
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.showAlert(
                    title: "Authorization Status is denied",
                    message: "To enable it go: Settings")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.showAlert(
                    title: "Authorization Status is restricted",
                    message: "To enable it go: Settings")
            }
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    // focus of map on current user's location
    
    func showUserLocation(mapView: MKMapView){
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
        
    }
    
    // build the route from user's location to place
    
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation)-> ()){
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate { (response, error) in
            
            if let error = error {
                print (error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }
            
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print ("Расстояние до места: \(distance) км.")
                print("Время в пути: \(timeInterval) сек")
            }
        }
    }
    
    // setting the request for calculating of route
    
     func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) ->MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else {return nil}
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    // change visible zone of map according with moving of user
    
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation? , closure: (_ currentLocation: CLLocation) -> ()){
        
        guard let location = location else {return}
        let center = getCenterLocation(for: mapView)
        
        guard center.distance(from: location) > 50 else {
            return
        }
        
        closure(center)
    }
    
    // resetting everything early builded routes before building new
    
    private func resetMapView (withNew directions: MKDirections, mapView: MKMapView){
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map{ $0.cancel() }
        directionsArray.removeAll()
    }
    
    //detecting centre of showing zone of map
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    func showAlert(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
        
    }
}
