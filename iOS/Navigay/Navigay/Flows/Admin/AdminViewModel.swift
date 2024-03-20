//
//  AdminViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 18.03.24.
//

import SwiftUI

final class AdminViewModel: ObservableObject {
    
    let errorManager: ErrorManagerProtocol //todo  убрать
    let networkManager: AdminNetworkManagerProtocol
    
    var isFetched: Bool = false
    @Published var uncheckedCountries: [AdminCountry] = []
    @Published var uncheckedRegions: [AdminRegion] = []
    @Published var uncheckedCities: [AdminCity] = []
    @Published var uncheckedPlaces: [AdminPlace] = []
    @Published var uncheckedEvents: [AdminEvent] = []
    
    // MARK: - Inits
    
    init(errorManager: ErrorManagerProtocol, networkManager: AdminNetworkManagerProtocol) {
        self.errorManager = errorManager
        self.networkManager = networkManager
    }
}

extension AdminViewModel {
    
    func getAdminInfo(for user: AppUser) {
        Task {
            do {
                let decodedResult = try await networkManager.getAdminInfo(for: user)
                await MainActor.run {
                    uncheckedPlaces = decodedResult.places ?? []
                    uncheckedCities = decodedResult.cities ?? []
                    uncheckedRegions = decodedResult.regions ?? []
                    uncheckedCountries = decodedResult.countries ?? []
                    isFetched = true
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
