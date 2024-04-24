//
//  PlaceRequiredFieldsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 31.10.23.
//

import SwiftUI
import MapKit

struct PlaceRequiredFieldsView: View {
    
    //MARK: - Properties
    
    @ObservedObject var viewModel: AddNewPlaceViewModel
    
    //MARK: - Private Properties
    
    @State private var position: MapCameraPosition = .automatic
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
                LazyVStack(spacing: 0) {
                    VStack(spacing: 0) {
                        NavigationLink {
                            EditTextFieldView(text: viewModel.name, characterLimit: 255, minHaracters: 2, title: "Title", placeholder: "Title") { string in
                                viewModel.name = string
                            }
                        } label: {
                            EditField(title: "Title", text: $viewModel.name, emptyFieldColor: .red)
                        }
                        Divider()
                            .padding(.horizontal)
                        typeField
                    }
                    .background(AppColors.lightGray6)
                    .cornerRadius(10)
                    .padding(.bottom, 40)
                    
                    locationField
                    if let latitude = viewModel.latitude, let longitude = viewModel.longitude {
                        map(latitude: latitude, longitude: longitude)
                            .padding(.bottom)
                    }
                    NavigationLink {
                        EditTextFieldView(text: viewModel.addressOrigin, characterLimit: 255, minHaracters: 5, title: "Address", placeholder: "Address") { string in
                            viewModel.addressOrigin = string
                        }
                    } label: {
                        EditField(title: "Address", text: $viewModel.addressOrigin, emptyFieldColor: .red)
                    }
                    
                    
                }
                .padding(.horizontal)
        }
    }
    
    //MARK: - Views
    
    private var typeField: some View {
            Menu {
                ForEach(PlaceType.allCases, id: \.self) { type in
                    Button("\(type.getImage())  \(type.getName())") {
                        viewModel.type = type
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Type")
                            .font(.callout)
                            .foregroundStyle(viewModel.type == nil ? .red : .green)
                        if let type = viewModel.type {
                            Text("\(type.getName())  \(type.getImage())")
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
                .foregroundStyle(viewModel.latitude == nil || viewModel.longitude == nil ? .red : .green)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Select on map") {
                viewModel.showMap.toggle()
            }
            .fullScreenCover(isPresented: $viewModel.showMap) {
                AddLocationView(isoCountryCode: $viewModel.isoCountryCode, countryEnglish: $viewModel.countryEnglish, regionEnglish: $viewModel.regionEnglish, cityEnglish: $viewModel.cityEnglish, addressOrigin: $viewModel.addressOrigin, latitude: $viewModel.latitude, longitude: $viewModel.longitude)
            }
        }
        .padding()
    }
    
//    //TODO сделать пин большим
//    private var map: some View {
//        VStack(spacing: 0) {
//            if let latitude = viewModel.latitude, let longitude = viewModel.longitude  {
//                let centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                Map(position: $position, interactionModes: []) {
//                    if let type = viewModel.type {
//                        Marker("", monogram: Text(type.getImage()), coordinate: centerCoordinate)
//                            .tint(type.getColor())
//                    } else {
//                        Marker("", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
//                    }
//                }
//                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
//                .mapControlVisibility(.hidden)
//                .frame(height: 200)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .padding(.bottom)
//                .onAppear {
//                    position = .camera(MapCamera(centerCoordinate: centerCoordinate, distance: 100))
//                }
//            }
//        }
//    }
    
    @ViewBuilder
    private func map(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> some View {
        VStack(spacing: 0) {
            let centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            Map(position: $position, interactionModes: []) {
                if viewModel.type != nil {
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
                Text(viewModel.countryEnglish)
                Text("•")
                Text(viewModel.cityEnglish)
            }
            .padding()
            .font(.callout)
        }
    }
}

#Preview {
    let decodetUser = DecodedAppUser(id: 0, name: "Test", email: "test@test.com", status: .admin, sessionKey: "000", bio: nil, photo: nil)
    let user = AppUser(decodedUser: decodetUser)
    let errorManager = ErrorManager()
    let appSettingsManager = AppSettingsManager()
    let networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
    let networkManager = EditPlaceNetworkManager(networkMonitorManager: networkMonitorManager)
    return PlaceRequiredFieldsView(viewModel: AddNewPlaceViewModel(networkManager: networkManager, errorManager: errorManager))
}
