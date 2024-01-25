//
//  DataManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 04.01.24.
//

import Foundation
import SwiftData
import CoreLocation

protocol DataManagerProtocol {
    ///Sorted by name
    func getAllPlaces(modelContext: ModelContext) -> [Place]

    ///Filtered by distance
    func getAroundPlaces(radius: Double, allPlaces: [Place], userLocation: CLLocation) async -> [Place]
    
    ///Grouped by type
    func createGroupedPlaces(places: [Place]) async -> [PlaceType: [Place]]
    
    func getClosestPlaces(from places: [Place], userLocation: CLLocation, count: Int) async -> [Place]
    
    
    ///Sorted by id
    func getAllEvents(modelContext: ModelContext) -> [Event]
    
    ///Filtered by distance
    func getAroundEvents(radius: Double, allEvents: [Event], userLocation: CLLocation) async -> [Event]
    
    ///sorted by date / start date (today or future) or finish Date (future or today with finish time is future)
    func getActualEvents(for events: [Event]) async -> [Event]
    
    func getTodayEvents(from events: [Event]) async -> [Event]
    
    ///events for 1 week without today
    func getUpcomingEvents(from events: [Event]) async -> [Event]
    
    func getActiveDates(for events: [Event]) async -> [Date]
}

final class DataManager: DataManagerProtocol {
    
    func getAllPlaces(modelContext: ModelContext) -> [Place] {
        do {
            let descriptor = FetchDescriptor<Place>(sortBy: [SortDescriptor(\.name)])
            return try modelContext.fetch(descriptor)
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func getAllEvents(modelContext: ModelContext) -> [Event] {
        do {
            let descriptor = FetchDescriptor<Event>(sortBy: [SortDescriptor(\.id)])
            return try modelContext.fetch(descriptor)
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func getAroundPlaces(radius: Double, allPlaces: [Place], userLocation: CLLocation) async -> [Place] {
        return allPlaces.filter { place in
            let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
            place.getDistanceText(distance: distance, inKm: true)//TODO: in miles also
            return distance <= radius
        }
    }
    
    func getAroundEvents(radius: Double, allEvents: [Event], userLocation: CLLocation) async -> [Event] {
        return allEvents.filter { event in
            let distance = userLocation.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
            return distance <= radius
        }
    }
    
    func createGroupedPlaces(places: [Place]) async -> [PlaceType: [Place]] {
        return Dictionary(grouping: places) { $0.type }
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
        if upcomingEvents.count > 0 {
            return upcomingEvents.sorted(by: { $0.startDate < $1.startDate})
        } else {
            return Array(events.prefix(4).sorted(by: { $0.startDate < $1.startDate}))
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
    
    func getClosestPlaces(from places: [Place], userLocation: CLLocation, count: Int) async -> [Place] {

        let sortedPlaces = places.sorted { place1, place2 in
            let location1 = CLLocation(latitude: place1.latitude, longitude: place1.longitude)
            let location2 = CLLocation(latitude: place2.latitude, longitude: place2.longitude)
            let distance1 = userLocation.distance(from: location1)
            let distance2 = userLocation.distance(from: location2)
            return distance1 < distance2
        }
        var closestPlaces: [Place] = []
        var placeCount: Int = 0
        for place in sortedPlaces {
            closestPlaces.append(place)
            placeCount += 1
            if placeCount == count {
                break
            }
        }
        return closestPlaces
    }
}
