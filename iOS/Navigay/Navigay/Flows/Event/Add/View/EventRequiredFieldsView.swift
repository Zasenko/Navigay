//
//  RequiredFieldsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import SwiftUI
import MapKit

struct EventRequiredFieldsView: View {
    
    @Binding var name: String
    @Binding var type: EventType?
    @Binding var isoCountryCode: String
    @Binding var countryEnglish: String
    @Binding var regionEnglish: String
    @Binding var cityEnglish: String
    @Binding var addressOrigin: String
    @Binding var latitude: Double?
    @Binding var longitude: Double?
        
    //MARK: - Private Properties
    
    @State private var position: MapCameraPosition = .automatic
    @State private var showMap: Bool = false
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    NavigationLink {
                        EditTextFieldView(text: name, characterLimit: 255, minHaracters: 2, title: "Title", placeholder: "Title") { string in
                            name = string
                        }
                    } label: {
                        EditField(title: "Title", text: $name, emptyFieldColor: .red)
                    }
                    Divider()
                        .padding(.horizontal)
                    typeField
                }
                .background(AppColors.lightGray6)
                .cornerRadius(10)
                .padding(.bottom, 40)
                
                locationField
                if let latitude, let longitude {
                    map(latitude: latitude, longitude: longitude)
                        .padding(.bottom)
                }
                
                NavigationLink {
                    EditTextFieldView(text: addressOrigin, characterLimit: 50, minHaracters: 5, title: "Address", placeholder: "Address") { string in
                        addressOrigin = string
                    }
                } label: {
                    EditField(title: "Address", text: $addressOrigin, emptyFieldColor: .secondary)
                }
            }
            .padding()
        }
    }
    
    //MARK: - Views
    
    private var typeField: some View {
            Menu {
                ForEach(EventType.allCases, id: \.self) { type in
                    Button(type.getName()) {
                        self.type = type
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Type")
                            .font(.callout)
                            .foregroundStyle(type == nil ? .red : .green)
                        if let type {
                            Text(type.getName())
                                .tint(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    AppImages.iconRight
                        .foregroundStyle(.quaternary)
                }
                .padding()
            }
    }
    
    private var locationField: some View {
        HStack {
            Text("Location")
                .font(.callout)
                .foregroundStyle(latitude == nil || longitude == nil ? .red : .green)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Select on map") {
                showMap.toggle()
            }
            .fullScreenCover(isPresented: $showMap) {
                AddLocationView(isoCountryCode: $isoCountryCode, countryEnglish: $countryEnglish, regionEnglish: $regionEnglish, cityEnglish: $cityEnglish, addressOrigin: $addressOrigin, latitude: $latitude, longitude: $longitude)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func map(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> some View {
        VStack(spacing: 4) {
            let centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            Map(position: $position, interactionModes: []) {
                if type != nil {
                    Marker("", monogram: Text("🎉"), coordinate: centerCoordinate)
                        .tint(.red)
                } else {
                    Marker("", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
            .mapControlVisibility(.hidden)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onAppear {
                position = .camera(MapCamera(centerCoordinate: centerCoordinate, distance: 500))
            }
            HStack(spacing: 5) {
                Text(countryEnglish)
                Text("•")
                Text(cityEnglish)
            }
            .padding(.horizontal)
            .font(.callout)
        }
    }
}

#Preview {
    EventRequiredFieldsView(name: .constant(""), type: .constant(nil), isoCountryCode: .constant(""), countryEnglish: .constant(""), regionEnglish: .constant(""), cityEnglish: .constant(""), addressOrigin: .constant(""), latitude: .constant(16.55788), longitude: .constant(48.25656))
}
