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
        
        var showSearchView: Bool = false
        var isSearching: Bool = false
        var searchText: String = ""

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
            print("--- SearchViewModel getCountriesFromDB()")
            do {
                let descriptor = FetchDescriptor<Country>(sortBy: [SortDescriptor(\.name)])
                countries = try modelContext.fetch(descriptor)
                if countries.isEmpty {
                    isLoading = true
                }
            } catch {
                debugPrint(error)
            }
        }
        
        func fetchCountries() {
            Task {
                guard !catalogNetworkManager.isCountriesLoaded else {
                    return
                }
                let errorModel = ErrorModel(massage: "Something went wrong. The information has not been updated. Please try again later.", img: nil, color: nil)
                do {
                    let decodedCountries = try await self.catalogNetworkManager.fetchCountries()
                    await updateCoutries(decodedCountries: decodedCountries)
                } catch NetworkErrors.apiError(let apiError) {
                    errorManager.showApiErrorOrMessage(apiError: apiError, or: errorModel)
                } catch {
                    errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
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
                var newCountries: [Country] = []
                for decodedCountry in decodedCountries {
                    if let country = countries.first(where: { $0.id == decodedCountry.id} ) {
                        country.updateCountryIncomplete(decodedCountry: decodedCountry)
                        newCountries.append(country)
                    } else {
                        let country = Country(decodedCountry: decodedCountry)
                        modelContext.insert(country)
                        newCountries.append(country)
                    }
                }
                self.countries = newCountries.sorted(by: { $0.name < $1.name})
                isLoading = false
            }
        }
    }
}
