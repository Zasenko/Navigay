//
//  CityViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import SwiftUI
import SwiftData

struct CityPlacesItem: Identifiable {
    let id: UUID
    let category: SortingCategory
    var places: [Place]
}

extension CityView {
    @Observable
    class CityViewModel {
        
        var modelContext: ModelContext
        let city: City
        
        var isPresented: Bool = false
        var isLoading: Bool = false
        
        var allPhotos: [String] = []
        
        var groupedItems: [PlaceType: [Place]] = [:]
        
        var allPlaces: [Place] = [] /// for Map
        var groupedPlaces: [CityPlacesItem] = []
        
        var todayEvents: [Event] = []
        var upcomingEvents: [Event] = []
        var displayedEvents: [Event] = []
        var eventsCount: Int = 0
        var showCalendar: Bool = false
        var eventsDates: [Date] = []
        var selectedDate: Date? = nil
        var selectedEvent: Event?
        
        var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
        var sortingHomeCategories: [SortingCategory] = []
        var selectedMenuCategory: SortingCategory = .all
        var selectedHomeSortingCategory: SortingCategory? = nil
        
        var showMap: Bool = false
        var sortingMapCategories: [SortingCategory] = []
        var selectedMapSortingCategory: SortingCategory = .all
        
        let catalogNetworkManager: CatalogNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let commentsNetworkManager: CommentsNetworkManagerProtocol

        let errorManager: ErrorManagerProtocol
        
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let catalogDataManager: CatalogDataManagerProtocol
        let notificationsManager: NotificationsManagerProtocol
        
        init(modelContext: ModelContext,
             city: City,
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
            self.catalogNetworkManager = catalogNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
            self.catalogDataManager = catalogDataManager
            self.commentsNetworkManager = commentsNetworkManager
            self.notificationsManager = notificationsManager
            self.city = city
            allPhotos = city.getAllPhotos()
        }
        
        func getPlacesAndEventsFromDB() {
            isPresented = true
            debugPrint("-CityViewModel- getPlacesAndEventsFromDB()")
            Task {
                let places = city.places.sorted(by: { $0.name < $1.name })
                let events = city.events.sorted(by: { $0.id < $1.id })
                
                let groupedPlaces = await self.placeDataManager.createHomeGroupedPlaces(places: places.sorted(by: { $0.name < $1.name}))
                let cityPlacesItem = groupedPlaces.map( { CityPlacesItem(id: UUID(), category: $0.key, places: $0.value) } )
                let actualEvents = eventDataManager.getActualEvents(for: events)
                let todayEvents = eventDataManager.getTodayEvents(from: actualEvents)
                let upcomingEvents = eventDataManager.getUpcomingEvents(from: actualEvents)
                await MainActor.run {
                    self.allPlaces = places
                    self.groupedPlaces = cityPlacesItem
                    self.upcomingEvents = upcomingEvents
                    self.todayEvents = todayEvents
                    self.displayedEvents = upcomingEvents
                    self.eventsDates = city.eventsDates
                    self.eventsCount = city.eventsCount
                }
                await updateCategories()
                await fetch()
            }
        }
        
        func showUpcomingEvents() {
            displayedEvents = upcomingEvents
        }
        
        func getEvents(for date: Date) {
            let events = eventDataManager.getEvents(for: date, events: city.events)
            displayedEvents = events
            Task {
                await fetchEvents(for: date)
            }
        }

        private func fetch() async {
            guard !catalogNetworkManager.loadedCities.contains(where: { $0 == city.id})
            else {
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
                
        private func fetchEvents(for date: Date) async {
            let message = "Something went wrong. The information didn't update. Please try again later."
            do {
                let events = try await eventNetworkManager.fetchEvents(cityId: city.id, date: date)
                await MainActor.run {
                    let events = eventDataManager.update(decodedEvents: events, for: city, on: date, modelContext: modelContext)
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
        
        private func updateFetchedResult(decodedCity: DecodedCity) {
            city.updateCityComplite(decodedCity: decodedCity)
            allPhotos = city.getAllPhotos()
            let places = placeDataManager.update(decodedPlaces: decodedCity.places, for: city, modelContext: modelContext)
            let events = eventDataManager.update(decodedEvents: decodedCity.events, for: city, modelContext: modelContext)
            Task {
                let groupedPlaces = await self.placeDataManager.createHomeGroupedPlaces(places: places.sorted(by: { $0.name < $1.name}))
                let cityPlacesItem = groupedPlaces.map( { CityPlacesItem(id: UUID(), category: $0.key, places: $0.value) } )
                let todayEvents = events.today.sorted(by: { $0.id < $1.id })
                let upcomingEvents = events.upcoming.sorted(by: { $0.id < $1.id }).sorted(by: { $0.startDate < $1.startDate })
                let activeDates = decodedCity.events?.calendarDates?.compactMap( { $0.dateFromString(format: "yyyy-MM-dd") }) ?? []
                await MainActor.run {
                    self.upcomingEvents = upcomingEvents
                    self.allPlaces = places
                    self.eventsDates = activeDates
                    self.todayEvents = todayEvents
                    self.displayedEvents = upcomingEvents
                    self.groupedPlaces = cityPlacesItem
                    self.eventsCount = events.count
                    self.city.eventsCount = events.count
                    self.city.eventsDates = activeDates
                }
                await updateCategories()
            }
        }

        private func updateCategories() async {
            var mapCategories: [SortingCategory] = []
            var homeCategories: [SortingCategory] = []
            var selectedCategory: SortingCategory = .all

            if eventsCount > 0 {
                homeCategories.append(.events)
            }
            let placesTypes = groupedPlaces.map({ $0.category })
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
            
            await MainActor.run { [selectedCategory] in
                withAnimation {
                    sortingMapCategories = sortedMapCategories
                    sortingHomeCategories = sortedHomeCategories
                    selectedMenuCategory = selectedCategory
                    selectedHomeSortingCategory = selectedCategory
                }
            }
        }
    }
}
