//
//  HomeViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 28.11.23.
//

import SwiftUI
import SwiftData
import CoreLocation

extension HomeView {
    
    @Observable
    class HomeViewModel {
        
        //MARK: - Properties
        
        var modelContext: ModelContext
        
        var actualEvents: [Event] = []
        var todayEvents: [Event] = []
        var upcomingEvents: [Event] = []
        var displayedEvents: [Event] = []
        
        var showCalendar: Bool = false
        var eventsDates: [Date] = []
        var selectedDate: Date? = nil
        
        var selectedEvent: Event?
        
        var aroundPlaces: [Place] = [] /// for Map
        var groupedPlaces: [PlaceType: [Place]] = [:]
        
        var isLoading: Bool = true
        var isLocationsAround20Found: Bool = true
        
        var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
        var showMap: Bool = false
        
        var sortingHomeCategories: [SortingCategory] = []
        var selectedHomeSortingCategory: SortingCategory = .all
        
        var sortingMapCategories: [SortingCategory] = []
        
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let catalogDataManager: CatalogDataManagerProtocol
        
        let aroundNetworkManager: AroundNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        
        //MARK: - Init
        
        init(modelContext: ModelContext,
             aroundNetworkManager: AroundNetworkManagerProtocol,
             placeNetworkManager: PlaceNetworkManagerProtocol,
             eventNetworkManager: EventNetworkManagerProtocol,
             errorManager: ErrorManagerProtocol,
             placeDataManager: PlaceDataManagerProtocol,
             eventDataManager: EventDataManagerProtocol,
             catalogDataManager: CatalogDataManagerProtocol) {
            self.modelContext = modelContext
            self.aroundNetworkManager = aroundNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
            self.catalogDataManager = catalogDataManager
        }
        
        //MARK: - Functions
        
        func updateAroundPlacesAndEvents(userLocation: CLLocation) {
            let radius: Double = 20000
            
            let allPlaces = placeDataManager.getAllPlaces(modelContext: modelContext)
            let allEvents = eventDataManager.getAllEvents(modelContext: modelContext)
            
            Task {
                let aroundPlaces = await placeDataManager.getAroundPlaces(radius: radius, allPlaces: allPlaces, userLocation: userLocation)
                let aroundEvents = await eventDataManager.getAroundEvents(radius: radius, allEvents: allEvents, userLocation: userLocation)
                
                let groupedPlaces = await placeDataManager.createGroupedPlaces(places: aroundPlaces)
                let actualEvents = await eventDataManager.getActualEvents(for: aroundEvents)
                let todayEvents = await eventDataManager.getTodayEvents(from: actualEvents)
                let upcomingEvents = await eventDataManager.getUpcomingEvents(from: actualEvents)
                let eventsDatesWithoutToday = await eventDataManager.getActiveDates(for: actualEvents)
                
                await MainActor.run {
                    self.actualEvents = actualEvents
                    self.upcomingEvents = upcomingEvents
                    self.aroundPlaces = aroundPlaces
                    self.eventsDates = eventsDatesWithoutToday
                    aroundPlaces.forEach { place in
                        let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                        place.getDistanceText(distance: distance, inKm: true)
                    }
                    self.todayEvents = todayEvents
                    self.displayedEvents = upcomingEvents
                    self.groupedPlaces = groupedPlaces
                    if !aroundPlaces.isEmpty && !aroundEvents.isEmpty {
                        isLoading = false
                    }
                }
                
                if !aroundNetworkManager.userLocations.contains(where: { $0 == userLocation }) {
                    await fetch(location: userLocation)
                } else {
                    if isLoading {
                        let closestPlaces = await placeDataManager.getClosestPlaces(from: allPlaces, userLocation: userLocation, count: 5)
                        let groupedClosestPlaces = await placeDataManager.createGroupedPlaces(places: closestPlaces)
                        await MainActor.run {
                            closestPlaces.forEach { place in
                                let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                                place.getDistanceText(distance: distance, inKm: true)
                            }
                            self.groupedPlaces = groupedClosestPlaces
                            self.isLocationsAround20Found = false
                            self.isLoading = false
                        }
                    }
                }
                await updateSortingMapCategories()
            }
        }
        
        //MARK: - Private Functions
        
        private func fetch(location: CLLocation) async {
            let message = "Something went wrong. The information didn't update. Please try again later."
            do {
                let decodedResult = try await aroundNetworkManager.fetchLocations(location: location)
                await MainActor.run {
                    if decodedResult.foundAround {
                        isLocationsAround20Found = true
                    } else {
                        isLocationsAround20Found = false
                    }
                    let cities = catalogDataManager.updateCities(decodedCities: decodedResult.cities, modelContext: modelContext)
                    let places = placeDataManager.updatePlaces(decodedPlaces: decodedResult.places, for: cities, modelContext: modelContext)
                    let events = eventDataManager.updateEvents(decodedEvents: decodedResult.events, for: cities, modelContext: modelContext)
                    places.forEach { place in
                        let distance = location.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                        place.getDistanceText(distance: distance, inKm: true)
                    }
                    updateFetchedResult(places: places.sorted(by: { $0.name < $1.name }), events: events.sorted(by: { $0.id < $1.id }), userLocation: location)
                }
            } catch NetworkErrors.apiError(let error) {
                if let error, error.show {
                    errorManager.showError(model: ErrorModel(error: NetworkErrors.api, message: error.message))
                } else {
                    errorManager.showError(model: ErrorModel(error: NetworkErrors.api, message: message))
                }
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: message))
            }
        }
        
        private func updateFetchedResult(places: [Place], events: [Event], userLocation: CLLocation) {
            Task {
                let groupedPlaces = await placeDataManager.createGroupedPlaces(places: places)
                let actualEvents = await eventDataManager.getActualEvents(for: events)
                let todayEvents = await eventDataManager.getTodayEvents(from: events)
                let upcomingEvents = await eventDataManager.getUpcomingEvents(from: events)
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
                    places.forEach { place in
                        let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                        place.getDistanceText(distance: distance, inKm: true)
                    }
                        self.todayEvents = todayEvents
                        self.displayedEvents = upcomingEvents
                        self.groupedPlaces = groupedPlaces
                        isLoading = false
                }
            }
        }
  
        private func updateSortingMapCategories() async {
            var mapCategories: [SortingCategory] = []
            var homeCategories: [SortingCategory] = []
            
            if actualEvents.count > 0 {
                homeCategories.append(.events)
            }
            let placesTypes = groupedPlaces.keys.compactMap( { SortingCategory(placeType: $0)} )
            placesTypes.forEach { mapCategories.append($0) }
            placesTypes.forEach { homeCategories.append($0) }
            if !todayEvents.isEmpty {
                mapCategories.append(.events)
            }
            if mapCategories.count > 1 {
                mapCategories.append(.all)
            }
            await MainActor.run { [mapCategories, homeCategories] in
                withAnimation {
                    sortingMapCategories = mapCategories.sorted(by: {$0.getSortPreority() < $1.getSortPreority()})
                    sortingHomeCategories = homeCategories.sorted(by: {$0.getSortPreority() < $1.getSortPreority()})
                }
            }
        }
    }
}
