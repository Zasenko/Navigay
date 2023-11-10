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
                    VStack {
                        NavigationLink {
                            EditTextFieldView(text: viewModel.name, characterLimit: 20, minHaracters: 2, title: "Title", placeholder: "Title") { string in
                                viewModel.name = string
                            }
                        } label: {
                            nameField
                        }
                        Divider()
                            .padding(.horizontal)
                        typeField
                    }
                    .background(AppColors.lightGray6)
                    .cornerRadius(10)
                    .padding(.bottom, 40)
                    NavigationLink {
                        EditTextFieldView(text: viewModel.addressOrigin, characterLimit: 50, minHaracters: 5, title: "Address", placeholder: "Address") { string in
                            viewModel.addressOrigin = string
                        }
                    } label: {
                        addressField
                    }
                    locationField
                    map
                }
                .padding(.horizontal)
        }
    }
    
    //MARK: - Views
    
    private var nameField: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Name")
                    .font(.callout)
                    .foregroundStyle(viewModel.name.isEmpty ? .red : .green)
                if !viewModel.name.isEmpty {
                    Text(viewModel.name)
                        .multilineTextAlignment(.leading)
                        .tint(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            AppImages.iconRight
                .foregroundStyle(.quaternary)
        }
        .padding()
    }
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
                AddLocationView(isoCountryCode: $viewModel.isoCountryCode, countryOrigin: $viewModel.countryOrigin, countryEnglish: $viewModel.countryEnglish, regionOrigin: $viewModel.regionOrigin, regionEnglish: $viewModel.regionEnglish, cityOrigin: $viewModel.cityOrigin, cityEnglish: $viewModel.cityEnglish, addressOrigin: $viewModel.addressOrigin, latitude: $viewModel.latitude, longitude: $viewModel.longitude)
            }
        }
        .padding()
    }
    
    private var map: some View {
        VStack(spacing: 0) {
            if let latitude = viewModel.latitude, let longitude = viewModel.longitude  {
                let centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                Map(position: $position, interactionModes: []) {
                    if let type = viewModel.type {
                        Marker("", monogram: Text(type.getImage()), coordinate: centerCoordinate)
                            .tint(type.getColor())
                    } else {
                        Marker("", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom)
                .onAppear {
                    position = .camera(MapCamera(centerCoordinate: centerCoordinate, distance: 100))
                }
            }
        }
    }
    
    private var addressField: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Address")
                    .font(.callout)
                    .foregroundStyle(viewModel.addressOrigin.isEmpty ? .red : .green)
                if !viewModel.addressOrigin.isEmpty {
                    Text(viewModel.addressOrigin)
                        .multilineTextAlignment(.leading)
                        .tint(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            AppImages.iconRight
                .foregroundStyle(.quaternary)
        }
        .padding()
        .background(AppColors.lightGray6)
        .cornerRadius(10)
    }
}

//#Preview {
//    NewPlaceRequiredFieldsView(viewModel: AddNewPlaceViewModel(networkManager: AddNetworkManager()))
//}
