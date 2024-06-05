//
//  CountryView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData

struct CountryView: View {
    
    // MARK: - Properties
    
    @State private var viewModel: CountryViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Init
    
    init(viewModel: CountryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Divider()
                    List {
                        if let url = viewModel.country.photo {
                            ImageLoadingView(url: url, width: geometry.size.width, height: (geometry.size.width / 4) * 5, contentMode: .fill) {
                                AppColors.lightGray6
                            }
                            .clipped()
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .padding(.bottom, 20)
                        }
                        HStack {
                            Text("Cities")
                                .font(.title)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button {
                                viewModel.showMap.toggle()
                                
                            } label: {
                                HStack(spacing: 4) {
                                    //                                AppImages.iconLocation
                                    //                                    .font(.headline)
                                    Text("Show on map")
                                        .font(.caption)
                                        .bold()
                                }
                                .foregroundStyle(.blue)
                                .padding()
                                .background(AppColors.lightGray6)
                                .clipShape(Capsule(style: .continuous))
                            }
                            .offset(x: -70)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .offset(x: 70)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowSeparator(.hidden)
                        if viewModel.country.showRegions {
                            ForEach(viewModel.country.regions.sorted(by: { $0.id < $1.id } )) { region in
                                RegionView(modelContext: viewModel.modelContext, region: region, catalogNetworkManager: viewModel.catalogNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, catalogDataManager: viewModel.catalogDataManager, commentsNetworkManager: viewModel.commentsNetworkManager)
                            }
                        } else {
                            CitiesView(modelContext: viewModel.modelContext, cities: viewModel.country.regions.flatMap( { $0.cities } ).sorted(by: { $0.id < $1.id } ), showCountryRegion: false, catalogNetworkManager: viewModel.catalogNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, catalogDataManager: viewModel.catalogDataManager, commentsNetworkManager: viewModel.commentsNetworkManager)
                        }
                        Section {
                            Text(viewModel.country.about ?? "")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 50)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .buttonStyle(PlainButtonStyle())
                    .scrollIndicators(.hidden)
                }
                .navigationBarBackButtonHidden()
                .toolbarBackground(AppColors.background)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("\(viewModel.country.flagEmoji) \(viewModel.country.name)")
                            .font(.title2.bold())
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation {
                                dismiss()
                            }
                        } label: {
                            AppImages.iconLeft
                                .bold()
                                .frame(width: 30, height: 30, alignment: .leading)
                        }
                        .tint(.primary)
                    }
                    if let user = authenticationManager.appUser, (user.status == .admin || user.status == .moderator)  {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink {
                                EditCountryView(viewModel: EditCountryViewModel(id: viewModel.country.id, country: viewModel.country, user: user, errorManager: viewModel.errorManager, networkManager: EditCountryNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager)))
                            } label: {
                                AppImages.iconSettings
                                    .bold()
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
                .onAppear() {
                    viewModel.fetch()
                }
                .fullScreenCover(isPresented: $viewModel.showMap) {
                    CitiesMapView(cities: viewModel.country.regions.flatMap( { $0.cities } ).sorted(by: { $0.id < $1.id } ))
                }
            }
        }
    }
}

import _MapKit_SwiftUI
struct CitiesMapView: View {
    
    let cities: [City]
    
    @State private var position: MapCameraPosition = .automatic
    @Environment(\.dismiss) private var dismiss
    
    let colors: [Color] = [.blue, .yellow, .orange, .green, AppColors.background]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                Map(position: $position, interactionModes: [.zoom, .pan]) {
                    ForEach(cities) { city in
                        Annotation(city.name, coordinate: CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude), anchor: .bottom) {
                            annotationView(city: city, size: geometry.size)
                        }
                        .annotationTitles(.hidden)
                    }
                }
                .mapStyle(.standard(elevation: .flat))
                .mapControlVisibility(.hidden)
                .onAppear {
                    position = .automatic
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        AppImages.iconXCircle
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .tint(.primary)
                    }
                }
            }
        }
    }
    
    private func annotationView(city: City, size: CGSize) -> some View {
        let color = colors.randomElement() ?? AppColors.background
        return HStack(spacing: 4) {
            Text(city.name)
                .bold()
            if city.isCapital {
                Text("⭐️")
            }
            if city.isParadise {
                Text("🏳️‍🌈")
            }
        }
        .font(.caption2)
        .padding(10)
        .background(color)
        .clipShape(.capsule)
        .padding(8)
        .overlay(alignment: .bottom) {
            Image(systemName: "arrowtriangle.left.fill")
                .resizable()
                .scaledToFit()
                .rotationEffect (Angle(degrees: 270))
                .foregroundColor(color)
                .frame(width: 10, height: 10)
        }
        .frame(maxWidth: size.width / 2)
    }
}

//
//#Preview {
//    CountryView(country: Country(decodedCountry: DecodedCountry(id: 1, isoCountryCode: "RUS", name: "Russia", flagEmoji: "🇷🇺", photo: "https://thumbs.dreamstime.com/b/церковь-pokrovsky-3476006.jpg", showRegions: true, isActive: true, about: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text.", regions: [])), networkManager: CatalogNetworkManager(appSettingsManager: AppSettingsManager()))
//}
