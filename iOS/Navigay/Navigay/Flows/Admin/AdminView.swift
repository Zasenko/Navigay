//
//  AdminView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI

final class AdminViewModel: ObservableObject {
    
    let user: AppUser
    let errorManager: ErrorManagerProtocol
    let networkManager: AdminNetworkManagerProtocol
    
    @Published var uncheckedPlaces: [AdminPlace] = []
    @Published var uncheckedCities: [AdminCity] = []
    @Published var uncheckedRegions: [AdminRegion] = []
    @Published var uncheckedCountries: [AdminCountry] = []
    
    // MARK: - Inits
    
    init(user: AppUser, errorManager: ErrorManagerProtocol, networkManager: AdminNetworkManagerProtocol) {
        self.user = user
        self.errorManager = errorManager
        self.networkManager = networkManager
    }
}

extension AdminViewModel {
    
    func getAdminInfo() {
        Task {
            let errorModel = ErrorModel(massage: "Something went wrong. The information has not been updated. Please try again later.", img: nil, color: nil)
            do {
                let decodedResult = try await networkManager.getAdminInfo()
                guard decodedResult.result else {
                    debugPrint("ERROR - getAdminInfo API:", decodedResult.error?.message ?? "---")
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    return
                }
                await MainActor.run {
                    self.uncheckedPlaces = decodedResult.places ?? []
                    self.uncheckedCities = decodedResult.cities ?? []
                    self.uncheckedRegions = decodedResult.regions ?? []
                    self.uncheckedCountries = decodedResult.countries ?? []
                }
            } catch {
                debugPrint("ERROR - getAdminInfo: ", error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            }
        }
    }
}

struct AdminView: View {

    @StateObject var viewModel: AdminViewModel
    
    init(viewModel: AdminViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
//                Section("Unchecked Places") {
//                    ForEach(viewModel.uncheckedPlaces) { place in
//                        VStack {
//                            Text("id \(place.id)")
//                            Text(place.name)
//                            Text(place.type.getName())
//                            Text(place.address)
//                        }
//                    }
//                }
                Section("Unchecked Regions") {
                    ForEach(viewModel.uncheckedRegions) { region in
                        NavigationLink {
                            EditRegionView(viewModel: EditRegionViewModel(region: region, errorManager: viewModel.errorManager, networkManager: viewModel.networkManager))
                        } label: {
                            VStack {
                                Text("id \(region.id)")
                                Text(region.nameOrigin ?? "")
                            }
                        }
                    }
                }
                Section("Unchecked Cities") {
                    ForEach(viewModel.uncheckedCities) { city in
                        NavigationLink {
                            EditCityView(viewModel: EditCityViewModel(city: city, errorManager: viewModel.errorManager, networkManager: viewModel.networkManager))
                        } label: {
                            VStack {
                                Text("id \(city.id)")
                                Text(city.nameOrigin ?? "")
                            }
                        }
                    }
                }
                Section("Unchecked Countries") {
                    ForEach(viewModel.uncheckedCountries) { country in
                        NavigationLink {
                            EditCountryView(viewModel: EditCountryViewModel(country: country, errorManager: viewModel.errorManager, networkManager: viewModel.networkManager))
                        } label: {
                            VStack {
                                Text("id \(country.id)")
                                Text(country.isoCountryCode)
                                Text(country.nameOrigin ?? "")
                            }
                        }
                    }
                }
                Section {
                    NavigationLink("Add new place") {
                        NewPlaceView(viewModel: AddNewPlaceViewModel(user: viewModel.user, networkManager: PlaceNetworkManager(), errorManager: viewModel.errorManager))
                    }
                    NavigationLink("Add new event") {
                        NewEventView(viewModel: NewEventViewModel(user: viewModel.user, place: nil, networkManager: EventNetworkManager(appSettingsManager: AppSettingsManager()), errorManager: viewModel.errorManager))
                    }
                }
            }
            .navigationTitle("Admin panel")
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
                viewModel.getAdminInfo()
            }
            .refreshable {
                viewModel.getAdminInfo()
            }
        }
    }
}

#Preview {
    let decodeduser = DecodedAppUser(id: 0, name: "Dima", email: "test@test.com", status: .admin, bio: nil, photo: nil, instagram: nil, likedPlacesId: nil)
    let user = AppUser(decodedUser: decodeduser)
    let errorManager = ErrorManager()
    let networkManager = AdminNetworkManager()
    return AdminView(viewModel: AdminViewModel(user: user, errorManager: errorManager, networkManager: networkManager))
}
