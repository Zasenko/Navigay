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

        var actualEvents: [Event] = []
        var todayEvents: [Event] = []
        var upcomingEvents: [Event] = []
        var displayedEvents: [Event] = []
        
        var showCalendar: Bool = false
        var eventsDates: [Date] = []
        var selectedDate: Date? = nil
        
        
        var gridLayoutPhotos: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
        var gridLayoutEvents: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
        var position: MapCameraPosition = .automatic
                
        let placeNetworkManager: PlaceNetworkManagerProtocol
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
                    let eventsDatesWithoutToday = await eventDataManager.getActiveDates(for: actualEvents)
                    
                    await MainActor.run {
                        self.actualEvents = actualEvents
                        self.upcomingEvents = upcomingEvents
                        self.eventsDates = eventsDatesWithoutToday
                        self.todayEvents = todayEvents
                        self.displayedEvents = upcomingEvents
                    }
                    await fetchPlace()
                }
            }
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
            let events = eventDataManager.updateEvents(decodedEvents: decodedPlace.events, for: place, modelContext: modelContext)
            updateEvents(events: events)
        }
        
        private func updateEvents(events: [Event]) {
            Task {
                let actualEvents = await eventDataManager.getActualEvents(for: events.sorted(by: { $0.id < $1.id}))
                let todayEvents = await eventDataManager.getTodayEvents(from: actualEvents)
                let upcomingEvents = await eventDataManager.getUpcomingEvents(from: actualEvents)

                let eventsDatesWithoutToday = await eventDataManager.getActiveDates(for: actualEvents)
                
                let eventsIDs = actualEvents.map( { $0.id } )
                var eventsToDelete: [Event] = []
                self.actualEvents.forEach { event in
                    if !eventsIDs.contains(event.id) {
                        eventsToDelete.append(event)
                    }
                }
                
                await MainActor.run { [eventsToDelete] in
                    eventsToDelete.forEach( { modelContext.delete($0) } )
                    self.actualEvents = actualEvents
                    self.upcomingEvents = upcomingEvents
                    self.eventsDates = eventsDatesWithoutToday
                    self.todayEvents = todayEvents
                    self.displayedEvents = upcomingEvents
                }
            }
        }
        
        func fetchComments() {
            Task {
                let message = "Oops! Looks like the comments failed to load. Don't worry, we're actively working to resolve the issue."
                do {
                    let decodedComments = try await placeNetworkManager.fetchComments(placeID: place.id)
                    await MainActor.run {
                        comments = decodedComments.filter( { $0.isActive } )
                    }
                } catch NetworkErrors.noConnection {
                } catch NetworkErrors.apiError(let apiError) {
                    errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
                } catch {
                    errorManager.showError(model: ErrorModel(error: error, message: message))
                }
            }
        }
        
        func goToMaps() {
            let coordinate = place.coordinate
            let stringUrl = "maps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)"
            guard let url = URL(string: stringUrl) else { return }
            UIApplication.shared.open(url)
        }
    }
}
