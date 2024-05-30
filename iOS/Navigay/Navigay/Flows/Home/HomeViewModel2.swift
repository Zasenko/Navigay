//
//  HomeViewModel2.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 30.05.24.
//

import SwiftUI
import CoreLocation
import SwiftData

extension HomeView2 {
    
    @Observable
    class HomeViewModel2 {
        
        //MARK: - Properties
        
        var modelContext: ModelContext
        
        var actualEvents: [Event] = []  // delete
        var todayEvents: [Event] = []
        var upcomingEvents: [Event] = []
        var displayedEvents: [Event] = []
        var eventsCount: Int = 0
        
        var showCalendar: Bool = false
        var eventsDates: [Date] = []
        var selectedDate: Date? = nil
        var dateEvents: [Date: [Int]] = [:]
        var selectedEvent: Event?
        
        
        var aroundPlaces: [Place] = [] /// for Map
        var groupedPlaces: [SortingCategory: [Place]] = [:]
        
        var locationUpdatedAtInit: Bool = false
        var isLoading: Bool = true
        var isLocationsAround20Found: Bool = true
        var citiesAround: [City] = []
        
        var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
        var showMap: Bool = false
        
        var sortingHomeCategories: [SortingCategory] = []
        var selectedHomeSortingCategory: SortingCategory = .all
        
        var sortingMapCategories: [SortingCategory] = []
        
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let catalogDataManager: CatalogDataManagerProtocol
        
    let catalogNetworkManager: CatalogNetworkManagerProtocol

        let aroundNetworkManager: AroundNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        
        //MARK: - Init
        
        init(modelContext: ModelContext,
             aroundNetworkManager: AroundNetworkManagerProtocol,
             placeNetworkManager: PlaceNetworkManagerProtocol,
             eventNetworkManager: EventNetworkManagerProtocol,
             catalogNetworkManager: CatalogNetworkManagerProtocol,
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
            self.catalogNetworkManager = catalogNetworkManager
        }
        
        //MARK: - Functions
        
//        func updateAroundPlacesAndEvents(userLocation: CLLocation) {
//            Task {
//                let radius: Double = 20000
//
//                let allPlaces = placeDataManager.getAllPlaces(modelContext: modelContext)
//                let allEvents = eventDataManager.getAllEvents(modelContext: modelContext)
//
//                let aroundPlaces = await placeDataManager.getAroundPlaces(radius: radius, allPlaces: allPlaces, userLocation: userLocation)
//                let aroundEvents = await eventDataManager.getAroundEvents(radius: radius, allEvents: allEvents, userLocation: userLocation)
//
//                let groupedPlaces = await placeDataManager.createHomeGroupedPlaces(places: aroundPlaces)
//                let actualEvents = await eventDataManager.getActualEvents(for: aroundEvents)
//                let todayEvents = await eventDataManager.getTodayEvents(from: actualEvents)
//                let upcomingEvents = await eventDataManager.getUpcomingEvents(from: actualEvents)
//                let eventsDatesWithoutToday = await eventDataManager.getActiveDates(for: actualEvents)
//
//                await MainActor.run {
//                    self.actualEvents = actualEvents
//                    self.upcomingEvents = upcomingEvents
//                    self.aroundPlaces = aroundPlaces
//                    self.eventsDates = eventsDatesWithoutToday
//                    aroundPlaces.forEach { place in
//                        let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
//                        place.getDistanceText(distance: distance, inKm: true)
//                    }
//                    self.todayEvents = todayEvents
//                    self.displayedEvents = upcomingEvents
//                    self.eventsCount = actualEvents.count
//                    self.groupedPlaces = groupedPlaces
//
//                   // self.dateEvents =
//                    if !aroundPlaces.isEmpty && !aroundEvents.isEmpty {
//                        isLoading = false
//                    }
//                }
//
//                if !aroundNetworkManager.userLocations.contains(where: { $0 == userLocation }) {
//                    await fetch(location: userLocation)
//                } else {
//                    if isLoading {
//                        let closestPlaces = await placeDataManager.getClosestPlaces(from: allPlaces, userLocation: userLocation, count: 5)
//                     //   let groupedClosestPlaces = await placeDataManager.createGroupedPlaces(places: closestPlaces)
//                        await MainActor.run {
//                            closestPlaces.forEach { place in
//                                let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
//                                place.getDistanceText(distance: distance, inKm: true)
//                            }
//                     //       self.groupedPlaces = groupedClosestPlaces
//                            self.isLocationsAround20Found = false
//                            self.isLoading = false
//                        }
//                    }
//                }
//                await updateSortingMapCategories()
//            }
//        }
        
        func updateAtInit(userLocation: CLLocation) {
            if !locationUpdatedAtInit {
                update(userLocation: userLocation)
                locationUpdatedAtInit = true
            }
        }
//
        func update(userLocation: CLLocation) {
            Task {
                let radius: Double = 20000
                
                let allPlaces = placeDataManager.getAllPlaces(modelContext: modelContext)
                let allEvents = eventDataManager.getAllEvents(modelContext: modelContext)
                
                let aroundPlaces = await placeDataManager.getAroundPlaces(radius: radius, allPlaces: allPlaces, userLocation: userLocation)
                let aroundEvents = await eventDataManager.getAroundEvents(radius: radius, allEvents: allEvents, userLocation: userLocation)
                
                if aroundPlaces.count > 0 || aroundEvents.count > 0 {
                    let groupedPlaces = await placeDataManager.createHomeGroupedPlaces(places: aroundPlaces)
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
                        self.eventsCount = actualEvents.count
                        self.groupedPlaces = groupedPlaces
                        if !aroundPlaces.isEmpty || !aroundEvents.isEmpty {
                            isLoading = false
                        }
                    }
                    await updateSortingMapCategories()
                }
                
                if !aroundNetworkManager.userLocations.contains(where: { $0 == userLocation }) {
                    await fetch(userLocation: userLocation)
                } else {
                    if isLoading {
                     //   let closestPlaces = await placeDataManager.getClosestPlaces(from: allPlaces, userLocation: userLocation, count: 5)
                     //   let groupedClosestPlaces = await placeDataManager.createGroupedPlaces(places: closestPlaces)
                        let cities = await catalogDataManager.getCitiesAround(count: 3, userLocation: userLocation, modelContext: modelContext)
                        await MainActor.run {
//                            closestPlaces.forEach { place in
//                                let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
//                                place.getDistanceText(distance: distance, inKm: true)
//                            }
                     //       self.groupedPlaces = groupedClosestPlaces
                            self.citiesAround = cities
                            self.isLocationsAround20Found = false
                            self.isLoading = false
                        }
                    }
                }
            }
        }
        
        
        //MARK: - Private Functions
        
//        func fetchTest() async {
//
//                    let url = Bundle.main.url(forResource: "aroundjson",
//                                                    withExtension: "json")
//                    let data = try? Data(contentsOf: url!)
//
//                    let decoder  = JSONDecoder()
//
//                    let result = try? decoder.decode(AroundResultNew.self, from: data!)
//            let decodedResult = result!.items!
//
//            print(decodedResult)
//            await MainActor.run {
//                if decodedResult.foundAround {
//                    isLocationsAround20Found = true
//                    let cities = catalogDataManager.updateCities(decodedCities: decodedResult.cities, modelContext: modelContext)
//                    let places = placeDataManager.updatePlaces(decodedPlaces: decodedResult.places, for: cities, modelContext: modelContext)
//                    let eventsItems = eventDataManager.updateEvents(decodedEvents: decodedResult.events, for: cities, modelContext: modelContext)
////                    places.forEach { place in
////                        let distance = location.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
////                        place.getDistanceText(distance: distance, inKm: true)
////                    }
//                    let location = CLLocation(latitude: 48.257790, longitude: 16.445837)
//                    updateFetchedResult(places: places.sorted(by: { $0.name < $1.name }), events: eventsItems, userLocation: location)
//                } else {
//                    isLocationsAround20Found = false
//                    self.isLoading = false
//                }
//            }
//
//        }
        
        private func fetch(userLocation: CLLocation) async {
            print("fetch locations, userLocation: ", userLocation)
            let message = "Something went wrong. The information didn't update. Please try again later."
            do {
                let decodedResult = try await aroundNetworkManager.fetchAround(location: userLocation)
                await MainActor.run {
                    if decodedResult.foundAround {
                        isLocationsAround20Found = true
                        let countries = catalogDataManager.updateCountries(decodedCountries: decodedResult.countries, modelContext: modelContext)
                        let regions = catalogDataManager.updateRegions(decodedRegions: decodedResult.regions, countries: countries, modelContext: modelContext)
                        let cities = catalogDataManager.updateCities(decodedCities: decodedResult.cities, regions: regions, modelContext: modelContext)
                        let places = placeDataManager.updatePlaces(decodedPlaces: decodedResult.places, for: cities, modelContext: modelContext)
                        let eventsItems = eventDataManager.updateEvents(decodedEvents: decodedResult.events, for: cities, modelContext: modelContext)
                        places.forEach { place in
                            let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                            place.getDistanceText(distance: distance, inKm: true)
                        }
                        updateFetchedResult(places: places.sorted(by: { $0.name < $1.name }), events: eventsItems, userLocation: userLocation)
                        self.isLoading = false
                    } else {
                        isLocationsAround20Found = false
                        
                        let countries = catalogDataManager.updateCountries(decodedCountries: decodedResult.countries, modelContext: modelContext)
                        let regions = catalogDataManager.updateRegions(decodedRegions: decodedResult.regions, countries: countries, modelContext: modelContext)
                        let cities = catalogDataManager.updateCities(decodedCities: decodedResult.cities, regions: regions, modelContext: modelContext)
                        self.citiesAround = cities
                        self.isLoading = false
                    }
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
            
            if isLoading {
                let cities = await catalogDataManager.getCitiesAround(count: 3, userLocation: userLocation, modelContext: modelContext)
                await MainActor.run {
//                            closestPlaces.forEach { place in
//                                let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
//                                place.getDistanceText(distance: distance, inKm: true)
//                            }
             //       self.groupedPlaces = groupedClosestPlaces
                    self.citiesAround = cities
                    self.isLocationsAround20Found = false
                    self.isLoading = false
                }
            }
        }
        
        func updateEvents(for date: Date, userLocation: CLLocation) {
            Task {
                let events = await eventDataManager.getEvents(for: date, userLocation: userLocation, modelContext: modelContext)
                await MainActor.run {
                    displayedEvents = events
                }
                await fetchEvents(for: date)
            }
        }
        
        private func fetchEvents(for date: Date) async {
            let ids = dateEvents.filter { $0.key == date }.flatMap { $0.value.map { $0 } }
           
            var savedEvents: [Event] = []
            var newIds: [Int] = []
            
            ids.forEach { id in
                if eventNetworkManager.loadedCalendarEventsId.contains(where: { $0 == id }) {
                    if let event = eventDataManager.getEvent(id: id, modelContext: modelContext) {
                        savedEvents.append(event)
                    } else {
                        newIds.append(id)
                    }
                } else {
                    newIds.append(id)
                }
            }
            guard !newIds.isEmpty else { return }
            
            let message = "Something went wrong. The information didn't update. Please try again later."
            do {
                let (decodedEvents, decodedCities) = try await eventNetworkManager.fetchEvents(ids: newIds)
                await MainActor.run { [savedEvents] in
                    let cities = catalogDataManager.updateCities(decodedCities: decodedCities, modelContext: modelContext)
                    var events = eventDataManager.updateEvents(decodedEvents: decodedEvents, for: cities, modelContext: modelContext)
                    events.append(contentsOf: savedEvents)
                    self.displayedEvents = events
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
        
        private func updateFetchedResult(places: [Place], events: EventsItems, userLocation: CLLocation) {
            Task {
                let groupedPlaces = await placeDataManager.createHomeGroupedPlaces(places: places)
                let tEvents = events.today.sorted(by: { $0.id < $1.id })
                let uEvents = events.upcoming.sorted(by: { $0.id < $1.id }).sorted(by: { $0.startDate < $1.startDate })
               let activeDates = events.allDates.keys.sorted().filter( { $0.isToday || $0.isFutureDay } )
               // let activeDates = await eventDataManager.getActiveDates(for: actualEvents)
//
//                let eventsIDs = actualEvents.map( { $0.id } )
//                var eventsToDelete: [Event] = []
//                self.actualEvents.forEach { event in
//                    if !eventsIDs.contains(event.id) {
//                        eventsToDelete.append(event)
//                    }
//                }
//
//                let placesIDs = aroundPlaces.map( { $0.id } )
//                var placesToDelete: [Place] = []
//                self.aroundPlaces.forEach { place in
//                    if !placesIDs.contains(place.id) {
//                        placesToDelete.append(place)
//                    }
//                }
                await MainActor.run { //[eventsToDelete, placesToDelete] in
                    // eventsToDelete.forEach( { modelContext.delete($0) } )
                    //  placesToDelete.forEach( { modelContext.delete($0) } )
                    //  self.actualEvents = actualEvents
                    self.upcomingEvents = uEvents
                    self.aroundPlaces = places
                    self.eventsDates = activeDates
                    self.todayEvents = tEvents
                    self.displayedEvents = uEvents
                    self.groupedPlaces = groupedPlaces
                    self.eventsCount = events.count
                    self.dateEvents = events.allDates
                }
                await updateSortingMapCategories()
            }
        }
  
        private func updateSortingMapCategories() async {
            var mapCategories: [SortingCategory] = []
            var homeCategories: [SortingCategory] = []
            var selectedCategory: SortingCategory?
            if eventsCount > 0 {
                homeCategories.append(.events)
                selectedCategory = .events
            }
            
            let placesTypes = groupedPlaces.keys
            
            placesTypes.forEach { mapCategories.append($0) }
            placesTypes.forEach { homeCategories.append($0) }

            if !todayEvents.isEmpty {
                mapCategories.append(.events)
            }
            if mapCategories.count > 1 {
                mapCategories.append(.all)
            }
            
            let sortedMapCategories = mapCategories.sorted(by: {$0.getSortPreority() < $1.getSortPreority()})
            let sortedHomeCategories = homeCategories.sorted(by: {$0.getSortPreority() < $1.getSortPreority()})
            
            if selectedCategory != .events, let firstPlacesCategory = sortedHomeCategories.first {
                selectedCategory = firstPlacesCategory
            }
            
            await MainActor.run { [sortedMapCategories, sortedHomeCategories, selectedCategory] in
                withAnimation {
                    sortingMapCategories = sortedMapCategories
                    sortingHomeCategories = sortedHomeCategories
                    selectedHomeSortingCategory = selectedCategory ?? .all
                }
            }
        }
    }
}
