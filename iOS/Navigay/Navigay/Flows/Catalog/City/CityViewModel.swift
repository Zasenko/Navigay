//
//  CityViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import SwiftUI
import SwiftData

struct CityItems {
    let allPlaces: [Place]
    let groupedPlaces: [CityPlacesItem]
    let todayEvents: [Event]
    let upcomingEvents: [Event]
    let citySortingItems: CitySortingItems
}

struct CityPlacesItem: Identifiable {
    let id: UUID
    let category: SortingCategory
    var places: [Place]
}

struct CitySortingItems {
    let homeCategories: [SortingCategory]
    let mapCategories: [SortingCategory]
    let selectedCategory: SortingCategory
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
        
        //var homeCategories: [SortingCategory] = []
        //var selectedHomeCategory: SortingCategory? = nil
        //var selectedMenuCategory: SortingCategory = .all

        var mapCategories: [SortingCategory] = []
        var selectedMapCategory: SortingCategory = .all
        
        var showMap: Bool = false

        
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
            if let result = catalogDataManager.loadedCities[city] {
              //  self.homeCategories = result.citySortingItems.homeCategories
                self.mapCategories = result.citySortingItems.mapCategories
              //  self.selectedMenuCategory = result.citySortingItems.selectedCategory
              //  self.selectedHomeCategory = result.citySortingItems.selectedCategory
                self.todayEvents = result.todayEvents
                self.displayedEvents = result.upcomingEvents
                self.groupedPlaces = result.groupedPlaces
                self.allPlaces = result.allPlaces
                self.upcomingEvents = result.upcomingEvents
                self.eventsDates = city.eventsDates
                self.eventsCount = city.eventsCount
            } else {
                Task {
                    let places = city.places.sorted(by: { $0.name < $1.name })
                    let events = city.events.sorted(by: { $0.id < $1.id })
                    
                    let groupedPlaces = await self.placeDataManager.createHomeGroupedPlaces(places: places.sorted(by: { $0.name < $1.name}))
                    let cityPlacesItems = groupedPlaces.map( { CityPlacesItem(id: UUID(), category: $0.key, places: $0.value) } )
                    let actualEvents = eventDataManager.getActualEvents(for: events)
                    let todayEvents = eventDataManager.getTodayEvents(from: actualEvents)
                    let upcomingEvents = eventDataManager.getUpcomingEvents(from: actualEvents)
                    
                    let citySortingItems = await updateCategories(eventsCount: city.eventsCount, todayEventsCount: todayEvents.count, placesTypes: cityPlacesItems.map({ $0.category }))

                    await MainActor.run {
                      //  self.homeCategories = citySortingItems.homeCategories
                        self.mapCategories = citySortingItems.mapCategories
                      //  self.selectedMenuCategory = citySortingItems.selectedCategory
                      //  self.selectedHomeCategory = citySortingItems.selectedCategory
                        self.todayEvents = todayEvents
                        self.displayedEvents = upcomingEvents
                        self.groupedPlaces = cityPlacesItems
                        self.allPlaces = places
                        self.upcomingEvents = upcomingEvents
                        self.eventsDates = city.eventsDates
                        self.eventsCount = city.eventsCount
                    }
                    await fetch()
                }

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
            await MainActor.run {
                isLoading = true
            }
            do {
                let decodedCity = try await catalogNetworkManager.fetchCity(id: city.id)
                await MainActor.run {
                    updateFetchedResult(decodedCity: decodedCity)
                }
                return
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
                let cityPlacesItems = groupedPlaces.map( { CityPlacesItem(id: UUID(), category: $0.key, places: $0.value) } )
                let todayEvents = events.today.sorted(by: { $0.id < $1.id })
                let upcomingEvents = events.upcoming.sorted(by: { $0.id < $1.id }).sorted(by: { $0.startDate < $1.startDate })
                let activeDates = decodedCity.events?.calendarDates?.compactMap( { $0.dateFromString(format: "yyyy-MM-dd") }) ?? []
                
                let citySortingItems = await updateCategories(eventsCount: events.count, todayEventsCount: todayEvents.count, placesTypes: cityPlacesItems.map({ $0.category }))
                
                await MainActor.run {
                 //   self.homeCategories = citySortingItems.homeCategories
                    self.mapCategories = citySortingItems.mapCategories
                 //   self.selectedMenuCategory = citySortingItems.selectedCategory
                 //   self.selectedHomeCategory = citySortingItems.selectedCategory
                    self.todayEvents = todayEvents
                    self.displayedEvents = upcomingEvents
                    self.groupedPlaces = cityPlacesItems
                    self.upcomingEvents = upcomingEvents
                    self.eventsDates = activeDates
                    self.eventsCount = events.count
                    self.allPlaces = places
                    self.city.eventsCount = events.count
                    self.city.eventsDates = activeDates
                    self.isLoading = false
                }
                catalogDataManager.addLoadedCity(city, with: CityItems(allPlaces: places, groupedPlaces: cityPlacesItems, todayEvents: todayEvents, upcomingEvents: upcomingEvents, citySortingItems: citySortingItems))
            }
        }

        private func updateCategories(eventsCount: Int, todayEventsCount: Int, placesTypes: [SortingCategory]) async -> CitySortingItems {
            var mapCategories: [SortingCategory] = []
            var homeCategories: [SortingCategory] = []
            var selectedCategory: SortingCategory = .all

            if eventsCount > 0 {
                homeCategories.append(.events)
            }
            let placesTypes = placesTypes
            placesTypes.forEach { mapCategories.append($0) }
            placesTypes.forEach { homeCategories.append($0) }
            if todayEventsCount > 0 {
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
            return CitySortingItems(homeCategories: sortedHomeCategories, mapCategories: sortedMapCategories, selectedCategory: selectedCategory)
        }
    }
}

