//
//  EventDataManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.01.24.
//

import Foundation
import SwiftData
import CoreLocation

protocol EventDataManagerProtocol {
    
    var aroundEventsCount: Int? { get set }
    var dateEvents: [Date: [Int]]? { get set }
    
    ///Sorted by id
    func getAllEvents(modelContext: ModelContext) -> [Event]
    func getEvent(id: Int, modelContext: ModelContext) -> Event?
    ///Filtered by distance
    func getAroundEvents(radius: Double, allEvents: [Event], userLocation: CLLocation) async -> [Event]
    
    ///sorted by date / start date (today or future) or finish Date (future or today with finish time is future)
    func getActualEvents(for events: [Event]) -> [Event]
    
    func getTodayEvents(from events: [Event]) -> [Event]
    
    ///sorted by date / events for 1 week without today
    func getUpcomingEvents(from events: [Event]) -> [Event]
    
    func getActiveDates(for events: [Event]) -> [Date]
    
    func getEvents(for date: Date, userLocation: CLLocation, modelContext: ModelContext) -> [Event]
    func getEvents(for date: Date, events: [Event]) -> [Event]
    
    /// return unsorted events
    func update(decodedEvents: [DecodedEvent]?, modelContext: ModelContext) -> [Event]
    
    func updateEvents2(decodedEvents: [DecodedEvent]?, for cities: [City], modelContext: ModelContext) -> [Event]
    
    //todo избавиться от этих двух метобов
    func updateEvents(decodedEvents: EventsItemsResult?, for cities: [City], modelContext: ModelContext) -> EventsItems
    func update(decodedEvents: EventsItemsResult?, for city: City, modelContext: ModelContext) -> EventsItems
    
    func update(decodedEvents: [DecodedEvent]?, for city: City, on date: Date, modelContext: ModelContext) -> [Event]
    
    func update(decodedEvents: EventsItemsResult?, for place: Place, modelContext: ModelContext) -> EventsItems
    
    func update(decodedEvents: [DecodedEvent]?, for place: Place, on date: Date, modelContext: ModelContext) -> [Event]
}

final class EventDataManager: EventDataManagerProtocol {
    var aroundEventsCount: Int? = nil
    var dateEvents: [Date: [Int]]? = nil
}

extension EventDataManager {
    
    func getAllEvents(modelContext: ModelContext) -> [Event] {
        do {
            let descriptor = FetchDescriptor<Event>(sortBy: [SortDescriptor(\.id)])
            return try modelContext.fetch(descriptor)
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func getEvent(id: Int, modelContext: ModelContext) -> Event? {
        let events = getAllEvents(modelContext: modelContext)
        return events.first(where: { $0.id == id })
    }
    
    func getAroundEvents(radius: Double, allEvents: [Event], userLocation: CLLocation) -> [Event] {
        return allEvents.filter { event in
            let distance = userLocation.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
            return distance <= radius
        }
    }
    
    func getActualEvents(for events: [Event]) -> [Event] {
        return events.filter { event in
            if event.startDate.isToday || event.startDate.isFutureDay  {
                return true
            }
            guard let finishDate = event.finishDate else {
                return false
            }
            if finishDate.isFutureDay {
                return true
            } else if finishDate.isToday {
                guard let finishTime = event.finishTime,
                      finishTime.isFutureHour(of: Date())
                else {
                    return false
                }
                return true
            }
            return false
        }.sorted(by: { $0.startDate < $1.startDate } )
    }
    
    func getTodayEvents(from events: [Event]) -> [Event] {
        return events.filter { event in
            if event.startDate.isToday {
                return true
            } else {
                ///если начало не сегодня
                ///убираем  если начало будущее
                guard !event.startDate.isFutureDay,
                      let finishDate = event.finishDate else {
                    return false
                }
                ///остается начало - прошлое
                if finishDate.isFutureDay {
                    return true
                }
                if finishDate.isPastDate {
                    return false
                }
                if finishDate.isToday {
                    guard let finishTime = event.finishTime,
                          finishTime.isFutureHour(of: Date())
                    else {
                        return false
                    }
                    return true
                }
                return false
            }
        }
    }
    
    func getUpcomingEvents(from events: [Event]) -> [Event] {
        let lastDayOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let sevenDaydFromNow = Date().getAllDatesBetween(finishDate: lastDayOfWeek)
        let upcomingEvents = events.filter { event in
            guard event.startDate.isFutureDay else {
                return false
            }
            var isShow: Bool = false
            for day in sevenDaydFromNow {
                if event.startDate.isSameDayWithOtherDate(day) {
                    isShow = true
                }
            }
            return isShow
        }
        if upcomingEvents.count > 3 {
            return upcomingEvents.sorted(by: { $0.startDate < $1.startDate})
        } else {
            let allUpcomingEvents = events.filter { $0.startDate.isFutureDay }
            return Array(allUpcomingEvents.prefix(4).sorted(by: { $0.startDate < $1.startDate}))
        }
    }
    
    func getActiveDates(for events: [Event]) -> [Date] {
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
            if let finishTime = event.finishTime,
               let elevenAM = Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date()) {
                if finishTime.isPastHour(of: elevenAM) {
                    if dates.count > 0 {
                        dates.removeLast()
                    }
                }
            } else {
                if dates.count > 0 {
                    dates.removeLast()
                }
            }
            activeDates.append(contentsOf: dates)
        }
        return activeDates.uniqued().sorted()
    }
    
    func getEvents(for date: Date, events: [Event]) -> [Event] {
        return events.filter { event in
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
    }
    
    func getEvents(for date: Date, userLocation: CLLocation, modelContext: ModelContext) -> [Event] {
        let radius: Double = 20000
        let allEvents = getAllEvents(modelContext: modelContext)
        let aroundEvents = getAroundEvents(radius: radius, allEvents: allEvents, userLocation: userLocation)
        let actualEvents = getActualEvents(for: aroundEvents)
        let events = getEvents(for: date, events: actualEvents)
        return events
    }
    
    func update(decodedEvents: [DecodedEvent]?, modelContext: ModelContext) -> [Event] {
        guard let decodedEvents, !decodedEvents.isEmpty else {
            return []
        }
        do {
            var allEvents = getAllEvents(modelContext: modelContext)
            var events: [Event] = []
            for decodeEvent in decodedEvents {
                if let event = allEvents.first(where: { $0.id == decodeEvent.id} ) {
                    event.updateEventIncomplete(decodedEvent: decodeEvent)
                    events.append(event)
                } else {
                    let event = Event(decodedEvent: decodeEvent)
                    modelContext.insert(event)
                    //todo проверить у всех добавляемых элементов 
                    allEvents.append(event)
                    events.append(event)
                }
            }
            try modelContext.save()
            return events
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func updateEvents(decodedEvents: EventsItemsResult?, for cities: [City], modelContext: ModelContext) -> EventsItems {
        guard let decodedEvents else {
            return EventsItems(today: [], upcoming: [], allDates: [:], count: 0)
        }
        let todayEvents = updateEvents2(decodedEvents: decodedEvents.today, for: cities, modelContext: modelContext)
        let upcomingEvents = updateEvents2(decodedEvents: decodedEvents.upcoming, for: cities, modelContext: modelContext)
        return EventsItems(today: todayEvents, upcoming: upcomingEvents, allDates: updateAllDates(decodedAllDates: decodedEvents.allDates), count: decodedEvents.eventsCount ?? 0)
    }
    
    //ok
    func update(decodedEvents: EventsItemsResult?, for city: City, modelContext: ModelContext) -> EventsItems {
        let todayEvents = update(decodedEvents: decodedEvents?.today, modelContext: modelContext)
        let upcomingEvents = update(decodedEvents: decodedEvents?.upcoming, modelContext: modelContext)
        
        var events: [Event] = []
        events.append(contentsOf: todayEvents)
        events.append(contentsOf: upcomingEvents)
        
        guard !events.isEmpty else {
            let eventsToDelete = city.events
            city.events = []
            eventsToDelete.forEach( { modelContext.delete($0) } )
            return EventsItems(today: [], upcoming: [], allDates: [:], count: 0)
        }
        events.forEach( { $0.city = city } )

        let ids = events.map( { $0.id } )
        var eventsToDelete: [Event] = []
        
        let cityTodayEvents = getTodayEvents(from: city.events)
        let cityUpcomingEvents = getUpcomingEvents(from: city.events)
        
        var oldCityEvents: [Event] = []
        oldCityEvents.append(contentsOf: cityTodayEvents)
        oldCityEvents.append(contentsOf: cityUpcomingEvents)
        oldCityEvents.forEach { event in
            if !ids.contains(event.id) {
                eventsToDelete.append(event)
            }
        }
        
        let oldEventIds = oldCityEvents.map { $0.id }
        let newEvents = events.filter { !oldEventIds.contains($0.id) }
        city.events.append(contentsOf: newEvents)
        city.events.removeAll { eventsToDelete.contains($0) } 
        eventsToDelete.forEach( { modelContext.delete($0) } )
        
        return EventsItems(today: todayEvents, upcoming: upcomingEvents, allDates: updateAllDates(decodedAllDates: decodedEvents?.allDates), count: decodedEvents?.eventsCount ?? 0)
    }
    
    func updateEvents2(decodedEvents: [DecodedEvent]?, for cities: [City], modelContext: ModelContext) -> [Event] {
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
            try modelContext.save()
            return events
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    //ok
    func update(decodedEvents: [DecodedEvent]?, for city: City, on date: Date, modelContext: ModelContext) -> [Event] {
        let events = update(decodedEvents: decodedEvents, modelContext: modelContext)
        let oldEvents = getEvents(for: date, events: city.events)
        
        guard !events.isEmpty else {
            city.events.removeAll { event in
                oldEvents.contains { $0.id == event.id }
            }
            oldEvents.forEach( { modelContext.delete($0) } )
            return []
        }
        events.forEach( { $0.city = city } )

        let ids = events.map( { $0.id } )
        let eventsToDelete = oldEvents.filter { !ids.contains($0.id) }
        
        let oldEventIds = oldEvents.map { $0.id }
        let newEvents = events.filter { !oldEventIds.contains($0.id) }
        
        city.events.append(contentsOf: newEvents)
        city.events.removeAll { eventsToDelete.contains($0) }
        eventsToDelete.forEach( { modelContext.delete($0) } )
        return events
    }
    
    //ok
    func update(decodedEvents: EventsItemsResult?, for place: Place, modelContext: ModelContext) -> EventsItems {
        let todayEvents = update(decodedEvents: decodedEvents?.today, modelContext: modelContext)
        let upcomingEvents = update(decodedEvents: decodedEvents?.upcoming, modelContext: modelContext)
        
        var events: [Event] = []
        events.append(contentsOf: todayEvents)
        events.append(contentsOf: upcomingEvents)
        
        guard !events.isEmpty else {
            let eventsToDelete = place.events
            place.events = []
            eventsToDelete.forEach( { modelContext.delete($0) } )
            return EventsItems(today: [], upcoming: [], allDates: [:], count: 0)
        }
        events.forEach( { $0.place = place } )

        let ids = events.map( { $0.id } )
        var eventsToDelete: [Event] = []
        
        let placeTodayEvents = getTodayEvents(from: place.events)
        let placeUpcomingEvents = getUpcomingEvents(from: place.events)
        
        var oldPlaceEvents: [Event] = []
        oldPlaceEvents.append(contentsOf: placeTodayEvents)
        oldPlaceEvents.append(contentsOf: placeUpcomingEvents)
        oldPlaceEvents.forEach { event in
            if !ids.contains(event.id) {
                eventsToDelete.append(event)
            }
        }
        
        let oldEventIds = oldPlaceEvents.map { $0.id }
        let newEvents = events.filter { !oldEventIds.contains($0.id) }
        place.events.append(contentsOf: newEvents)
        place.events.removeAll { eventsToDelete.contains($0) }
        eventsToDelete.forEach( { modelContext.delete($0) } )
        
        return EventsItems(today: todayEvents, upcoming: upcomingEvents, allDates: updateAllDates(decodedAllDates: decodedEvents?.allDates), count: decodedEvents?.eventsCount ?? 0)
    }
    
    //ok
    func update(decodedEvents: [DecodedEvent]?, for place: Place, on date: Date, modelContext: ModelContext) -> [Event] {
        let events = update(decodedEvents: decodedEvents, modelContext: modelContext)
        let oldEvents = getEvents(for: date, events: place.events)
        
        guard !events.isEmpty else {
            place.events.removeAll { event in
                oldEvents.contains { $0.id == event.id }
            }
            oldEvents.forEach( { modelContext.delete($0) } )
            return []
        }
        events.forEach( { $0.place = place } )

        let ids = events.map( { $0.id } )
        let eventsToDelete = oldEvents.filter { !ids.contains($0.id) }
        
        let oldEventIds = oldEvents.map { $0.id }
        let newEvents = events.filter { !oldEventIds.contains($0.id) }
        
        place.events.append(contentsOf: newEvents)
        place.events.removeAll { eventsToDelete.contains($0) }
        eventsToDelete.forEach( { modelContext.delete($0) } )
        return events
    }
}
extension EventDataManager {
    
    // MARK: - Private functions
    
    private func updateAllDates(decodedAllDates: [String: [Int]]?) -> [Date: [Int]] {
        guard let decodedAllDates = decodedAllDates else { return [:] }
        var allDates: [Date: [Int]] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for (dateString, eventIds) in decodedAllDates {
            if let date = dateFormatter.date(from: dateString) {
                allDates[date] = eventIds
            }
        }
        return allDates
    }
}
