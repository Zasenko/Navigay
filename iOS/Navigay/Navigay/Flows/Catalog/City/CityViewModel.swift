//
//  CityViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import SwiftUI
import SwiftData

extension CityView {
    @Observable
    class CityViewModel {
        
        var modelContext: ModelContext
        
        let city: City
        var isLoading: Bool = false
        
        var allPhotos: [String] = []
        
        var aroundPlaces: [Place] = [] /// for Map
        var groupedPlaces: [PlaceType: [Place]] = [:]
        
        var actualEvents: [Event] = []
        var todayEvents: [Event] = []
        var upcomingEvents: [Event] = []
        var displayedEvents: [Event] = []
        
        var showCalendar: Bool = false
        var eventsDates: [Date] = []
        var selectedDate: Date? = nil
        
        var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
        
        var sortingHomeCategories: [SortingCategory] = []
        var selectedHomeSortingCategory: SortingCategory = .all
        
        var showMap: Bool = false
        var sortingMapCategories: [SortingCategory] = []
        var selectedMapSortingCategory: SortingCategory = .all
        
        let catalogNetworkManager: CatalogNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let catalogDataManager: CatalogDataManagerProtocol
        
       // var adminCity: AdminCity? = nil
        
        init(modelContext: ModelContext,
             city: City,
             catalogNetworkManager: CatalogNetworkManagerProtocol,
             placeNetworkManager: PlaceNetworkManagerProtocol,
             eventNetworkManager: EventNetworkManagerProtocol,
             errorManager: ErrorManagerProtocol,
             placeDataManager: PlaceDataManagerProtocol,
             eventDataManager: EventDataManagerProtocol,
             catalogDataManager: CatalogDataManagerProtocol) {
            self.modelContext = modelContext
            self.city = city
            self.catalogNetworkManager = catalogNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
            self.catalogDataManager = catalogDataManager
            
            let newPhotosLinks = city.getAllPhotos()
            allPhotos = newPhotosLinks
        }
        
        func getPlacesAndEventsFromDB() {
            if city.lastUpdateComplite == nil {
                isLoading = true
                Task {
                    await fetch()
                }
            } else {
                Task {
                    let places = city.places.sorted(by: { $0.name < $1.name })
                    let events = city.events.sorted(by: { $0.id < $1.id })
                    
                    let groupedPlaces = await placeDataManager.createGroupedPlaces(places: places)
                    
                    let actualEvents = await self.eventDataManager.getActualEvents(for: events)
                    let todayEvents = await eventDataManager.getTodayEvents(from: actualEvents)
                    let upcomingEvents = await eventDataManager.getUpcomingEvents(from: actualEvents)
                    let eventsDatesWithoutToday = await eventDataManager.getActiveDates(for: actualEvents)
                    
                    await MainActor.run {
                        self.actualEvents = actualEvents
                        self.upcomingEvents = upcomingEvents
                        self.aroundPlaces = aroundPlaces
                        self.eventsDates = eventsDatesWithoutToday
                        self.todayEvents = todayEvents
                        self.displayedEvents = upcomingEvents
                        self.groupedPlaces = groupedPlaces
                    }
                    await fetch()
                }
            }
        }
        
        func showUpcomingEvents() {
            self.displayedEvents = upcomingEvents
        }
        
        private func fetch() async {
            guard !catalogNetworkManager.loadedCities.contains(where: { $0 == city.id}) else {
                return
            }
            await MainActor.run {
                isLoading = true
            }
            do {
                let decodedCity = try await catalogNetworkManager.fetchCity(id: city.id)
                await MainActor.run {
                    updateFetchedResult(decodedCity: decodedCity)
                }
            } catch NetworkErrors.noConnection {
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
            } catch {
                errorManager.showUpdateError(error: error)
            }
            await MainActor.run {
                isLoading = false
            }
        }
        private func updateFetchedResult(decodedCity: DecodedCity) {
            
            city.updateCityComplite(decodedCity: decodedCity)
            let newPhotosLinks = city.getAllPhotos()
            for link in newPhotosLinks {
                if !allPhotos.contains(where:  { $0 == link } ) {
                    allPhotos.append(link)
                }
            }
            let places = placeDataManager.updatePlaces(decodedPlaces: decodedCity.places, for: city, modelContext: modelContext)
            let events = eventDataManager.updateEvents(decodedEvents: decodedCity.events, for: city, modelContext: modelContext)
            Task {
                let groupedPlaces = await placeDataManager.createGroupedPlaces(places: places.sorted(by: { $0.name < $1.name}))
                let actualEvents = await eventDataManager.getActualEvents(for: events.sorted(by: { $0.id < $1.id}))
                let todayEvents = await eventDataManager.getTodayEvents(from: actualEvents)
                let upcomingEvents = await eventDataManager.getUpcomingEvents(from: actualEvents)
                let eventsDatesWithoutToday = await eventDataManager.getActiveDates(for: actualEvents)
                
                let eventsIDs = actualEvents.map( { $0.id } )
                var eventsToDelete: [Event] = []
                self.actualEvents.forEach { event in
                    if !eventsIDs.contains(event.id) {
                        eventsToDelete.append(event)
                    }
                }
                
                let placesIDs = aroundPlaces.map( { $0.id } )
                var placesToDelete: [Place] = []
                self.aroundPlaces.forEach { place in
                    if !placesIDs.contains(place.id) {
                        placesToDelete.append(place)
                    }
                }
                
                await MainActor.run { [eventsToDelete, placesToDelete] in
                    eventsToDelete.forEach( { modelContext.delete($0) } )
                    placesToDelete.forEach( { modelContext.delete($0) } )
                    self.actualEvents = actualEvents
                    self.upcomingEvents = upcomingEvents
                    self.aroundPlaces = places
                    self.eventsDates = eventsDatesWithoutToday
                    self.todayEvents = todayEvents
                    self.displayedEvents = upcomingEvents
                    self.groupedPlaces = groupedPlaces
                    isLoading = false
                }
            }
        }
        
//        func getEvents(for date: Date) {
//            Task {
//                let events = await eventDataManager.getEvents(for: date, events: actualEvents )
//                await MainActor.run {
//                    displayedEvents = events
//                }
//            }
//        }
    }
}
