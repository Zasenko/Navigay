//
//  LocationManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 11.09.23.
//

import SwiftUI
import CoreLocation

enum LocationStatus {
    case authorized, denied, loading
}

final class LocationManager: NSObject, ObservableObject {
    
    //MARK: - Properties
    @Published var userLocation: CLLocation = CLLocation(latitude: 48.24608899975663, longitude: 16.43973750035735)
   // @Published var userLocation: CLLocation? = nil
    @Published var authorizationStatus: LocationStatus = .loading
    @Published var isAlertIfLocationDeniedDisplayed: Bool = false
    
    var locationsChanged: (() -> Void)?
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    
    //private let networkManager: LocationNetworkManagerProtocol
        
    // MARK: - Inits
    
    override init() {
        super.init()
        locationManager.distanceFilter = 100 //TODO?
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //TODO?
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if locationManager.authorizationStatus == .denied {
            isAlertIfLocationDeniedDisplayed = true
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            authorizationStatus = .authorized
            manager.requestLocation()
        case .denied:
            authorizationStatus = .denied
            
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default: ()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("---ERROR--- LocationManager: " , error.localizedDescription, error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.last, currentLocation != userLocation else { return }
        userLocation = currentLocation
        locationsChanged?()
  //      fetchLocations(userLocation: currentLocation)
    }
}

extension LocationManager {
    
    //MARK: - Private Functions

}
