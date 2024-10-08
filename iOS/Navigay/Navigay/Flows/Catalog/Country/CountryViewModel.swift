//
//  CountryViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import SwiftUI
import SwiftData

struct CountryRegion: Identifiable {
    let id: Int
    let region: Region
    let cities: [City]
}

extension CountryView {
    @Observable
    class CountryViewModel {
        
        var modelContext: ModelContext
        let country: Country
        var regions: [CountryRegion] = []
        
        let catalogNetworkManager: CatalogNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let catalogDataManager: CatalogDataManagerProtocol
        let commentsNetworkManager: CommentsNetworkManagerProtocol
        let notificationsManager: NotificationsManagerProtocol
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
             catalogDataManager: CatalogDataManagerProtocol,
             commentsNetworkManager: CommentsNetworkManagerProtocol,
             notificationsManager: NotificationsManagerProtocol) {
            self.modelContext = modelContext
            self.country = country
            self.catalogNetworkManager = catalogNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
            self.catalogDataManager = catalogDataManager
            self.commentsNetworkManager = commentsNetworkManager
            self.notificationsManager = notificationsManager
            country.regions.forEach( { regions.append(CountryRegion(id: $0.id, region: $0, cities: $0.cities)) })
        }
        
        func fetch() {
            Task {
                guard !catalogDataManager.loadedCountries.contains(where: { $0.id == country.id}) else {
                    return
                }
                do {
                    let decodedCountry = try await catalogNetworkManager.fetchCountry(id: country.id)
                    await MainActor.run {
                        updateCountry(decodedCountry: decodedCountry)
                    }
                    catalogDataManager.addLoadedCountry(country)
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
            catalogDataManager.updateRegions(decodedRegions: decodedCountry.regions, country: country, modelContext: modelContext)
            // todo удалять красиво!
            regions = []
            country.regions.forEach( { regions.append(CountryRegion(id: $0.id, region: $0, cities: $0.cities)) })
           // try? modelContext.save()
        }
    }
}
