//
//  EditCityView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.11.23.
//

import SwiftUI
import MapKit

struct EditCityView: View {
    
    //MARK: - Private Properties
    
    @StateObject private var viewModel: EditCityViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var position: MapCameraPosition = .automatic

    //MARK: - Inits
    
    init(viewModel: EditCityViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                if viewModel.fetched {
                    editView
                } else {
                    ProgressView()
                        .tint(.blue)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("id: \(viewModel.id)")
                            .font(.caption).bold()
                            .foregroundStyle(.secondary)
                        Text(viewModel.nameEn)
                            .font(.headline.bold())
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        AppImages.iconLeft
                            .bold()
                            .frame(width: 30, height: 30, alignment: .leading)
                    }
                    .tint(.primary)
                }
                if viewModel.fetched {
                    ToolbarItem(placement: .topBarTrailing) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.blue)
                        } else {
                            Button("Save") {
                                viewModel.updateInfo()
                            }
                            .bold()
                        }
                    }
                }
            }
            .disabled(viewModel.isLoadingPhoto)
            .disabled(viewModel.isLoading)
            .disabled(viewModel.isLoadingLibraryPhoto)
            .onAppear {
                viewModel.fetchCity()
            }
            
        }
    }
    
    private var editView: some View {
        GeometryReader { proxy  in
            ScrollView {
                PhotoEditView(canDelete: false, canAddFromUrl: true) {
                    ZStack {
                        if let photo = viewModel.photo {
                            if let image = photo.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: proxy.size.width, height: (proxy.size.width / 4) * 5)
                                    .clipped()
                                    .opacity(viewModel.isLoadingPhoto ? 0.2 : 1)
                            } else if let url = photo.url {
                                ImageLoadingView(url: url, width: proxy.size.width, height: (proxy.size.width / 4) * 5, contentMode: .fit) {
                                    AppColors.lightGray6
                                }
                                .clipped()
                                .opacity(viewModel.isLoadingPhoto ? 0.2 : 1)
                            }
                        } else {
                            AppImages.iconCamera
                                .resizable()
                                .scaledToFit()
                                .opacity(viewModel.isLoadingPhoto ? 0 : 1)
                                .tint(.primary)
                                .frame(width: 100)
                                .frame(width: proxy.size.width, height: (proxy.size.width / 4) * 5)
                                .background(AppColors.lightGray6)
                        }
                        if viewModel.isLoadingPhoto {
                            ProgressView()
                                .tint(.blue)
                        }
                    }
                } onSave: { uiImage in
                    viewModel.updateImage(uiImage: uiImage)
                } onDelete: {}
                
                NamesEditView(nameOrigin: $viewModel.nameOrigin, nameEn: $viewModel.nameEn)
                    .padding()
                
                Toggle(isOn: $viewModel.isCapital) {
                    Text("⭐️ Capital")
                }
                
                Toggle(isOn: $viewModel.isParadise) {
                    Text("🏳️‍🌈 Gay paradice")
                }
                                
                if viewModel.latitude != 0, viewModel.longitude != 0 {
                    Map(position: $position, interactionModes: [.zoom]) {
                        Marker("", coordinate: CLLocationCoordinate2D(latitude: viewModel.latitude, longitude: viewModel.longitude))
                            .annotationTitles(.hidden)
                    }
                    .mapStyle(.standard(elevation: .flat))
                    .mapControlVisibility(.hidden)
                    .frame(height: proxy.size.width)
                    .clipShape(RoundedRectangle(cornerRadius: 0))
                    .onAppear {
                        position = .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: viewModel.latitude, longitude: viewModel.longitude), distance: 30000))
                    }
                    Button {
                        viewModel.showMap.toggle()
                    } label: {
                        Text("Change city location")
                    }
                } else {
                    Button {
                        viewModel.showMap.toggle()
                    } label: {
                        Text("Add city location")
                    }
                    
                }
                
                NavigationLink {
                    EditTextEditorView(title: "Edit description", text: viewModel.about, characterLimit: 3000) { string in
                        viewModel.about = string
                    }
                } label: {
                    EditField(title: "Description", text: $viewModel.about, emptyFieldColor: .secondary)
                }
                .padding()
                
                EditLibraryView(photos: $viewModel.photos, isLoading: $viewModel.isLoadingLibraryPhoto, width: proxy.size.width) { result in
                    viewModel.updateLibraryPhoto(photoId: result.id, uiImage: result.uiImage)
                } onDelete: { id in
                    viewModel.deleteLibraryPhoto(photoId: id)
                }
                .padding(.vertical)
                
                ActivationFieldsView(isActive: $viewModel.isActive, isChecked: $viewModel.isChecked)
                    .padding(.vertical)
                    .padding(.bottom, 50)
            }
            .scrollIndicators(.hidden)
            .fullScreenCover(isPresented: $viewModel.showMap) {
                AddLocationView2 { location in
                    viewModel.latitude = location.latitude
                    viewModel.longitude = location.longitude
                    viewModel.showMap.toggle()
                }
            }
        }
    }
}

//#Preview {
//    let errorManager = ErrorManager()
//    let networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
//    let appSettingsManager = AppSettingsManager()
//    let networkManager = AdminNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//    let user = AppUser(decodedUser: DecodedAppUser(id: 0, name: "", email: "", status: .admin, sessionKey: "", bio: nil, photo: nil))
//    let editCityNetworkManager = EditCityNetworkManager(networkMonitorManager: networkMonitorManager)
//    return EditCityView(viewModel: EditCityViewModel(id: 0, city: nil, user: user, errorManager: errorManager, networkManager: editCityNetworkManager))
//}

struct Location {
    let isoCountryCode: String
    let countryEnglish: String
    let regionEnglish: String
    let cityEnglish: String
    let addressOrigin: String
    let latitude: Double
    let longitude: Double
}

struct AddLocationView2: View {
    
    //MARK: - Properties
    
    var onSave: (Location) -> Void
    
    //MARK: - Inits
    
    init(onSave: @escaping (Location) -> Void) {
        self.onSave = onSave
    }

    //MARK: - Private Properties
    
    @State private var isoCountryCode: String?
    @State private var countryEnglish: String?
    @State private var regionEnglish: String?
    @State private var cityEnglish: String?
    @State private var addressOrigin: String?
    @State private var latitude: Double?
    @State private var longitude: Double?
    
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
                        if isoCountryCode != nil, latitude != nil, longitude != nil {
                            Button {
                                guard let isoCountryCode, let latitude, let longitude else { return }
                                let location = Location(isoCountryCode: isoCountryCode, countryEnglish: countryEnglish ?? "", regionEnglish: regionEnglish ?? "", cityEnglish: cityEnglish ?? "", addressOrigin: addressOrigin ?? "", latitude: latitude, longitude: longitude)
                                onSave(location)
                            } label: {
                                Text("Done")
                                    .bold()
                                    .padding()
                                    .background(.thinMaterial)
                                    .clipShape(.capsule)
                            }
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
    AddLocationView2() { location in
        debugPrint(location)
    }
}
