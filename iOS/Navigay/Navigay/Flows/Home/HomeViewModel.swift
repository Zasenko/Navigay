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
        var modelContext: ModelContext
        
        var allAroundEvents: [Event] = [] // actualEvents
        var todayEvents: [Event] = []
        var upcomingEvents: [Event] = []
        var displayedEvents: [Event] = []
        
        var eventsDates: [Date] = []
        var selectedDate: Date? = nil
        var showCalendar: Bool = false //TODO: убрать
        
        var aroundPlaces: [Place] = [] /// for Map
        var groupedPlaces: [PlaceType: [Place]] = [:]
        
        var isLoading: Bool = true
        var isLocationsAround20Found: Bool = true
        
        var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
        var showMap: Bool = false
        var sortingHomeCategories: [SortingMapCategory] = []
        var selectedHomeSortingCategory: SortingMapCategory = .all
        
        var sortingMapCategories: [SortingMapCategory] = []
        var selectedMapSortingCategory: SortingMapCategory = .all
        
        let dataManager: DataManagerProtocol = DataManager() //TODO: init
        let aroundNetworkManager: AroundNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        
        init(modelContext: ModelContext, aroundNetworkManager: AroundNetworkManagerProtocol, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
            self.modelContext = modelContext
            self.aroundNetworkManager = aroundNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
        }
        
        func updateAroundPlacesAndEvents(userLocation: CLLocation) {
            let radius: Double = 20000
            
            let allPlaces = dataManager.getAllPlaces(modelContext: modelContext)
            let allEvents = dataManager.getAllEvents(modelContext: modelContext)
            
            Task {
                let aroundPlaces = await dataManager.getAroundPlaces(radius: radius, allPlaces: allPlaces, userLocation: userLocation)
                let aroundEvents = await dataManager.getAroundEvents(radius: radius, allEvents: allEvents, userLocation: userLocation)
                
                let groupedPlaces = await dataManager.createGroupedPlaces(places: aroundPlaces)
                let actualEvents = await dataManager.getActualEvents(for: aroundEvents)
                let todayEvents = await dataManager.getTodayEvents(from: aroundEvents)
                let upcomingEvents = await dataManager.getUpcomingEvents(from: aroundEvents)
                let eventsDatesWithoutToday = await dataManager.getActiveDates(for: actualEvents)
                
                await MainActor.run {
                    self.allAroundEvents = actualEvents
                    self.upcomingEvents = upcomingEvents
                    self.aroundPlaces = aroundPlaces/// для карты
                    self.eventsDates = eventsDatesWithoutToday
                    aroundPlaces.forEach { place in
                        let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                        place.getDistanceText(distance: distance, inKm: true)
                    }
                    withAnimation {
                        self.todayEvents = todayEvents
                        self.displayedEvents = upcomingEvents
                        self.groupedPlaces = groupedPlaces///для страницы
                        if !aroundPlaces.isEmpty && !aroundEvents.isEmpty {
                            isLoading = false
                        }
                    }
                }
                
                if !aroundNetworkManager.userLocations.contains(where: { $0 == userLocation }) {
                    await fetch(location: userLocation)
                } else {
                    if isLoading {
                        let closestPlaces = await dataManager.getClosestPlaces(from: allPlaces, userLocation: userLocation, count: 5)
                        let groupedClosestPlaces = await dataManager.createGroupedPlaces(places: closestPlaces)
                        await MainActor.run {
                            closestPlaces.forEach { place in
                                let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                                place.getDistanceText(distance: distance, inKm: true)
                            }
                            withAnimation {
                                self.groupedPlaces = groupedClosestPlaces
                                self.isLocationsAround20Found = false
                                self.isLoading = false
                            }
                        }
                    }
                }
                await updateSortingMapCategories()
            }
        }
        
        private func fetch(location: CLLocation) async {
            guard let decodedResult = await aroundNetworkManager.fetchLocations(location: location) else {
                return
            }
            await MainActor.run {
                
                if decodedResult.foundAround {
                    withAnimation {
                        isLocationsAround20Found = true
                    }
                } else {
                    withAnimation {
                        isLocationsAround20Found = false
                    }
                }
                
                let cities = updateCities(decodedCities: decodedResult.cities)
                let places = updatePlaces(decodedPlaces: decodedResult.places, for: cities)
                let events = updateEvents(decodedEvents: decodedResult.events, for: cities)

                places.forEach { place in
                    let distance = location.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                    place.getDistanceText(distance: distance, inKm: true)
                }
                updateFetchedResult(places: places.sorted(by: { $0.name < $1.name }), events: events.sorted(by: { $0.id < $1.id }), userLocation: location)
            }
        }
        
        private func updateFetchedResult(places: [Place], events: [Event], userLocation: CLLocation) {
            Task {
                let groupedPlaces = await dataManager.createGroupedPlaces(places: places)
                let actualEvents = await dataManager.getActualEvents(for: events)
                let todayEvents = await dataManager.getTodayEvents(from: events)
                let upcomingEvents = await dataManager.getUpcomingEvents(from: events)
                let eventsDatesWithoutToday = await dataManager.getActiveDates(for: actualEvents)
                
                /// удаляем не нужное
                let eventsIDs = allAroundEvents.map( { $0.id } )
                var eventsToDelete: [Event] = []
                allAroundEvents.forEach { event in
                    if !eventsIDs.contains(event.id) {
                        eventsToDelete.append(event)
                    }
                }
                
                let placesIDs = aroundPlaces.map( { $0.id } )
                var placesToDelete: [Place] = []
                aroundPlaces.forEach { place in
                    if !placesIDs.contains(place.id) {
                        placesToDelete.append(place)
                    }
                }
                
                await MainActor.run { [eventsToDelete, placesToDelete] in
                    eventsToDelete.forEach( { modelContext.delete($0) } )
                    placesToDelete.forEach( { modelContext.delete($0) } )
                    self.allAroundEvents = actualEvents
                    self.upcomingEvents = upcomingEvents
                    self.aroundPlaces = places/// для карты
                    self.eventsDates = eventsDatesWithoutToday
                    places.forEach { place in
                        let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                        place.getDistanceText(distance: distance, inKm: true)
                    }
                    withAnimation {
                        self.todayEvents = todayEvents
                        self.displayedEvents = upcomingEvents
                        self.groupedPlaces = groupedPlaces///для страницы
                        isLoading = false
                    }
                }
            }
        }
        
    //TODO:
        func showUpcomingEvents() {
            withAnimation {
                self.displayedEvents = upcomingEvents
            }
        }
        
        private func updatePlaces(decodedPlaces: [DecodedPlace]?, for cities: [City]) -> [Place] {
            guard let decodedPlaces else { return [] }
            do {
                let descriptor = FetchDescriptor<Place>()
                var allPlaces = try modelContext.fetch(descriptor)
                
                var places: [Place] = []
                
                for decodedPlace in decodedPlaces {
                    if let place = allPlaces.first(where: { $0.id == decodedPlace.id} ) {
                        place.updatePlaceIncomplete(decodedPlace: decodedPlace)
                        updateTimeTable(timetable: decodedPlace.timetable, for: place)
                        places.append(place)
                        if let cityId = decodedPlace.cityId,
                           let city = cities.first(where: { $0.id == cityId }) {
                            place.city = city
                            if !city.places.contains(where: { $0.id == place.id } ) {
                                city.places.append(place)
                            }
                        }
                    } else {
                        let place = Place(decodedPlace: decodedPlace)
                        modelContext.insert(place)
                        updateTimeTable(timetable: decodedPlace.timetable, for: place)
                        allPlaces.append(place)
                        places.append(place)
                        if let cityId = decodedPlace.cityId,
                           let city = cities.first(where: { $0.id == cityId }) {
                            place.city = city
                            city.places.append(place)
                        }
                    }
                }
                return places
            } catch {
                debugPrint(error)
                return []
            }
        }
        
        private func updateEvents(decodedEvents: [DecodedEvent]?, for cities: [City]) -> [Event] {
            guard let decodedEvents else { return [] }
            do {
                let descriptor = FetchDescriptor<Event>()
                var allEvents = try modelContext.fetch(descriptor)
                var events: [Event] = []
                
                for decodeEvent in decodedEvents {
                    if let event = allEvents.first(where: { $0.id == decodeEvent.id} ) {
                        event.updateEventIncomplete(decodedEvent: decodeEvent)
                        events.append(event)
                        if let cityId = decodeEvent.cityId,
                           let city = cities.first(where: { $0.id == cityId }) {
                            event.city = city
                            if !city.events.contains(where: { $0.id == event.id } ) {
                                city.events.append(event)
                            }
                        }
                    } else {
                        let event = Event(decodedEvent: decodeEvent)
                        modelContext.insert(event)
                        allEvents.append(event)
                        events.append(event)
                        if let cityId = decodeEvent.cityId,
                           let city = cities.first(where: { $0.id == cityId }) {
                            event.city = city
                            if !city.events.contains(where: { $0.id == event.id } ) {
                                city.events.append(event)
                            }
                        }
                    }
                }
                return events
            } catch {
                debugPrint(error)
                return []
            }
        }
        
        private func updateTimeTable(timetable: [PlaceWorkDay]?, for place: Place) {
            let oldTimetable = place.timetable
            place.timetable.removeAll()
            oldTimetable.forEach( { modelContext.delete($0) })
            if let timetable {
                for day in timetable {
                    let workingDay = WorkDay(workDay: day)
                    place.timetable.append(workingDay)
                }
            }
        }
        
        func getEvents(for date: Date) {
            Task {
                let events = allAroundEvents.filter { event in
                    if event.startDate.isFutureDay(of: date) {
                        return false
                    }
                    if event.startDate.isSameDayWithOtherDate(date) {
                        return true
                    }
                    guard let finishDate = event.finishDate else {
                        return false
                    }
                    
                    if finishDate.isFutureDay(of: date) {
                        return true
                    }
                    if finishDate.isSameDayWithOtherDate(date) {
                        guard let finishTime = event.finishTime,
                              let elevenAM = Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())
                        else {
                            return false
                        }
                        if finishTime.isPastHour(of: elevenAM) {
                            return false
                        } else {
                            return true
                        }
                    }
                    return false
                }
                await MainActor.run {
                    displayedEvents = events
                }
            }
        }
  
        private func updateSortingMapCategories() async {
            var categories: [SortingMapCategory] = []
            let placesTypes = groupedPlaces.keys.compactMap( { SortingMapCategory(placeType: $0)} )
            placesTypes.forEach { categories.append($0) }
            
            if !todayEvents.isEmpty {
                categories.append(.events)
            }
            if categories.count > 1 {
                categories.append(.all)
            }
            await MainActor.run { [categories] in
                withAnimation {
                    sortingMapCategories = categories
                }
            }
        }
        
        private func updateCities(decodedCities: [DecodedCity]?) -> [City] {
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
                        updateCityRegion(decodedRegion: decodedCity.region, for: city)
                        cities.append(city)
                    } else {
                        let city = City(decodedCity: decodedCity)
                        modelContext.insert(city)
                        updateCityRegion(decodedRegion: decodedCity.region, for: city)
                        cities.append(city)
                    }
                }
                return cities.sorted(by: { $0.name < $1.name})
            } catch {
                debugPrint(error)
                return []
            }
        }
        
        private func updateCityRegion(decodedRegion: DecodedRegion?, for city: City) {
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
                    updateRegionCountry(decodedCountry: decodedRegion.country, for: region)
                } else {
                    let region = Region(decodedRegion: decodedRegion)
                    modelContext.insert(region)
                    city.region = region
                    region.cities.append(city)
                    updateRegionCountry(decodedCountry: decodedRegion.country, for: region)
                }
            } catch {
                debugPrint(error)
            }
        }
        
        private func updateRegionCountry(decodedCountry: DecodedCountry?, for region: Region) {
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
}
