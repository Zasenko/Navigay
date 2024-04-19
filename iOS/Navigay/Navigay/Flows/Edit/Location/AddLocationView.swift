//
//  AddLocationView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 23.10.23.
//

import SwiftUI
import MapKit

struct AddLocationView: View {
    
    //MARK: - Properties
    
    @Binding var isoCountryCode: String
    @Binding var countryEnglish: String
    @Binding var regionEnglish: String
    @Binding var cityEnglish: String
    @Binding var addressOrigin: String
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    
    //MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedPlacemark: MKPlacemark?
    @State private var showSearch: Bool = false
    private let geocoder = CLGeocoder()
    
    //MARK: - Body
    
    var body: some View {
            MapReader { reader in
                Map(position: $position) {
                    if let selectedPlacemark {
                        Marker("", coordinate: selectedPlacemark.coordinate)
                    }
                }
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
                .mapControlVisibility(.hidden)
                .safeAreaInset(edge: .top) {
                    HStack(alignment: .top, spacing: 10) {
                        Button {
                            dismiss()
                        } label: {
                            AppImages.iconX
                                .bold()
                                .padding()
                                .background(.thinMaterial)
                                .clipShape(.circle)
                        }
                        Spacer()
                        Button {
                            showSearch = true
                        } label: {
                            AppImages.iconSearch
                                .bold()
                                .padding()
                                .background(.thinMaterial)
                                .clipShape(.circle)
                        }
                        .sheet(isPresented: $showSearch){
                            SearchLocationView(selectedPlacemark: $selectedPlacemark, position: $position)
                                .padding(.top)
                                .presentationDetents([.medium])
                                .presentationCornerRadius(25)
                                .presentationDragIndicator(.hidden)
                        }
                    }
                    .padding(.horizontal)
                }
                .safeAreaInset(edge: .bottom) {
                    if let placemark = selectedPlacemark {
                        VStack {
                            Divider()
                            let thoroughfare = placemark.thoroughfare
                            let subThoroughfare = placemark.subThoroughfare
                            let locality = placemark.locality
                            let country = placemark.country
                            Text(thoroughfare ?? "")
                            + Text(thoroughfare != nil ? " " : "")
                            + Text(subThoroughfare ?? "")
                            + Text(thoroughfare != nil || subThoroughfare != nil ? ", " : "")
                            + Text(locality ?? "")
                            + Text(locality != nil ? ", " : "")
                            + Text(country ?? "")
                            
                            Button("Select") {
                                reverseLocationCoordinatesOrigin()
                            }
                            .buttonStyle(.bordered)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding()
                    }
                }
                .onTapGesture(perform: { screenCoordinate in
                    if let pinLocation = reader.convert(screenCoordinate, from: .local) {
                        let coordinate = CLLocationCoordinate2D(latitude: pinLocation.latitude, longitude: pinLocation.longitude)
                        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        geocoder.reverseGeocodeLocation(location) { placemarks, error in
                            let selectedPlacemark = selectedPlacemark
                            if let placemark = placemarks?.first, let coordinate = placemark.location?.coordinate {
                                self.selectedPlacemark = MKPlacemark(placemark: placemark)
                                if selectedPlacemark == nil {
                                    withAnimation {
                                        position = .camera(MapCamera(centerCoordinate: coordinate, distance: 3000))
                                    }
                                }
                            }
                        }
                    }
                })
            }
            .toolbar(.hidden, for: .navigationBar)
        
    }
    
    //MARK: - Private functions
    
    private func reverseLocationCoordinatesOrigin() {
        guard let selectedPlacemark,
              let location = selectedPlacemark.location,
              let isoCountryCode = selectedPlacemark.isoCountryCode
        else { return }
        
        latitude = selectedPlacemark.coordinate.latitude
        longitude = selectedPlacemark.coordinate.longitude
        self.isoCountryCode = isoCountryCode
        
        getLocationLanguage(location: location) { language in
            let preferredLanguage = language ?? "en-US"
            let preferredLocale = Locale(identifier: preferredLanguage)
            
            geocoder.reverseGeocodeLocation(location, preferredLocale: preferredLocale) { placemarks, error in
                guard let place = placemarks?.first, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    let thoroughfare = place.thoroughfare ?? ""
                    let subThoroughfare = place.subThoroughfare ?? ""
                    let comma = thoroughfare.isEmpty || subThoroughfare.isEmpty  ? "" : ", "
                    self.addressOrigin = "\(thoroughfare)\(comma)\(subThoroughfare)"
                }
                let preferredLocale = Locale(identifier: "en-US")
                geocoder.reverseGeocodeLocation(location, preferredLocale: preferredLocale) { placemarks, error in
                    guard let place = placemarks?.first else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.countryEnglish = place.country ?? ""
                        self.regionEnglish = place.administrativeArea ?? ""
                        self.cityEnglish = place.locality ?? ""
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getLocationLanguage(location: CLLocation, completion: @escaping(String?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, let isoCountryCode = placemark.isoCountryCode else {
                completion(nil)
                return
            }
            let locale = Locale(identifier: isoCountryCode)
            let preferredLanguage = locale.language.languageCode?.identifier
            completion(preferredLanguage)
        }
    }
}

#Preview {
    AddLocationView(isoCountryCode: .constant(""), countryEnglish: .constant(""), regionEnglish: .constant(""), cityEnglish: .constant(""), addressOrigin: .constant(""), latitude: .constant(0), longitude: .constant(0))
}
