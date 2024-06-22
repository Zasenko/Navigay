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
    
    @Published var userLocation: CLLocation? = nil
    @Published var authorizationStatus: LocationStatus = .loading
    @Published var isAlertIfLocationDeniedDisplayed: Bool = false
    
    @AppStorage("lastUserLatitude") var lastLatitude: Double = 0.0
    @AppStorage("lastUserLongitude") var lastLongitude: Double = 0.0
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
        
    //MARK: - Inits
    
    override init() {
        super.init()
        locationManager.distanceFilter = 5000
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
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
        debugPrint(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last, currentLocation != userLocation else { return }
        userLocation = currentLocation
        lastLatitude = currentLocation.coordinate.latitude
        lastLongitude = currentLocation.coordinate.longitude
    }
}
