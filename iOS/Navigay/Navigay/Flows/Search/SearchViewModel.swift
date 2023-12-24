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
        
        var countries: [Country] = []
        
        var searchText: String = ""
        
        let catalogNetworkManager: CatalogNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        
        init(modelContext: ModelContext, catalogNetworkManager: CatalogNetworkManagerProtocol, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol) {
            self.modelContext = modelContext
            self.catalogNetworkManager = catalogNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
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
                    }
                }
            }
        }
        
        func getCountriesFromDB() {
            do {
                let descriptor = FetchDescriptor<Country>(sortBy: [SortDescriptor(\.name)])
                countries = try modelContext.fetch(descriptor)
            } catch {
                debugPrint(error)
            }
        }
    }
}
