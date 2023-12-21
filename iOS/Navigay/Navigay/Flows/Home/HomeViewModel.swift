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
        var sortingCategories: [SortingMapCategory] = [] /// for Map
        var selectedSortingCategory: SortingMapCategory = .all /// for Map
        
        let networkManager: AroundNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        
        init(modelContext: ModelContext, networkManager: AroundNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
            self.modelContext = modelContext
            self.networkManager = networkManager
            self.eventNetworkManager = EventNetworkManager(appSettingsManager: networkManager.appSettingsManager)
            self.placeNetworkManager = PlaceNetworkManager(appSettingsManager: networkManager.appSettingsManager)
            self.errorManager = errorManager
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
            
            if !networkManager.userLocations.contains(where: { $0 == userLocation }) {
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
                guard let decodedResult = await networkManager.fetchLocations(location: location) else {
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
                let aroundPlaces = allPlaces.filter { userLocation.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude)) <= radius }
                self.aroundPlaces = aroundPlaces
                createGroupedPlaces(places: aroundPlaces)
            } catch {
                debugPrint(error)
            }
        }
        
        private func getEventsFromDB(userLocation: CLLocation, radius: Double) {
            do {
                let eventDescriptor = FetchDescriptor<Event>()
                allEvents = try modelContext.fetch(eventDescriptor)
                let unsortedEvents = allEvents.filter { event in
                    let distance = userLocation.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
   
                    if let finishDate = event.finishDate {
                        return distance <= radius && (finishDate.isToday || finishDate.isFutureDay)
                    } else {
                        return distance <= radius && (event.startDate.isToday || event.startDate.isFutureDay)
                    }
                }
                aroundEvents = unsortedEvents.sorted(by: { $0.startDate < $1.startDate } )
                getUpcomingEvents()
                updateEventsDates()
            } catch {
                debugPrint(error)
            }
        }
        
        func getUpcomingEvents() {
            let lastDayOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            let weekDays = Date().getAllDatesBetween(finishDate: lastDayOfWeek)
            let upcomingEvents = aroundEvents.filter { event in
                var isShow: Bool = false
                for day in weekDays {
                    if event.startDate.isSameDayWithOtherDate(day) {
                        isShow = true
                    }
                }
                if !isShow {
                    if let finishDate = event.finishDate {
                        let eventDates = event.startDate.getAllDatesBetween(finishDate: finishDate)
                        for eventDay in eventDates {
                            for weekDay in weekDays {
                                if eventDay.isSameDayWithOtherDate(weekDay) {
                                    if finishDate.isToday {
                                        if let finishTime = event.finishTime {
                                            isShow = finishTime.isFutureHour(of: Date()) ? true : false
                                            break
                                        } else {
                                            isShow = true
                                            break
                                        }
                                    } else {
                                        isShow = true
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
                return isShow
            }
            if upcomingEvents.count > 0 {
                displayedEvents = upcomingEvents
            } else {
                displayedEvents = Array(aroundEvents.prefix(4))
            }
        }
        
        func getEvents(for date: Date) {
            let unsortedWeekEvents = aroundEvents.filter { event in
                guard let finishDate = event.finishDate else {
                    return event.startDate.isSameDayWithOtherDate(date)
                }
                guard !finishDate.isSameDayWithOtherDate(event.startDate) else {
                    return event.startDate.isSameDayWithOtherDate(date)
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
                return dates.contains(where: { $0 == date } )
            }
            displayedEvents = unsortedWeekEvents
        }
        
        private func updateEventsDates() {
            Task {
                var activeDates: [Date] = []
                aroundEvents.forEach { event in
                    if let finishDate = event.finishDate {
                        if finishDate.isSameDayWithOtherDate(event.startDate) {
                            activeDates.append(event.startDate)
                        } else {
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
                    } else {
                        activeDates.append(event.startDate)
                    }
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
                if categories.count > 1 {
                    categories.append(.all)
                }
                await MainActor.run { [categories] in
                    withAnimation {
                        sortingCategories = categories
                    }
                }
            }
        }
    }
}
