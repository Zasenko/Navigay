//
//  PlaceViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 23.12.23.
//

import SwiftUI

import SwiftUI
import SwiftData
import MapKit

extension PlaceView {
    
    @Observable
    class PlaceViewModel {
        
        //MARK: - Properties
        
        var modelContext: ModelContext
        
        
        let user: AppUser?
        
        let place: Place
        var allPhotos: [String] = []
        
        var showAddCommentButton: Bool = false
        var comments: [DecodedComment] = []
        
        var selectedTag: UUID? = nil /// for Map (big Pin)
        
        var gridLayoutPhotos: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
        var gridLayoutEvents: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
        var position: MapCameraPosition = .automatic
                
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        
        
        //MARK: - Inits
        
        init(place: Place, modelContext: ModelContext, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, user: AppUser?) {
            self.place = place
            self.selectedTag = place.tag
            self.modelContext = modelContext
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.user = user
        }
        
        //MARK: - Functions
        
        func loadPlace() {
            Task {
                if placeNetworkManager.loadedPlaces.contains(where: { $0 == place.id}) {
                    return
                }
                guard let decodedPlace = await placeNetworkManager.getPlace(id: place.id) else {
                    return
                }
                
                await MainActor.run {
                    updatePlace(decodedPlace: decodedPlace)
                    /// чтобы фотографии не загружались несколько раз
                    /// todo! проверить и изменить логику
                    let newPhotosLinks = place.getAllPhotos()
                    for links in newPhotosLinks {
                        if !allPhotos.contains(where:  { $0 == links } ) {
                            allPhotos.append(links)
                        }
                    }
                    updateEvents(decodedEvents: decodedPlace.events)
                }
            }
        }
        
        func fetchComments() {
            Task {
//                if placeNetworkManager.loadedPlaces.contains(where: { $0 == place.id}) {
//                    return
//                }
                guard let decodedComments = await placeNetworkManager.fetchComments(placeID: place.id) else {
                    return
                }
                let activeComments = decodedComments.filter( { $0.isActive } )
                await MainActor.run {
                    comments = activeComments
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
            let coordinate = place.coordinate
            let stringUrl = "maps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)"
            guard let url = URL(string: stringUrl) else { return }
            UIApplication.shared.open(url)
        }
        
        //MARK: - Private Functions
        
        private func updatePlace(decodedPlace: DecodedPlace) {
            place.updatePlaceComplite(decodedPlace: decodedPlace)
            let timetable = place.timetable
            place.timetable.removeAll()
            timetable.forEach( { modelContext.delete($0) })
            if let timetable = decodedPlace.timetable {
                for day in timetable {
                    let workingDay = WorkDay(workDay: day)
                    place.timetable.append(workingDay)
                }
            }
        }
        
        private func updateEvents(decodedEvents: [DecodedEvent]?) {
            if let decodedEvents {
                do {
                    let descriptor = FetchDescriptor<Event>()
                    let allEvents = try modelContext.fetch(descriptor)
                    for decodeEvent in decodedEvents {
                        var newEvent: Event?
                        if let event = allEvents.first(where: { $0.id == decodeEvent.id} ) {
                            event.updateEventIncomplete(decodedEvent: decodeEvent)
                            newEvent = event
                        } else if decodeEvent.isActive {
                            let event = Event(decodedEvent: decodeEvent)
                            newEvent = event
                        }
                        if let newEvent = newEvent, !place.events.contains(where: { $0.id == newEvent.id } ) {
                            place.events.append(newEvent)
                        }
                    }
                } catch {
                    debugPrint("ERROR - PlaceViewModel updateEvents(): ", error)
                }
            }
        }
    }
}
