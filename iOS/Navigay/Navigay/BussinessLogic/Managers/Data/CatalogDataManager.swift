//
//  CatalogDataManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.01.24.
//

import Foundation
import SwiftData

protocol CatalogDataManagerProtocol {
    /// return [City] sorted by name
    func updateCities(decodedCities: [DecodedCity]?, modelContext: ModelContext) -> [City]
}

final class CatalogDataManager: CatalogDataManagerProtocol {
    
    func updateCities(decodedCities: [DecodedCity]?, modelContext: ModelContext) -> [City] {
        guard let decodedCities, !decodedCities.isEmpty else {
            return []
        }
        do {
            let cityDescriptor = FetchDescriptor<City>()
            let allCities = try modelContext.fetch(cityDescriptor)
            
            var cities: [City] = []
            for decodedCity in decodedCities {
                if let city = allCities.first(where: { $0.id == decodedCity.id} ) {
                    city.updateCityIncomplete(decodedCity: decodedCity)
                    updateCityRegion(decodedRegion: decodedCity.region, for: city, modelContext: modelContext)
                    cities.append(city)
                } else {
                    let city = City(decodedCity: decodedCity)
                    modelContext.insert(city)
                    updateCityRegion(decodedRegion: decodedCity.region, for: city, modelContext: modelContext)
                    cities.append(city)
                }
            }
            return cities.sorted(by: { $0.name < $1.name})
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func updateCities(decodedCities: [DecodedCity]?, for region: Region, modelContext: ModelContext) {
        guard let decodedCities, !decodedCities.isEmpty else {
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
        
        for decodedCity in decodedCities {
            if let city = region.cities.first(where: { $0.id == decodedCity.id} ) {
                city.updateCityIncomplete(decodedCity: decodedCity)
            } else {
                let city = City(decodedCity: decodedCity)
                region.cities.append(city)
                city.region = region
            }
        }

    }
    
    
    private func updateCityRegion(decodedRegion: DecodedRegion?, for city: City, modelContext: ModelContext) {
        guard let decodedRegion else {
            return
        }
        do {
            let regionDescriptor = FetchDescriptor<Region>()
            let allRegions = try modelContext.fetch(regionDescriptor)
            
            if let region = allRegions.first(where: { $0.id == decodedRegion.id} ) {
                region.updateIncomplete(decodedRegion: decodedRegion)
                city.region = region
                if !region.cities.contains(where: { $0.id == city.id } ) {
                    region.cities.append(city)
                }
                updateRegionCountry(decodedCountry: decodedRegion.country, for: region, modelContext: modelContext)
            } else {
                let region = Region(decodedRegion: decodedRegion)
                modelContext.insert(region)
                city.region = region
                region.cities.append(city)
                updateRegionCountry(decodedCountry: decodedRegion.country, for: region, modelContext: modelContext)
            }
        } catch {
            debugPrint(error)
        }
    }
    
    private func updateRegionCountry(decodedCountry: DecodedCountry?, for region: Region, modelContext: ModelContext) {
        guard let decodedCountry else { return }
        do {
            let countryDescriptor = FetchDescriptor<Country>()
            let allCountries = try modelContext.fetch(countryDescriptor)
            
            if let country = allCountries.first(where: { $0.id == decodedCountry.id} ) {
                country.updateCountryIncomplete(decodedCountry: decodedCountry)
                region.country = country
                if !country.regions.contains(where: { $0.id == region.id } ) {
                    country.regions.append(region)
                }
            } else {
                let country = Country(decodedCountry: decodedCountry)
                modelContext.insert(country)
                region.country = country
                country.regions.append(region)
            }
        } catch {
            debugPrint(error)
        }
    }
}
