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
        let user: AppUser?
        var allEvents: [Event] = []
        var aroundEvents: [Event] = []
        var todayAndTomorrowEvents: [Event] = [] /// for Map
        var displayedEvents: [Event] = []
        
        var eventsDates: [Date] = []
        var selectedDate: Date? = nil
        var showCalendar: Bool = false // - убрать
        
        var allPlaces: [Place] = []
        var aroundPlaces: [Place] = [] /// for Map
        var groupedPlaces: [PlaceType: [Place]] = [:]
        
        var isLoading: Bool = true
        var foundAround: Bool = true
        
        var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
        var showMap: Bool = false
        var sortingCategories: [SortingMapCategory] = []
        var selectedHomeSortingCategory: SortingMapCategory = .all
        var sortingMapCategories: [SortingMapCategory] = []
        var selectedMapSortingCategory: SortingMapCategory = .all
        
        let aroundNetworkManager: AroundNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        
        init(modelContext: ModelContext, aroundNetworkManager: AroundNetworkManagerProtocol, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, user: AppUser?) {
            self.modelContext = modelContext
            self.aroundNetworkManager = aroundNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.user = user
        }
        
        func updateAroundPlacesAndEvents(userLocation: CLLocation) {
            let radius: Double = 20000
            getPlacesFromDB(userLocation: userLocation, radius: radius)
            getEventsFromDB(userLocation: userLocation, radius: radius)
            
            if !aroundEvents.isEmpty && !groupedPlaces.isEmpty {
                withAnimation {
                    isLoading = false
                }
            }
            
            if !aroundNetworkManager.userLocations.contains(where: { $0 == userLocation }) {
                fetch(location: userLocation)
            } else {
                if isLoading {
                    getClosesPlacesFromDB(userLocation: userLocation)
                    withAnimation {
                        foundAround = false
                        isLoading = false
                    }
                }
            }
            updateSortingCategories()
        }
        
        private func updatePlaces(decodedPlaces: [DecodedPlace]?) {
            guard let decodedPlaces else { return }
            for decodedPlace in decodedPlaces {
                if let place = allPlaces.first(where: { $0.id == decodedPlace.id} ) {
                    place.updatePlaceIncomplete(decodedPlace: decodedPlace)
                    updateTimeTable(timetable: decodedPlace.timetable, for: place)
                } else if decodedPlace.isActive {
                    let place = Place(decodedPlace: decodedPlace)
                    modelContext.insert(place)
                    updateTimeTable(timetable: decodedPlace.timetable, for: place)
                    allPlaces.append(place)
                }
            }
            
        }
        
        private func updateEvents(decodedEvents: [DecodedEvent]?) {
            guard let decodedEvents else { return }
            for decodeEvent in decodedEvents {
                if let event = allEvents.first(where: { $0.id == decodeEvent.id} ) {
                    event.updateEventIncomplete(decodedEvent: decodeEvent)
                } else if decodeEvent.isActive {
                    let event = Event(decodedEvent: decodeEvent)
                    modelContext.insert(event)
                    allEvents.append(event)
                }
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
        
        private func fetch(location: CLLocation) {
            Task {
                guard let decodedResult = await aroundNetworkManager.fetchLocations(location: location) else {
                    return
                }
                await MainActor.run {
                    updatePlaces(decodedPlaces: decodedResult.places)
                    updateEvents(decodedEvents: decodedResult.events)
                    if decodedResult.foundAround {
                        foundAround = true
                        updateAroundPlacesAndEvents(userLocation: location)
                    } else {
                        foundAround = false
                        getClosesPlacesFromDB(userLocation: location)
                    }
                    updateSortingCategories()
                    isLoading = false
                }
            }
        }
        
        private func getClosesPlacesFromDB(userLocation: CLLocation) {
            let sortedPlaces = allPlaces.sorted { place1, place2 in
                let location1 = CLLocation(latitude: place1.latitude, longitude: place1.longitude)
                let location2 = CLLocation(latitude: place2.latitude, longitude: place2.longitude)
                let distance1 = userLocation.distance(from: location1)
                let distance2 = userLocation.distance(from: location2)
                return distance1 < distance2
            }
            var closestPlaces: [Place] = []
            var count: Int = 0
            for place in sortedPlaces {
                closestPlaces.append(place)
                count += 1
                if count == 5 {
                    break
                }
            }
            aroundPlaces = closestPlaces
            createGroupedPlaces(places: closestPlaces)
        }
        
        private func getPlacesFromDB(userLocation: CLLocation, radius: Double) {
            do {
                let descriptor = FetchDescriptor<Place>(sortBy: [SortDescriptor(\.name)])
                allPlaces = try modelContext.fetch(descriptor)
                let aroundPlaces = allPlaces.filter { place in
                    let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                    place.getDistanceText(distance: distance, inKm: true)
                    return distance <= radius
                }
                self.aroundPlaces = aroundPlaces
                createGroupedPlaces(places: aroundPlaces)
            } catch {
                debugPrint(error)
            }
        }
        
        private func getEventsFromDB(userLocation: CLLocation, radius: Double) {
            do {
                let eventDescriptor = FetchDescriptor<Event>(sortBy: [SortDescriptor(\.id)])
                allEvents = try modelContext.fetch(eventDescriptor)
                let allAroundEvents = allEvents.filter { event in
                    let distance = userLocation.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
                    return distance <= radius && (event.startDate.isToday || event.startDate.isFutureDay)
                }
                let unsortedEvents = allAroundEvents.filter { event in
                    guard event.startDate.isToday || event.startDate.isFutureDay else {
                        if let finishDate = event.finishDate, finishDate.isFutureDay {
                            return true
                        }
                        guard let finishDate = event.finishDate,
                              finishDate.isToday,
                              let finishTime = event.finishTime,
                              finishTime.isFutureHour(of: Date())
                        else {
                            return false
                        }
                        return true
                    }
                    return true
                }
                aroundEvents = unsortedEvents.sorted(by: { $0.startDate < $1.startDate } )
                getUpcomingEvents()
                updateEventsDates()
                getEventsForMap()
            } catch {
                debugPrint(error)
            }
        }
        
        func getUpcomingEvents() {
            Task {
                let lastDayOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                let sevenDaydFromNow = Date().getAllDatesBetween(finishDate: lastDayOfWeek)
                let upcomingEvents = aroundEvents.filter { event in
                    if event.startDate.isToday {
                        return true
                    }
                    if event.startDate.isFutureDay {
                        var isShow: Bool = false
                        for day in sevenDaydFromNow {
                            if event.startDate.isSameDayWithOtherDate(day) {
                                isShow = true
                                break
                            } else {
                                isShow = false
                            }
                        }
                        return isShow
                    }
                    guard let finishDate = event.finishDate else {
                        return false
                    }
                    if finishDate.isFutureDay {
                        return true
                    }
                    guard finishDate.isToday,
                          let finishTime = event.finishTime,
                          finishTime.isFutureHour(of: Date())
                    else {
                        return false
                    }
                    return true
                }
                await MainActor.run {
                    if upcomingEvents.count > 0 {
                        displayedEvents = upcomingEvents
                    } else {
                        displayedEvents = Array(aroundEvents.prefix(4))
                    }
                }
            }
        }
        
        func getEvents(for date: Date) {
            Task {
                let events = aroundEvents.filter { event in
                    if event.startDate.isSameDayWithOtherDate(date) {
                        return true
                    }
                    if event.startDate.isFutureDay(of: date) {
                        return false
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
        
        func getEventsForMap() {
            Task {
                let events = aroundEvents.filter { event in
                    if event.startDate.isToday {
                        return true
                    }
                    if event.startDate.isFutureDay {
                        guard event.startDate.isTomorrow else {
                            return false
                        }
                        return true
                    }
                    
                    guard let finishTime = event.finishTime else {
                        return false
                    }
                    if finishTime.isFutureDay {
                        return true
                    }
                    
                    if finishTime.isToday {
                        guard let finishTime = event.finishTime,
                              finishTime.isFutureHour(of: Date())
                        else {
                            return false
                        }
                        return true
                    }
                    return false
                }
                await MainActor.run {
                    todayAndTomorrowEvents = events
                }
            }
        }
        
        private func updateEventsDates() {
            Task {
                var activeDates: [Date] = []
                
                aroundEvents.forEach { event in
                    guard let finishDate = event.finishDate else {
                        activeDates.append(event.startDate)
                        return
                    }
                    guard !finishDate.isSameDayWithOtherDate(event.startDate) else {
                        activeDates.append(event.startDate)
                        return
                    }
                    
                    var dates = event.startDate.getAllDatesBetween(finishDate: finishDate)
                    if let finishTime = event.finishTime {
                        if let elevenAM = Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date()) {
                            if finishTime.isPastHour(of: elevenAM) {
                                dates.removeLast()
                            }
                        } else {
                            dates.removeLast()
                        }
                    } else {
                        dates.removeLast()
                    }
                    activeDates.append(contentsOf: dates)
                }
                let eventsDates = activeDates.uniqued().filter { !$0.isPastDate }.sorted()
                await MainActor.run {
                    withAnimation {
                        self.eventsDates = eventsDates
                    }
                }
            }
        }
        
        private func createGroupedPlaces(places: [Place]) {
            withAnimation(.spring()) {
                self.groupedPlaces = Dictionary(grouping: places.filter { $0.isActive }) { $0.type }
            }
        }
        
        private func updateSortingCategories() {
            Task {
                var categories: [SortingMapCategory] = []
                let placesTypes = groupedPlaces.keys.compactMap( { SortingMapCategory(placeType: $0)} )
                placesTypes.forEach { categories.append($0) }
                if !aroundEvents.isEmpty {
                    categories.append(.events)
                }
                await MainActor.run { [categories] in
                    withAnimation {
                        sortingCategories = categories
                    }
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
        }
    }
}
