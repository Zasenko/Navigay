//
//  CatalogDataManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.01.24.
//

import Foundation
import SwiftData
import CoreLocation

protocol CatalogDataManagerProtocol {
    
    var isCountriesLoaded: Bool { get }
    var loadedCountries: [Country] { get }
    var loadedCities: [City:CityItems] { get }
    
    func changeCountriesLoadStatus()
    func addLoadedCountry(_ country: Country)
    func addLoadedCity(_ city: City, with items: CityItems)

    
    /// return  -> sorted by name
    func getAllCountries(modelContext: ModelContext) -> [Country]
    
    /// return  -> sorted by id
    func getAllRegions(modelContext: ModelContext) -> [Region]
    
    /// return  -> sorted by name
    func getAllCities(modelContext: ModelContext) -> [City]
    
    ///return  ->  filtered by distance
    func getCitiesAround(count: Int, userLocation: CLLocation, modelContext: ModelContext) -> [City]
    
    /// return ->  sorted by name
    func updateCountries(decodedCountries: [DecodedCountry]?, modelContext: ModelContext) -> [Country]
    
    /// return  -> sorted by id
    func updateRegions(decodedRegions: [DecodedRegion]?, modelContext: ModelContext) -> [Region]
    
    /// return  -> sorted by name
    func updateCities(decodedCities: [DecodedCity]?, modelContext: ModelContext) -> [City]
   
    func updateRegions(decodedRegions: [DecodedRegion]?, countries: [Country], modelContext: ModelContext) -> [Region]
    
    func updateCities(decodedCities: [DecodedCity]?, regions: [Region], modelContext: ModelContext) -> [City]
    
    func updateRegions(decodedRegions: [DecodedRegion]?, country: Country, modelContext: ModelContext)
    
    func updateCities(decodedCities: [DecodedCity]?, region: Region, modelContext: ModelContext)
}

final class CatalogDataManager: CatalogDataManagerProtocol {
    
    // MARK: - Properties
    
    var isCountriesLoaded: Bool = false
    var loadedCountries: [Country] = []
    var loadedCities: [City:CityItems] = [:]
}

extension CatalogDataManager {
    
    func changeCountriesLoadStatus() {
        isCountriesLoaded = true
    }
    
    func addLoadedCountry(_ country: Country) {
        loadedCountries.append(country)
    }
    func addLoadedCity(_ city: City, with items: CityItems) {
        loadedCities[city] = items
    }
    
    func getAllCountries(modelContext: ModelContext) -> [Country] {
        do {
            let descriptor = FetchDescriptor<Country>(sortBy: [SortDescriptor(\.name)])
            return try modelContext.fetch(descriptor)
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func getAllRegions(modelContext: ModelContext) -> [Region] {
        do {
            let descriptor = FetchDescriptor<Region>(sortBy: [SortDescriptor(\.id)])
            return try modelContext.fetch(descriptor)
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func getAllCities(modelContext: ModelContext) -> [City] {
        do {
            let descriptor = FetchDescriptor<City>(sortBy: [SortDescriptor(\.name)])
            return try modelContext.fetch(descriptor)
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func getCitiesAround(count: Int, userLocation: CLLocation, modelContext: ModelContext) -> [City] {
        let allCities = getAllCities(modelContext: modelContext)
        let sortedCities = allCities.sorted(by: {  userLocation.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude)) < userLocation.distance(from: CLLocation(latitude: $1.latitude, longitude: $1.longitude)) })
            
        return Array(sortedCities.prefix(count))
    }
    
    //ok
    func updateCountries(decodedCountries: [DecodedCountry]?, modelContext: ModelContext) -> [Country] {
        guard let decodedCountries, !decodedCountries.isEmpty else {
            return []
        }
        do {
            var allCountries = getAllCountries(modelContext: modelContext)
            var countries: [Country] = []
            for decodedCountry in decodedCountries {
                if let country = allCountries.first(where: { $0.id == decodedCountry.id} ) {
                    country.updateCountryIncomplete(decodedCountry: decodedCountry)
                    countries.append(country)
                } else {
                    let country = Country(decodedCountry: decodedCountry)
                    modelContext.insert(country)
                    allCountries.append(country)
                    countries.append(country)
                }
            }
            try modelContext.save()
            return countries.sorted(by: { $0.name < $1.name})
        } catch {
            debugPrint(error)
            return []
        }
    }

    func updateRegions(decodedRegions: [DecodedRegion]?, modelContext: ModelContext) -> [Region] {
        guard let decodedRegions, !decodedRegions.isEmpty else {
            return []
        }
        do {
            let allRegions = getAllRegions(modelContext: modelContext)
            var regions: [Region] = []
            for decodedRegion in decodedRegions {
                if let region = allRegions.first(where: { $0.id == decodedRegion.id} ) {
                    region.updateIncomplete(decodedRegion: decodedRegion)
                    updateCities(decodedCities: decodedRegion.cities, region: region, modelContext: modelContext)
                    regions.append(region)
                } else {
                    let region = Region(decodedRegion: decodedRegion)
                    modelContext.insert(region)
                    updateCities(decodedCities: decodedRegion.cities, region: region, modelContext: modelContext)
                    regions.append(region)
                }
            }
            try modelContext.save()
            return regions.sorted(by: { $0.id < $1.id})
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func updateCities(decodedCities: [DecodedCity]?, modelContext: ModelContext) -> [City] {
        guard let decodedCities, !decodedCities.isEmpty else {
            return []
        }
        do {
            let allCities = getAllCities(modelContext: modelContext)
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
            try modelContext.save()
            return cities.sorted(by: { $0.name < $1.name})
        } catch {
            debugPrint(error)
            return []
        }
    }
        
    func updateRegions(decodedRegions: [DecodedRegion]?, countries: [Country], modelContext: ModelContext) -> [Region] {
        guard let decodedRegions, !decodedRegions.isEmpty else {
            return []
        }
        do {
            let allRegions = getAllRegions(modelContext: modelContext)
            var regions: [Region] = []
            for decodedRegion in decodedRegions {
                if let region = allRegions.first(where: { $0.id == decodedRegion.id} ) {
                    region.updateIncomplete(decodedRegion: decodedRegion)
                    if let country = countries.first(where: { $0.id == decodedRegion.countryId}) {
                        region.country = country
                        if !country.regions.contains(where: { $0.id == region.id} ) {
                            country.regions.append(region)
                        }
                    }
                    regions.append(region)
                } else {
                    let region = Region(decodedRegion: decodedRegion)
                    modelContext.insert(region)
                    if let country = countries.first(where: { $0.id == decodedRegion.countryId}) {
                        region.country = country
                        country.regions.append(region)
                    }
                    regions.append(region)
                }
            }
            try modelContext.save()
            return regions.sorted(by: { $0.id < $1.id})
        } catch {
            debugPrint(error)
            return []
        }
//
//        for decodedCity in decodedCities {
//
//            if let city = region.cities.first(where: { $0.id == decodedCity.id} ) {
//                city.updateCityIncomplete(decodedCity: decodedCity)
//            } else {
//                let city = City(decodedCity: decodedCity)
//                region.cities.append(city)
//                city.region = region
//            }
//        }

    }
    
    func updateCities(decodedCities: [DecodedCity]?, regions: [Region], modelContext: ModelContext) -> [City] {
        guard let decodedCities, !decodedCities.isEmpty else {
            return []
        }
        do {
            let allCities = getAllCities(modelContext: modelContext)
            var cities: [City] = []
            for decodedCity in decodedCities {
                if let city = allCities.first(where: { $0.id == decodedCity.id} ) {
                    city.updateCityIncomplete(decodedCity: decodedCity)
                    if let region = regions.first(where: { $0.id == decodedCity.regionId}) {
                        city.region = region
                        if !region.cities.contains(where: { $0.id == city.id} ) {
                            region.cities.append(city)
                        }
                    }
                    cities.append(city)
                } else {
                    let city = City(decodedCity: decodedCity)
                    modelContext.insert(city)
                    if let region = regions.first(where: { $0.id == decodedCity.regionId}) {
                        city.region = region
                        region.cities.append(city)
                    }
                    cities.append(city)
                }
            }
            try modelContext.save()
            return cities.sorted(by: { $0.name < $1.name})
        } catch {
            debugPrint(error)
            return []
        }
//
//        for decodedCity in decodedCities {
//            
//            if let city = region.cities.first(where: { $0.id == decodedCity.id} ) {
//                city.updateCityIncomplete(decodedCity: decodedCity)
//            } else {
//                let city = City(decodedCity: decodedCity)
//                region.cities.append(city)
//                city.region = region
//            }
//        }

    }
    
    //OK
    func updateRegions(decodedRegions: [DecodedRegion]?, country: Country, modelContext: ModelContext) {
        let regions = updateRegions(decodedRegions: decodedRegions, modelContext: modelContext)
        guard !regions.isEmpty else {
            let regionsToDelete = country.regions
            country.regions = []
            regionsToDelete.forEach( { modelContext.delete($0) } )
            return
        }
        let ids = regions.map( { $0.id } )
        var regionsToDelete: [Region] = []
        country.regions.forEach { region in
            if !ids.contains(region.id) {
                regionsToDelete.append(region)
            }
        }
        regions.forEach( { $0.country = country } )
        country.regions = regions
        regionsToDelete.forEach( { modelContext.delete($0) } )
    }
    
    //OK
    func updateCities(decodedCities: [DecodedCity]?, region: Region, modelContext: ModelContext) {
        let cities = updateCities(decodedCities: decodedCities, modelContext: modelContext)
        guard !cities.isEmpty else {
            let citiesToDelete = region.cities
            region.cities = []
            citiesToDelete.forEach( { modelContext.delete($0) } )
            return
        }
        let ids = cities.map( { $0.id } )
        var citiesToDelete: [City] = []
        region.cities.forEach { city in
            if !ids.contains(city.id) {
                citiesToDelete.append(city)
            }
        }
        cities.forEach( { $0.region = region } )
        region.cities = cities
        citiesToDelete.forEach( { modelContext.delete($0) } )
    }
    
     func updateCityRegion(decodedRegion: DecodedRegion?, for city: City, modelContext: ModelContext) {
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
