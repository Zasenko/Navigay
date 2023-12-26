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
        var isLoading: Bool = true // TODO: isLoading
        
        var groupedPlaces: [PlaceType: [Place]] = [:]
        
        var displayedEvents: [Event] = []
        var eventsDates: [Date] = []
        var selectedDate: Date? = nil
        var showCalendar: Bool = false // - убрать???
        
        var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
        let catalogNetworkManager: CatalogNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        
        init(modelContext: ModelContext, city: City, catalogNetworkManager: CatalogNetworkManagerProtocol, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
            debugPrint("init CityViewModel, city id: ", city.id)
            self.modelContext = modelContext
            self.city = city
            self.catalogNetworkManager = catalogNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            if city.lastUpdateComplite == nil {
                isLoading = true
            }
        }
        
        func getPlacesAndEventsFromDB() {
            Task {
                await createGroupedPlaces(places: city.places)
                await getEventsForCity()
                await fetch()
            }
        }
        
        private func fetch() async {
            if !catalogNetworkManager.loadedCities.contains(where: { $0 == city.id}) {
                guard let decodedCity = await catalogNetworkManager.fetchCity(id: city.id) else {
                    isLoading = false
                    return
                }
                
                await MainActor.run {
                    city.updateCityComplite(decodedCity: decodedCity)
                    updatePlaces(decodedPlaces: decodedCity.places)
                    updateEvents(decodedEvents: decodedCity.events)
                    isLoading = false
                }
            }
        }
        
        private func getEventsForCity() async {
            let unsortedEvents = city.events.filter { event in
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
            let sortedEvents = unsortedEvents.sorted(by: { $0.startDate < $1.startDate } )
            await getUpcomingEvents(for: sortedEvents)
            await updateEventsDates(for: sortedEvents)
            //  getEventsForMap()
        }
        
        // TODO: дубляж
        func getEvents(for date: Date) async {
                let events = city.events.filter { event in
                    guard event.isActive else {
                        return false
                    }
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
        
        // TODO: дубляж
        func getUpcomingEvents(for events: [Event]) async {
            let lastDayOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            let sevenDaydFromNow = Date().getAllDatesBetween(finishDate: lastDayOfWeek)
            let upcomingEvents = events.filter { event in
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
                    displayedEvents = Array(events.prefix(4))
                }
            }
            
        }
        
        private func updateEventsDates(for events: [Event]) async {
            var activeDates: [Date] = []
            
            events.forEach { event in
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
        
        func updatePlaces(decodedPlaces: [DecodedPlace]?) {
            guard let decodedPlaces, !decodedPlaces.isEmpty else {
                // TODO: проверить нужно ли удалять places из city
                city.places.forEach( { modelContext.delete($0) } )
                return
            }
            do {
                let descriptor = FetchDescriptor<Place>(sortBy: [SortDescriptor(\.name)])
                let allPlaces = try modelContext.fetch(descriptor)
                
                for decodedPlace in decodedPlaces {
                    if let place = city.places.first(where: { $0.id == decodedPlace.id} ) {
                        place.updatePlaceIncomplete(decodedPlace: decodedPlace)
                        updateTimeTable(timetable: decodedPlace.timetable, for: place)
                    } else {
                        if let place = allPlaces.first(where: { $0.id == decodedPlace.id} ) {
                            place.updatePlaceIncomplete(decodedPlace: decodedPlace)
                            city.places.append(place)
                            updateTimeTable(timetable: decodedPlace.timetable, for: place)
                        } else if decodedPlace.isActive {
                            let place = Place(decodedPlace: decodedPlace)
                            city.places.append(place)
                            updateTimeTable(timetable: decodedPlace.timetable, for: place)
                        }
                    }
                }
                Task {
                    await createGroupedPlaces(places: city.places)
                }
            } catch {
                debugPrint("-- ERROR--- CityViewModel updatePlaces: ", error)
            }
        }
        
        func updateEvents(decodedEvents: [DecodedEvent]?) {
            guard let decodedEvents, !decodedEvents.isEmpty else {
                // TODO: проверить нужно ли удалять places из city
                city.events.forEach( { modelContext.delete($0) } )
                return
            }
            do {
                let descriptor = FetchDescriptor<Event>(sortBy: [SortDescriptor(\.startDate)])
                let allEvents = try modelContext.fetch(descriptor)
                
                for decodedEvent in decodedEvents {
                    if let event = city.events.first(where: { $0.id == decodedEvent.id} ) {
                        event.updateEventIncomplete(decodedEvent: decodedEvent)
                    } else {
                        if let event = allEvents.first(where: { $0.id == decodedEvent.id} ) {
                            event.updateEventIncomplete(decodedEvent: decodedEvent)
                            city.events.append(event)
                        } else if decodedEvent.isActive {
                            let event = Event(decodedEvent: decodedEvent)
                            city.events.append(event)
                        }
                    }
                }
                Task {
                    await getEventsForCity()
                }
            } catch {
                debugPrint("-- ERROR--- CityViewModel updateEvents: ", error)
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
        
        
        func createGroupedPlaces(places: [Place]) async {
            let groupedPlaces = Dictionary(grouping: places.filter { $0.isActive }) { $0.type }
            await MainActor.run {
                withAnimation(.spring()) {
                    self.groupedPlaces = groupedPlaces
                }
            }
        }
    }
}
