//
//  AdminCitiesView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.04.24.
//

import SwiftUI

final class AdminCitiesViewModel: ObservableObject {
    
    let errorManager: ErrorManagerProtocol
    let networkManager: AdminNetworkManagerProtocol
    
    @Published var cities: [AdminCity] = []
    
    let region: AdminRegion
    let user: AppUser
    
    // MARK: - Inits
    
    init(region: AdminRegion, user: AppUser, errorManager: ErrorManagerProtocol, networkManager: AdminNetworkManagerProtocol) {
        self.errorManager = errorManager
        self.networkManager = networkManager
        self.region = region
        self.user = user
    }
}

extension AdminCitiesViewModel {
    
    func fetchCities() {
        Task {
            do {
                let decodedCities = try await networkManager.getCities(regionID: region.id, user: user)
                await MainActor.run {
                    cities = decodedCities
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.errorMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.errorMessage, img: nil, color: nil))
            }
        }
    }
}


struct AdminCitiesView: View {
    
    @StateObject private var viewModel: AdminCitiesViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    
    init(viewModel: AdminCitiesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.cities) { city in
                    NavigationLink {
                        EditCityView(viewModel: EditCityViewModel(id: city.id, city: nil, user: viewModel.user, errorManager: viewModel.errorManager, networkManager: EditCityNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager)))
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("id \(city.id)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                Text(city.nameEn ?? city.nameOrigin ?? "")
                                    .font(.headline)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Circle()
                                        .foregroundStyle(city.isActive ? .green : .red)
                                        .frame(width: 8)
                                    Text("is active")
                                }
                                HStack {
                                    Circle()
                                        .foregroundStyle(city.isChecked ? .green : .red)
                                        .frame(width: 8)
                                    Text("is checked")
                                }
                            }
                        }
                    }
                }
            }
            //.navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text(viewModel.region.nameEn ?? "ID: \(viewModel.region.id)")
                            .font(.caption).bold()
                            .foregroundStyle(.secondary)
                        Text("Cities")
                            .font(.headline).bold()
                    }
                }
            }
            .onAppear() {
                viewModel.fetchCities()
            }
        }
    }
}
