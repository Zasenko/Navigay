//
//  EventViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 23.12.23.
//

import SwiftUI
import SwiftData
import MapKit

extension EventView {
    
    @Observable
    final class EventViewModel {
        
        //MARK: - Properties
        
        var modelContext: ModelContext
        
        let event: Event
        var image: Image?
        
        var isShowPlace: Bool = true //????
        var isPosterLoaded: Bool = false //?????????
        var place: Place? = nil //????????? -> event.place
        var position: MapCameraPosition = .automatic
        
        var showHeader: Bool = false
        
        var showEditView: Bool = false
        var showNewEvetnView: Bool = false
        
        let placeNetworkManager: PlaceNetworkManagerProtocol //?????????
        let eventNetworkManager: EventNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        
     //   var isLoading: Bool = false //todo если event.complite == nil
     //   var allPlaces: [Place] = []// обновление ?????????

        //MARK: - Inits
        
        init(event: Event, modelContext: ModelContext, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
            self.event = event
            self.image = event.image
            self.modelContext = modelContext
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
        }
        
        //MARK: - Functions
        
        func loadPoster() {
            Task {
                if let url = event.poster {
                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
                        await MainActor.run {
                            self.image = image
                            event.image = image
                            isPosterLoaded = true
                        }
                    }
                }
            }
        }
        
        func loadEvent() {
            print("loadEvent()")
            Task {
                guard !eventNetworkManager.loadedEvents.contains(where: { $0 == event.id}) else {
                    return
                }
                guard let decodedEvent = await eventNetworkManager.fetchEvent(id: event.id) else {
                    return
                }
                await MainActor.run {
                    updateEvent(decodedEvent: decodedEvent)
                }
            }
        }
        
        func call(phone: String) {
            let api = "tel://"
            let stringUrl = api + phone
            guard let url = URL(string: stringUrl) else { return }
            UIApplication.shared.open(url)
        }
        
        func goToWebSite(url: String) {
            guard let url = URL(string: url) else { return }
            UIApplication.shared.open(url)
        }
        
        func goToMaps() {
            let coordinate = event.coordinate
            let stringUrl = "maps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)"
            guard let url = URL(string: stringUrl) else { return }
            UIApplication.shared.open(url)
        }
        
        //MARK: - Private Functions

        private func updateEvent(decodedEvent: DecodedEvent) {
            event.updateEventComplete(decodedEvent: decodedEvent)
            if let decodedPlace = decodedEvent.place {
                updatePlace(decodedPlace: decodedPlace)
            }
            if let owner = decodedEvent.owner {
                updateOwner(decodedUser: owner)
            }
        }
        private func updatePlace(decodedPlace: DecodedPlace) {
                do {
                    let descriptor = FetchDescriptor<Place>()
                    let allPlaces = try modelContext.fetch(descriptor)
                    var eventPlace: Place?
                    if let place = allPlaces.first(where: { $0.id == decodedPlace.id} ) {
                        place.updatePlaceIncomplete(decodedPlace: decodedPlace)
                        updateTimeTable(timetable: decodedPlace.timetable, for: place)
                        eventPlace = place
                    } else {
                        let place = Place(decodedPlace: decodedPlace)
                        updateTimeTable(timetable: decodedPlace.timetable, for: place)
                        eventPlace = place
                    }
                    event.place = eventPlace
                } catch {
                    debugPrint("ERROR - EventViewModel updatePlace id \(decodedPlace.id): ", error)
                }
        }
        
        private func updateOwner(decodedUser: DecodedUser) {
            do {
                let descriptor = FetchDescriptor<User>()
                let allUsers = try modelContext.fetch(descriptor)
                var eventOwner: User?
                if let owner = allUsers.first(where: { $0.id == decodedUser.id} ) {
                    owner.updateUser(decodedUser: decodedUser)
                    eventOwner = owner
                } else {
                    let owner = User(decodedUser: decodedUser)
                    eventOwner = owner
                }
                event.owner = eventOwner
            } catch {
                debugPrint("ERROR - EventViewModel updateOwner id \(decodedUser.id): ", error)
            }
        }
        
        //TOD double
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
    }
}
