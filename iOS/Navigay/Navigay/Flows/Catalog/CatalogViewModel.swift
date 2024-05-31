//
//  CatalogViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 14.03.24.
//

import SwiftUI
import SwiftData

extension CatalogView {
    @Observable
    class CatalogViewModel {
        
        var modelContext: ModelContext
        
        var isLoading: Bool = false
        var countries: [Country] = []
        
     //   var showSearchView: Bool = false
       // var isSearching: Bool = false
       // var searchText: String = ""

        let catalogNetworkManager: CatalogNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let catalogDataManager: CatalogDataManagerProtocol
        
        init(modelContext: ModelContext,
             catalogNetworkManager: CatalogNetworkManagerProtocol,
             placeNetworkManager: PlaceNetworkManagerProtocol,
             eventNetworkManager: EventNetworkManagerProtocol,
             errorManager: ErrorManagerProtocol,
             placeDataManager: PlaceDataManagerProtocol,
             eventDataManager: EventDataManagerProtocol,
             catalogDataManager: CatalogDataManagerProtocol) {
            self.modelContext = modelContext
            self.catalogNetworkManager = catalogNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
            self.catalogDataManager = catalogDataManager
        }
        
        func getCountriesFromDB() {
            print("--- catalog  getCountriesFromDB()")
            countries = catalogDataManager.getAllCountries(modelContext: modelContext)
            if countries.isEmpty {
                isLoading = true
            }
        }
        
        func fetchCountries() {
            Task {
                guard !catalogNetworkManager.isCountriesLoaded else {
                    return
                }
                do {
                    let decodedCountries = try await self.catalogNetworkManager.fetchCountries()
                    await updateCoutries(decodedCountries: decodedCountries)
                } catch NetworkErrors.noConnection {
                } catch NetworkErrors.apiError(let apiError) {
                    errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
                } catch {
                    errorManager.showUpdateError(error: error)
                }
                await MainActor.run {
                    isLoading = false
                }
            }
        }
        
        private func updateCoutries(decodedCountries: [DecodedCountry]) async {
            let ids = decodedCountries.map { $0.id }
            var countriesToDelete: [Country] = []
            countries.forEach { country in
                if !ids.contains(country.id) {
                    countriesToDelete.append(country)
                }
            }
            await MainActor.run { [countriesToDelete] in
                countriesToDelete.forEach( { modelContext.delete($0) } )
                let newCountries = catalogDataManager.updateCountries(decodedCountries: decodedCountries, modelContext: modelContext)
                self.countries = newCountries.sorted(by: { $0.name < $1.name})
            }
        }
    }
}
