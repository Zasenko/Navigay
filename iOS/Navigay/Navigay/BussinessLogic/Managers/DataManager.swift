////
////  DataManager.swift
////  Navigay
////
////  Created by Dmitry Zasenko on 04.01.24.
////
//
//import Foundation
//import SwiftData
//
//final class DataManager {
//    
//    var allRegions: [Region] = []
//    var allCountries: [Country] = []
//    
//    init(modelContext: ModelContext) {
//        do {
//            let regionDescriptor = FetchDescriptor<Region>()
//            allRegions = try modelContext.fetch(regionDescriptor)
//            
//            let countryDescriptor = FetchDescriptor<Country>()
//            allCountries = try modelContext.fetch(countryDescriptor)
//        } catch {
//            debugPrint(error)
//        }
//        
//    }
//    func updateCountry() {
//        
//    }
//    
//    private func updateSearchedRegions(decodedRegions: [DecodedRegion]?) -> [Region] {
//        guard let decodedRegions, !decodedRegions.isEmpty else {
//            return
//        }
//        do {
//            var regions: [Region] = []
//            for decodedRegion in decodedRegions {
//                if let region = allRegions.first(where: { $0.id == decodedRegion.id} ) {
//                    region.updateIncomplete(decodedRegion: decodedRegion)
//                    updateCities(decodedCities: decodedRegion.cities, for: region)
//                    regions.append(region)
//                } else if decodedRegion.isActive {
//                    let region = Region(decodedRegion: decodedRegion)
//                    if let decodedCountry = decodedRegion.country,
//                       let country = allCountries.first(where: { $0.id == decodedCountry.id} ) {
//                        country.regions.append(region)
//                        region.country = country
//                    }
//                    updateCities(decodedCities: decodedRegion.cities, for: region)
//                    regions.append(region)
//                }
//            }
//            searchRegions = regions
//        } catch {
//            debugPrint(error)
//        }
//    }
//    
//    func updateRegion(decodedRegions: DecodedRegion, for country: Country) {
//        
//    }
//    
//    func updateCity(decodedCity: DecodedCity, for region: DecodedRegion) {
//        
//    }
//    
//    
//    
//}
