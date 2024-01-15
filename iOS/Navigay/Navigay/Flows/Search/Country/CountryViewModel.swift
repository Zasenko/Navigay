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
                        country.updateCountryComplite(decodedCountry: decodedCountry)
                        updateRegions(decodedRegions: decodedCountry.regions)
                    }
                }
            }
        }
        
        func updateRegions(decodedRegions: [DecodedRegion]?) {
            if let decodedRegions = decodedRegions, !decodedRegions.isEmpty {
                
                let ids = decodedRegions.map( { $0.id } )
                var regionsToDelete: [Region] = []
                country.regions.forEach { region in
                    if !ids.contains(region.id) {
                        regionsToDelete.append(region)
                    }
                }
                regionsToDelete.forEach( { modelContext.delete($0) } )
                
                for decodedRegion in decodedRegions {
                    if let region = country.regions.first(where: { $0.id == decodedRegion.id} ) {
                        region.updateIncomplete(decodedRegion: decodedRegion)
                        updateCities(decodedCities: decodedRegion.cities, for: region)
                    } else {
                        let region = Region(decodedRegion: decodedRegion)
                        country.regions.append(region)
                        region.country = country
                        updateCities(decodedCities: decodedRegion.cities, for: region)
                    }
                }
            } else {
                country.regions.forEach( { modelContext.delete($0) } )
            }
        }
        
        func updateCities(decodedCities: [DecodedCity]?, for region: Region) {
            if let decodedCities = decodedCities, !decodedCities.isEmpty {
                
                let ids = decodedCities.map( { $0.id } )
                var citiesToDelete: [City] = []
                region.cities.forEach { city in
                    if !ids.contains(city.id) {
                        citiesToDelete.append(city)
                    }
                }
                citiesToDelete.forEach( { modelContext.delete($0) } )
                
                for decodedCity in decodedCities {
                    if let city = region.cities.first(where: { $0.id == decodedCity.id} ) {
                        city.updateCityIncomplete(decodedCity: decodedCity)
                    } else if decodedCity.isActive {
                        let city = City(decodedCity: decodedCity)
                        region.cities.append(city)
                        city.region = region
                    }
                }
            } else {
                region.cities.forEach( { modelContext.delete($0) } )
            }
        }
    }
}
