//
//  SearchViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 24.12.23.
//

import SwiftUI
import SwiftData

extension SearchView {
    @Observable
    class SearchViewModel {
        
        var modelContext: ModelContext
        let user: AppUser?
        
        var countries: [Country] = []
        
        var searchText: String = ""
        var isLoading: Bool = false
        
        let catalogNetworkManager: CatalogNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        
        init(modelContext: ModelContext, catalogNetworkManager: CatalogNetworkManagerProtocol, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, user: AppUser?) {
            self.modelContext = modelContext
            self.catalogNetworkManager = catalogNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.user = user
        }
        
        func fetch() {
            if !catalogNetworkManager.isCountriesLoaded {
                Task {
                    guard let decodedCountries = await catalogNetworkManager.fetchCountries() else {
                        return
                    }
                    await MainActor.run {
                        for decodedCountry in decodedCountries {
                            if let country = countries.first(where: { $0.id == decodedCountry.id} ) {
                                country.updateCountryIncomplete(decodedCountry: decodedCountry)
                            } else if decodedCountry.isActive {
                                let country = Country(decodedCountry: decodedCountry)
                                modelContext.insert(country)
                                countries.append(country)
                            }
                        }
                        isLoading = false
                    }
                }
            }
        }
        
        func getCountriesFromDB() {
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
    }
}
