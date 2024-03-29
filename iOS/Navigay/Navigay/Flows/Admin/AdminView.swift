//
//  AdminView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI

struct AdminView: View {

    @StateObject private var viewModel: AdminViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    
    init(viewModel: AdminViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                addView
                
                Section {
                    NavigationLink("Countries") {
                        AdminCountriesView(viewModel: AdminCountriesViewModel(errorManager: viewModel.errorManager, networkManager: viewModel.networkManager))
                    }
                }
                Section("Unchecked Countries") {
                    ForEach(viewModel.uncheckedCountries) { country in
                        NavigationLink {
                            EditCountryView(viewModel: EditCountryViewModel(id: country.id, country: nil, errorManager: viewModel.errorManager, networkManager: EditCountryNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager)))
                        } label: {
                            HStack(spacing: 10) {
                                if let url = country.photo {
                                    ImageLoadingView(url: url, width: 80, height: 80, contentMode: .fill) {
                                        Color.red
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    Color.clear
                                        .frame(width: 80, height: 80)
                                }
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("id: \(country.id), code: \(country.isoCountryCode)")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                    Text(country.nameOrigin ?? "")
                                        .font(.headline)
                                        .bold()
                                }
                            }
                        }
                    }
                }
                Section("Unchecked Regions") {
                    EmptyView()
//                    ForEach(viewModel.uncheckedRegions) { region in
//                        NavigationLink {
//                            EditRegionView(viewModel: EditRegionViewModel(region: region, errorManager: viewModel.errorManager, networkManager: viewModel.networkManager))
//                        } label: {
//                            VStack {
//                                HStack(spacing: 10) {
//                                    if let url = region.photo {
//                                        ImageLoadingView(url: url, width: 80, height: 80, contentMode: .fill) {
//                                            Color.red
//                                        }
//                                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                                    } else {
//                                        Color.clear
//                                            .frame(width: 80, height: 80)
//                                    }
//                                    VStack(alignment: .leading, spacing: 10) {
//                                        Text("id \(region.id)")
//                                            .font(.callout)
//                                            .foregroundStyle(.secondary)
//                                        Text(region.nameOrigin ?? "")
//                                            .font(.headline)
//                                            .bold()
//                                    }
//                                }
//                            }
//                        }
//                    }
                }
                Section("Unchecked Cities") {
                    ForEach(viewModel.uncheckedCities) { city in
                        NavigationLink {
                            EditCityView(viewModel: EditCityViewModel(id: city.id, errorManager: viewModel.errorManager, networkManager: EditCityNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager)))
                        } label: {
                            VStack {
                                Text("id \(city.id)")
                                Text(city.nameOrigin ?? "")
                            }
                        }
                    }
                }
                
                Section("Unchecked Places") {
                    ForEach(viewModel.uncheckedPlaces) { place in
                        VStack {
                            Text("id \(place.id)")
                            Text(place.name)
                            Text(place.type.getName())
                           // Text(place.address ?? "")
                        }
                    }
                }
                
                Section("Unchecked Events") {
                    ForEach(viewModel.uncheckedEvents) { event in
                        VStack {
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Admin panel")
                        .font(.headline.bold())
                }
            }
            .onAppear() {
                if !viewModel.isFetched {
                    guard let user = authenticationManager.appUser else { return }
                    viewModel.getAdminInfo(for: user)
                }
            }
            .refreshable {
                guard let user = authenticationManager.appUser else { return }
                viewModel.getAdminInfo(for: user)
            }
        }
    }
    
    private var addView: some View {
        Section {
            NavigationLink {
                NewPlaceView(viewModel: AddNewPlaceViewModel(networkManager: EditPlaceNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager), errorManager: viewModel.errorManager))
                
                //                        NewPlaceView(viewModel: AddNewPlaceViewModel(userId: authenticationManager.appUser?.id ?? 0, networkManager: PlaceNetworkManager(appSettingsManager: AppSettingsManager(), errorManager: viewModel.errorManager), errorManager: viewModel.errorManager), authenticationManager: authenticationManager)
            } label: {
                Label(
                    title: { Text("Add new Place") },
                    icon: { AppImages.iconPlus }
                )
            }
            NavigationLink {
                EmptyView()
                //                        NewEventView(viewModel: NewEventViewModel(place: nil, copy: nil, networkManager: EventNetworkManager(appSettingsManager: AppSettingsManager(), errorManager: viewModel.errorManager), errorManager: viewModel.errorManager), authenticationManager: authenticationManager)
            } label: {
                Label(
                    title: { Text("Add new Event") },
                    icon: { AppImages.iconPlus }
                )
            }
        }
    }
}

//#Preview {
//    let keychainManager = KeychainManager()
//    let errorManager = ErrorManager()
//    let apps = AppSettingsManager()
//    let nm = NetworkMonitorManager(errorManager: errorManager)
//let networkManager = AuthNetworkManager(networkMonitorManager: nm, appSettingsManager: apps)
//    
//    let au = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: nm, networkManager: networkManager, errorManager: errorManager)
//    let decodeduser = DecodedAppUser(id: 0, name: "Dima", email: "test@test.com", status: .admin, sessionKey: "kjjj", bio: nil, photo: nil)
//    let user = AppUser(decodedUser: decodeduser)
//    
//    let anetworkManager = AdminNetworkManager(networkMonitorManager: nm, appSettingsManager: apps)
//    return AdminView(viewModel: AdminViewModel(errorManager: errorManager, networkManager: anetworkManager))
//        .environmentObject(au)
//}
