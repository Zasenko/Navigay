//
//  CountryViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import SwiftUI
import SwiftData

extension CountryView {
    @Observable
    class CountryViewModel {
        
        var modelContext: ModelContext
        let country: Country
        var isLoading: Bool = true // TODO: isLoading
        
        let catalogNetworkManager: CatalogNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        let user: AppUser?
        
        init(modelContext: ModelContext, country: Country, catalogNetworkManager: CatalogNetworkManagerProtocol, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, user: AppUser?) {
            self.modelContext = modelContext
            self.country = country
            self.catalogNetworkManager = catalogNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.user = user
        }
        
        func fetch() {
            if !catalogNetworkManager.loadedCountries.contains(where: { $0 == country.id}) {
                Task {
                    guard let decodedCountry = await catalogNetworkManager.fetchCountry(id: country.id) else {
                        return
                    }
                    await MainActor.run {
                        // TODO!!! проверить
                        if country.isDeleted {
                            print("isDeleted")
                        }
                        if country.hasChanges {
                            print("hasChanges")
                        }
                        country.updateCountryComplite(decodedCountry: decodedCountry)
                        updateRegions(decodedRegions: decodedCountry.regions)
                    }
                }
            }
        }
        
        func updateRegions(decodedRegions: [DecodedRegion]?) {
            if let decodedRegions = decodedRegions, !decodedRegions.isEmpty {
                for decodedRegion in decodedRegions {
                    if let region = country.regions.first(where: { $0.id == decodedRegion.id} ) {
                        region.lastUpdateIncomplete(decodedRegion: decodedRegion)
                        updateCities(decodedCities: decodedRegion.cities, for: region)
                    } else if decodedRegion.isActive {
                        let region = Region(decodedRegion: decodedRegion)
                        country.regions.append(region)
                        updateCities(decodedCities: decodedRegion.cities, for: region)
                    }
                }
            } else {
                country.regions.forEach( { modelContext.delete($0) } )
            }
        }
        
        func updateCities(decodedCities: [DecodedCity]?, for region: Region) {
            if let decodedCities = decodedCities, !decodedCities.isEmpty {
                for decodedCity in decodedCities {
                    if let city = region.cities.first(where: { $0.id == decodedCity.id} ) {
                        city.updateCityIncomplete(decodedCity: decodedCity)
                    } else if decodedCity.isActive {
                        let city = City(decodedCity: decodedCity)
                        region.cities.append(city)
                    }
                }
            } else {
                region.cities.forEach( { modelContext.delete($0) } )
            }
        }
    }
}
