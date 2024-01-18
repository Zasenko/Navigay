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
        
        var showRegistrationView: Bool = false
        var showAddEventView: Bool = false
        
        var showEditView: Bool = false
        
        //MARK: - Inits
        
        init(place: Place, modelContext: ModelContext, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
            self.place = place
            self.selectedTag = place.tag
            self.modelContext = modelContext
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
        }
        
        //MARK: - Functions
        
        func loadPlace() {
            Task {
                guard let decodedPlace = await placeNetworkManager.fetchPlace(id: place.id) else {
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
                guard let decodedComments = await placeNetworkManager.fetchComments(placeID: place.id) else {
                    return
                }
                await MainActor.run {
                    comments = decodedComments.filter( { $0.isActive } )
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
            guard let decodedEvents, !decodedEvents.isEmpty else {
                // TODO: проверить нужно ли удалять places из city
                place.events.forEach( { modelContext.delete($0) } )
                return
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
                let allEvents = try modelContext.fetch(descriptor)
                
                for decodedEvent in decodedEvents {
                    if let event = place.events.first(where: { $0.id == decodedEvent.id} ) {
                        event.updateEventIncomplete(decodedEvent: decodedEvent)
                    } else {
                        if let event = allEvents.first(where: { $0.id == decodedEvent.id} ) {
                            event.updateEventIncomplete(decodedEvent: decodedEvent)
                            place.events.append(event)
                            event.place = place
                        } else {
                            let event = Event(decodedEvent: decodedEvent)
                            place.events.append(event)
                            event.place = place
                        }
                    }
                }
                //TODO: дубликат кода getEventsFromDB(userLocation: CLLocation, radius: Double) в HomeViewModel
                let unsortedEvents = place.events.filter { event in
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
                
                place.events = unsortedEvents
            } catch {
                debugPrint("ERROR - PlaceViewModel updateEvents(): ", error)
            }
        }
    }
}
