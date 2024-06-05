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
        
    ///Sorted by id
    func getAllEvents(modelContext: ModelContext) -> [Event]
    func getEvent(id: Int, modelContext: ModelContext) -> Event?
    ///Filtered by distance
    func getAroundEvents(radius: Double, allEvents: [Event], userLocation: CLLocation) async -> [Event]
    
    ///sorted by date / start date (today or future) or finish Date (future or today with finish time is future)
    func getActualEvents(for events: [Event]) async -> [Event]
    
    func getTodayEvents(from events: [Event]) async -> [Event]
    
    ///sorted by date / events for 1 week without today
    func getUpcomingEvents(from events: [Event]) async -> [Event]
    
    func getActiveDates(for events: [Event]) async -> [Date]
    
    func getEvents(for date: Date, userLocation: CLLocation, modelContext: ModelContext) async -> [Event]
    func getEvents(for date: Date, events: [Event]) async -> [Event]
    
    func updateEvents(decodedEvents: [DecodedEvent]?, for cities: [City], modelContext: ModelContext) -> [Event]
    
    //todo избавиться от этих двух метобов
    func updateEvents(decodedEvents: EventsItemsResult?, for cities: [City], modelContext: ModelContext) -> EventsItems
    func updateCityEvents(decodedEvents: EventsItemsResult?, for city: City, modelContext: ModelContext) -> EventsItems
    
    
    func updateCityEvents(decodedEvents: [DecodedEvent]?, for city: City, modelContext: ModelContext) -> [Event]
    
    func updateEvents(decodedEvents: [DecodedEvent]?, for place: Place, modelContext: ModelContext) -> [Event]
}

final class EventDataManager {
}
extension EventDataManager: EventDataManagerProtocol {

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

    func getAroundEvents(radius: Double, allEvents: [Event], userLocation: CLLocation) async -> [Event] {
        return allEvents.filter { event in
            let distance = userLocation.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
            return distance <= radius
        }
    }
    
    func getActualEvents(for events: [Event]) async -> [Event] {
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
    
    func getTodayEvents(from events: [Event]) async -> [Event] {
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
    
    func getUpcomingEvents(from events: [Event]) async -> [Event] {
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
    
    func getActiveDates(for events: [Event]) async -> [Date] {
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
    
    func getEvents(for date: Date, events: [Event]) async -> [Event] {
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
    
    func getEvents(for date: Date, userLocation: CLLocation, modelContext: ModelContext) async -> [Event] {
        let radius: Double = 20000
        let allEvents = getAllEvents(modelContext: modelContext)
        let aroundEvents = await getAroundEvents(radius: radius, allEvents: allEvents, userLocation: userLocation)
        let actualEvents = await getActualEvents(for: aroundEvents)
        let events = await getEvents(for: date, events: actualEvents)
        return events
    }
    
    func updateEvents(decodedEvents: [DecodedEvent]?, for place: Place, modelContext: ModelContext) -> [Event] {
        guard let decodedEvents, !decodedEvents.isEmpty else {
            place.events.forEach( { modelContext.delete($0) } )
            return []
        }
        
        let ids = decodedEvents.map( { $0.id } )
        var eventsToDelete: [Event] = []
        place.events.forEach { event in
            if !ids.contains(event.id) {
                eventsToDelete.append(event)
            }
        }
        eventsToDelete.forEach( { modelContext.delete($0) } )
        
        do {
            let descriptor = FetchDescriptor<Event>()
            var allEvents = try modelContext.fetch(descriptor)
            var events: [Event] = []
            
            for decodeEvent in decodedEvents {
                if let event = allEvents.first(where: { $0.id == decodeEvent.id} ) {
                    event.updateEventIncomplete(decodedEvent: decodeEvent)
                    events.append(event)
                    event.place = place
                    if !place.events.contains(where: { $0.id == event.id } ) {
                        place.events.append(event)
                    }
                } else {
                    let event = Event(decodedEvent: decodeEvent)
                    modelContext.insert(event)
                    allEvents.append(event)
                    events.append(event)
                    event.place = place
                    place.events.append(event)
                }
            }
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
        let todayEvents = updateEvents(decodedEvents: decodedEvents.today, for: cities, modelContext: modelContext)
        let upcomingEvents = updateEvents(decodedEvents: decodedEvents.upcoming, for: cities, modelContext: modelContext)
        return EventsItems(today: todayEvents, upcoming: upcomingEvents, allDates: updateAllDates(decodedAllDates: decodedEvents.allDates), count: decodedEvents.eventsCount ?? 0)
    }
    

    
    func updateCityEvents(decodedEvents: EventsItemsResult?, for city: City, modelContext: ModelContext) -> EventsItems {
        guard let decodedEvents else {
            city.events.forEach( { modelContext.delete($0) } )
            return EventsItems(today: [], upcoming: [], allDates: [:], count: 0)
        }
        let todayEvents = updateCityEvents(decodedEvents: decodedEvents.today, for: city, modelContext: modelContext)
        let upcomingEvents = updateCityEvents(decodedEvents: decodedEvents.upcoming, for: city, modelContext: modelContext)
        return EventsItems(today: todayEvents, upcoming: upcomingEvents, allDates: updateAllDates(decodedAllDates: decodedEvents.allDates), count: decodedEvents.eventsCount ?? 0)
    }
    
    func updateEvents(decodedEvents: [DecodedEvent]?, for cities: [City], modelContext: ModelContext) -> [Event] {
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
}
extension EventDataManager {

    // MARK: - Private functions
    
    func updateCityEvents(decodedEvents: [DecodedEvent]?, for city: City, modelContext: ModelContext) -> [Event] {
        guard let decodedEvents, !decodedEvents.isEmpty else {
            city.events.forEach( { modelContext.delete($0) } )
            return []
        }
        do {
            let descriptor = FetchDescriptor<Event>()
            var allEvents = try modelContext.fetch(descriptor)
            var events: [Event] = []
            
            for decodeEvent in decodedEvents {
                if let event = allEvents.first(where: { $0.id == decodeEvent.id} ) {
                    event.updateEventIncomplete(decodedEvent: decodeEvent)
                    events.append(event)
                    event.city = city
                    if !city.events.contains(where: { $0.id == event.id } ) {
                        city.events.append(event)
                    }
                } else {
                    let event = Event(decodedEvent: decodeEvent)
                    modelContext.insert(event)
                    allEvents.append(event)
                    events.append(event)
                    event.city = city
                    city.events.append(event)
                }
            }
            return events
        } catch {
            debugPrint(error)
            return []
        }
    }
    
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
