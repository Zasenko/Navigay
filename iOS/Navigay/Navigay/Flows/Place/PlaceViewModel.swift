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
        var isLoading: Bool = false
        
        var showHeaderTitle: Bool = false
        
        var modelContext: ModelContext
        let place: Place
        var showOpenInfo: Bool
        
        var allPhotos: [String] = []
        var showAddCommentButton: Bool = false
        var comments: [DecodedComment] = []
        var selectedTag: UUID? = nil /// for Map (big Pin) 

        var todayEvents: [Event] = []
        var upcomingEvents: [Event] = []
        var displayedEvents: [Event] = []
        
        var eventsCount: Int = 0
        var showCalendar: Bool = false
        var eventsDates: [Date] = []
        var selectedDate: Date? = nil
        var selectedEvent: Event?
        
        var gridLayoutPhotos: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
        var gridLayoutEvents: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
        var position: MapCameraPosition = .automatic
                
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let commentsNetworkManager: CommentsNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        
        
        var showRegistrationView: Bool = false
        var showAddEventView: Bool = false
        var showEditView: Bool = false
        
        //MARK: - Init
        
        init(place: Place,
             modelContext: ModelContext,
             placeNetworkManager: PlaceNetworkManagerProtocol,
             eventNetworkManager: EventNetworkManagerProtocol,
             errorManager: ErrorManagerProtocol,
             placeDataManager: PlaceDataManagerProtocol,
             eventDataManager: EventDataManagerProtocol,
             commentsNetworkManager: CommentsNetworkManagerProtocol,
             showOpenInfo: Bool) {
            self.place = place
            self.showOpenInfo = showOpenInfo
            self.selectedTag = place.tag
            self.modelContext = modelContext
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
            self.commentsNetworkManager = commentsNetworkManager
        }
        
        //MARK: - Functions
        
        func getEventsFromDB() {
            if place.lastUpdateComplite == nil {
                isLoading = true
                Task {
                    await fetchPlace()
                }
            } else {
                Task {
                    let events = place.events.sorted(by: { $0.id < $1.id })
                    
                    let actualEvents = await self.eventDataManager.getActualEvents(for: events)
                    let todayEvents = await eventDataManager.getTodayEvents(from: actualEvents)
                    let upcomingEvents = await eventDataManager.getUpcomingEvents(from: actualEvents)
                   // let eventsDatesWithoutToday = await eventDataManager.getActiveDates(for: actualEvents)
                    await MainActor.run {
                        self.upcomingEvents = upcomingEvents
                        self.eventsDates = place.eventsDates
                        self.eventsCount = place.eventsCount
                        self.todayEvents = todayEvents
                        self.displayedEvents = upcomingEvents
                    }
                    await fetchPlace()
                }
            }
        }
        
        func goToMaps() {
            let coordinate = place.coordinate
            let stringUrl = "maps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)"
            guard let url = URL(string: stringUrl) else { return }
            UIApplication.shared.open(url)
        }
        
        private func fetchPlace() async {
            guard !placeNetworkManager.loadedPlaces.contains(where: { $0 ==  place.id } ) else {
                return
            }
            await MainActor.run {
                isLoading = true
            }
            do {
                let decodedPlace = try await placeNetworkManager.fetchPlace(id: place.id)
                await MainActor.run {
                    updateFetchedResult(decodedPlace: decodedPlace)
                }
            } catch NetworkErrors.noConnection {
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
            } catch {
                errorManager.showUpdateError(error: error)
            }
            await MainActor.run { 
                isLoading = false
            }
        }
        
        private func updateFetchedResult(decodedPlace: DecodedPlace) {
            placeDataManager.update(place: place, decodedPlace: decodedPlace, modelContext: modelContext)
            /// чтобы фотографии не загружались несколько раз
            /// todo! проверить и изменить логику
            let newPhotosLinks = place.getAllPhotos()
            for links in newPhotosLinks {
                if !allPhotos.contains(where:  { $0 == links } ) {
                    allPhotos.append(links)
                }
            }
            
            let todayEvents = eventDataManager.updateEvents(decodedEvents: decodedPlace.events?.today, for: place, modelContext: modelContext)
            let upcomingEvents = eventDataManager.updateEvents(decodedEvents: decodedPlace.events?.upcoming, for: place, modelContext: modelContext)
            
            let todayEventsSorted = todayEvents.sorted(by: { $0.id < $1.id })
            let upcomingEventsSorted = upcomingEvents.sorted(by: { $0.id < $1.id }).sorted(by: { $0.startDate < $1.startDate })
            let activeDates = decodedPlace.events?.calendarDates?.compactMap( { $0.dateFromString(format: "yyyy-MM-dd") }) ?? []
            
            self.upcomingEvents = upcomingEventsSorted
            self.eventsDates = activeDates
            self.todayEvents = todayEventsSorted
            self.displayedEvents = upcomingEventsSorted
            self.eventsCount = decodedPlace.events?.eventsCount ?? 0
            self.place.eventsCount = decodedPlace.events?.eventsCount ?? 0
            self.place.eventsDates = activeDates
        }
        
//        private func updateEvents(events: [Event]) {
//            Task {
//                let actualEvents = await eventDataManager.getActualEvents(for: events.sorted(by: { $0.id < $1.id}))
//                let todayEvents = await eventDataManager.getTodayEvents(from: actualEvents)
//                let upcomingEvents = await eventDataManager.getUpcomingEvents(from: actualEvents)
//
//                let eventsDatesWithoutToday = await eventDataManager.getActiveDates(for: actualEvents)
//                
//                let eventsIDs = actualEvents.map( { $0.id } )
//                var eventsToDelete: [Event] = []
//                self.actualEvents.forEach { event in
//                    if !eventsIDs.contains(event.id) {
//                        eventsToDelete.append(event)
//                    }
//                }
//                
//                await MainActor.run { [eventsToDelete] in
//                    eventsToDelete.forEach( { modelContext.delete($0) } )
//                    self.actualEvents = actualEvents
//                    self.upcomingEvents = upcomingEvents
//                    self.eventsDates = eventsDatesWithoutToday
//                    self.todayEvents = todayEvents
//                    self.displayedEvents = upcomingEvents
//                    self.eventsCount = actualEvents.count
//                }
//            }
//        }

    }
}
