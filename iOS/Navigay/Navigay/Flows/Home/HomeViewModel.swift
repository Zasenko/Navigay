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
        
        var allPlaces: [Place] = []
        var aroundPlaces: [Place] = []
        var groupedPlaces: [PlaceType: [Place]] = [:]
        
        var foundAround: Bool = true
        
        var isLoading: Bool = true
        var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
        var sortingCategories: [SortingMapCategory] = []
        var selectedSortingCategory: SortingMapCategory = .all
        var showMap: Bool = false
        
        
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
            print(sortedPlaces.count)
            let closestPlaces: [Place] = Array(sortedPlaces[0..<5])
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
                let unsortedEventsAround = allEvents.filter { event in
                    let distance = userLocation.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
                    let lastDayOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                    let weekDays = Date().getAllDatesBetween(finishDate: lastDayOfWeek)
                    var bool = false
                    for day in weekDays {
                        if day.isSameDayWithOtherDate(event.startDate) {
                            bool = true
                        }
                    }
                    if !bool {
                        if let finishDate = event.finishDate {
                            let allEventsDate = event.startDate.getAllDatesBetween(finishDate: finishDate)
                            for eventDay in allEventsDate {
                                for day in weekDays {
                                    if day.isSameDayWithOtherDate(eventDay) {
                                        if finishDate.isToday {
                                            if let finishTime = event.finishTime {
                                                if finishTime.isFutureHour(of: Date()) {
                                                    bool = true
                                                    break
                                                } else {
                                                    bool = false
                                                    break
                                                }
                                            } else {
                                                bool = true
                                                break
                                            }
                                        } else {
                                            bool = true
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                    return distance <= radius && bool
                }
                let sortedEvents = unsortedEventsAround.sorted(by: { $0.startDate < $1.startDate } )
                aroundEvents = sortedEvents
            } catch {
                debugPrint(error)
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
