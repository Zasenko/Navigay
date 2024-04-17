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
                        AdminCountriesView(viewModel: AdminCountriesViewModel(user: viewModel.user, errorManager: viewModel.errorManager, networkManager: viewModel.networkManager))
                    }
                }
                Section("Unchecked Countries") {
                    ForEach(viewModel.uncheckedCountries) { country in
                        NavigationLink {
                            EditCountryView(viewModel: EditCountryViewModel(id: country.id, country: nil, user: viewModel.user, errorManager: viewModel.errorManager, networkManager: EditCountryNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager)))
                        } label: {
                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("id: \(country.id), code: \(country.isoCountryCode)")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                    Text(country.nameEn ?? "")
                                        .font(.headline)
                                        .bold()
                                }
                            }
                        }
                    }
                }
                Section("Unchecked Regions") {
                    EmptyView()
                    ForEach(viewModel.uncheckedRegions) { region in
                        NavigationLink {
                            EditRegionView(viewModel: EditRegionViewModel(id: region.id, countryId: region.countryId, region: nil, user: viewModel.user, errorManager: viewModel.errorManager, networkManager: EditRegionNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager)))
                        } label: {
                            VStack {
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("id \(region.id)")
                                            .font(.callout)
                                            .foregroundStyle(.secondary)
                                        Text(region.nameEn ?? region.nameOrigin ?? "")
                                            .font(.headline)
                                            .bold()
                                    }
                                }
                            }
                        }
                    }
                }
                Section("Unchecked Cities") {
                    ForEach(viewModel.uncheckedCities) { city in
                        NavigationLink {
                            EditCityView(viewModel: EditCityViewModel(id: city.id, city: nil, user: viewModel.user, errorManager: viewModel.errorManager, networkManager: EditCityNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager)))
                        } label: {
                            VStack(alignment: .leading) {
                                Text("id \(city.id)")
                                Text(city.nameEn ?? city.nameOrigin ?? "")
                            }
                        }
                    }
                }
                
                Section("Unchecked Events") {
                    ForEach(viewModel.uncheckedEvents) { event in
                        NavigationLink {
                            EditEventView(viewModel: EditEventViewModel(eventID: event.id, user: viewModel.user, event: nil, networkManager: EditEventNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager), errorManager: viewModel.errorManager))
                        } label: {
                            VStack(alignment: .leading) {
                                Text("id \(event.id)")
                                Text(event.name)
                                Text(event.type.getName())
                            }
                        }
                    }
                }
                
                Section("Unchecked Places") {
                    ForEach(viewModel.uncheckedPlaces) { place in
                        NavigationLink {
                            EditPlaceView(viewModel: EditPlaceViewModel(id: place.id, place: nil, user: viewModel.user, networkManager: EditPlaceNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager), errorManager: viewModel.errorManager))
                        } label: {
                            VStack(alignment: .leading) {
                                Text("id \(place.id)")
                                Text(place.name)
                                Text(place.type.getName())
                            }
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
                    viewModel.getAdminInfo()
                }
            }
            .refreshable {
                viewModel.getAdminInfo()
            }
        }
    }
    
    private var addView: some View {
        Section {
            NavigationLink {
                NewPlaceView(viewModel: AddNewPlaceViewModel(networkManager: EditPlaceNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager), errorManager: viewModel.errorManager))
            } label: {
                Label(
                    title: { Text("Add new Place") },
                    icon: { AppImages.iconPlus }
                )
            }
            NavigationLink {
                NewEventView(viewModel: NewEventViewModel(user: viewModel.user , place: nil, copy: nil, networkManager: EditEventNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager), errorManager: viewModel.errorManager))
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
