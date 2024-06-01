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
        
        let catalogNetworkManager: CatalogNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let catalogDataManager: CatalogDataManagerProtocol
        
        var showMap: Bool = false
                
        // MARK: - Init
        
        init(modelContext: ModelContext,
             country: Country,
             catalogNetworkManager: CatalogNetworkManagerProtocol,
             placeNetworkManager: PlaceNetworkManagerProtocol,
             eventNetworkManager: EventNetworkManagerProtocol,
             errorManager: ErrorManagerProtocol,
             placeDataManager: PlaceDataManagerProtocol,
             eventDataManager: EventDataManagerProtocol,
             catalogDataManager: CatalogDataManagerProtocol) {
            self.modelContext = modelContext
            self.country = country
            self.catalogNetworkManager = catalogNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
            self.catalogDataManager = catalogDataManager
        }
        
        func fetch() {
            Task {
                guard !catalogNetworkManager.loadedCountries.contains(where: { $0 == country.id}) else {
                    return
                }
                do {
                    let decodedCountry = try await catalogNetworkManager.fetchCountry(id: country.id)
                    await MainActor.run {
                        updateCountry(decodedCountry: decodedCountry)
                    }
                } catch NetworkErrors.noConnection {
                } catch NetworkErrors.apiError(let apiError) {
                    errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
                } catch {
                    errorManager.showUpdateError(error: error)
                }
            }
        }
        
        private func updateCountry(decodedCountry: DecodedCountry) {
            country.updateCountryComplite(decodedCountry: decodedCountry)
            let regions = updateRegions(decodedRegions: decodedCountry.regions)
            country.regions = regions
            try? modelContext.save()
        }
        
        func updateRegions(decodedRegions: [DecodedRegion]?) -> [Region] {
            guard let decodedRegions = decodedRegions, !decodedRegions.isEmpty else {
                country.regions.forEach( { modelContext.delete($0) } )
                return []
            }
            let ids = decodedRegions.map( { $0.id } )
            var regionsToDelete: [Region] = []
            country.regions.forEach { region in
                if !ids.contains(region.id) {
                    regionsToDelete.append(region)
                }
            }
            regionsToDelete.forEach( { modelContext.delete($0) } )
            var regions: [Region] = []
            for decodedRegion in decodedRegions {
                if let region = country.regions.first(where: { $0.id == decodedRegion.id} ) {
                    region.updateIncomplete(decodedRegion: decodedRegion)
                    updateCities(decodedCities: decodedRegion.cities, for: region)
                    regions.append(region)
                } else {
                    let region = Region(decodedRegion: decodedRegion)
                    country.regions.append(region)
                    region.country = country
                    updateCities(decodedCities: decodedRegion.cities, for: region)
                    regions.append(region)
                }
            }
            return regions
        }
        
        func updateCities(decodedCities: [DecodedCity]?, for region: Region) {
            guard let decodedCities = decodedCities, !decodedCities.isEmpty else {
                region.cities.forEach( { modelContext.delete($0) } )
                region.cities = []
                return
            }
                
                let ids = decodedCities.map( { $0.id } )
                var citiesToDelete: [City] = []
                region.cities.forEach { city in
                    if !ids.contains(city.id) {
                        citiesToDelete.append(city)
                    }
                }
                citiesToDelete.forEach( { modelContext.delete($0) } )
                
                var cities: [City] = []
                for decodedCity in decodedCities {
                    if let city = region.cities.first(where: { $0.id == decodedCity.id} ) {
                        city.updateCityIncomplete(decodedCity: decodedCity)
                        city.region = region
                        cities.append(city)
                    } else {
                        let city = City(decodedCity: decodedCity)
                        city.region = region
                        cities.append(city)
                    }
                }
                region.cities = cities
        }
    }
}
