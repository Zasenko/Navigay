//
//  PlaceDataManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 04.01.24.
//

import Foundation
import SwiftData
import CoreLocation

protocol PlaceDataManagerProtocol {
    ///Sorted by name
    func getAllPlaces(modelContext: ModelContext) -> [Place]
    
    ///Filtered by distance
    func getAroundPlaces(radius: Double, allPlaces: [Place], userLocation: CLLocation) async -> [Place]
    
    ///Grouped by type
    func createGroupedPlaces(places: [Place]) async -> [PlaceType: [Place]]
    
    func getClosestPlaces(from places: [Place], userLocation: CLLocation, count: Int) async -> [Place]
    
    func updatePlaces(decodedPlaces: [DecodedPlace]?, for cities: [City], modelContext: ModelContext) -> [Place]
    func updatePlaces(decodedPlaces: [DecodedPlace]?, for city: City, modelContext: ModelContext) -> [Place]
    func updateTimeTable(timetable: [PlaceWorkDay]?, for place: Place, modelContext: ModelContext)
}

final class PlaceDataManager: PlaceDataManagerProtocol {
    
    func getAllPlaces(modelContext: ModelContext) -> [Place] {
        do {
            let descriptor = FetchDescriptor<Place>(sortBy: [SortDescriptor(\.name)])
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

    func createGroupedPlaces(places: [Place]) async -> [PlaceType: [Place]] {
        return Dictionary(grouping: places) { $0.type }
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
    
    func updatePlaces(decodedPlaces: [DecodedPlace]?, for cities: [City], modelContext: ModelContext) -> [Place] {
        guard let decodedPlaces else { return [] }
        do {
            let descriptor = FetchDescriptor<Place>()
            var allPlaces = try modelContext.fetch(descriptor)
            
            var places: [Place] = []
            
            for decodedPlace in decodedPlaces {
                if let place = allPlaces.first(where: { $0.id == decodedPlace.id} ) {
                    place.updatePlaceIncomplete(decodedPlace: decodedPlace)
                    updateTimeTable(timetable: decodedPlace.timetable, for: place, modelContext: modelContext)
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
                    updateTimeTable(timetable: decodedPlace.timetable, for: place, modelContext: modelContext)
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
    
    func updatePlaces(decodedPlaces: [DecodedPlace]?, for city: City, modelContext: ModelContext) -> [Place] {
        guard let decodedPlaces,
              !decodedPlaces.isEmpty
        else {
            city.places.forEach( { modelContext.delete($0) } )
            return []
        }
        
        let ids = decodedPlaces.map( { $0.id } )
        var placesToDelete: [Place] = []
        city.places.forEach { place in
            if !ids.contains(place.id) {
                placesToDelete.append(place)
            }
        }
        placesToDelete.forEach( { modelContext.delete($0) } )
        do {
            let descriptor = FetchDescriptor<Place>()
            var allPlaces = try modelContext.fetch(descriptor)
            
            var places: [Place] = []
            
            for decodedPlace in decodedPlaces {
                if let place = allPlaces.first(where: { $0.id == decodedPlace.id} ) {
                    place.updatePlaceIncomplete(decodedPlace: decodedPlace)
                    updateTimeTable(timetable: decodedPlace.timetable, for: place, modelContext: modelContext)
                    places.append(place)
                    place.city = city
                    if !city.places.contains(where: { $0.id == place.id } ) {
                        city.places.append(place)
                    }
                } else {
                    let place = Place(decodedPlace: decodedPlace)
                    modelContext.insert(place)
                    updateTimeTable(timetable: decodedPlace.timetable, for: place, modelContext: modelContext)
                    allPlaces.append(place)
                    places.append(place)
                    place.city = city
                    city.places.append(place)
                }
            }
            return places
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func updateTimeTable(timetable: [PlaceWorkDay]?, for place: Place, modelContext: ModelContext) {
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
}

