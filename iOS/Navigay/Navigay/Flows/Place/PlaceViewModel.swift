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
        var eventsDates: [Date] = []
        var selectedDate: Date? = nil
        var showCalendar: Bool = false // - убрать???
        
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
        
        func fetchPlace() {
            Task {
                guard let decodedPlace = await placeNetworkManager.fetchPlace(id: place.id) else {
                    return
                }
                
                await MainActor.run {
                    updateFetchedResult(decodedPlace: decodedPlace)
                }
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
            
            Task {
                let actualEvents = await eventDataManager.getActualEvents(for: events.sorted(by: { $0.id < $1.id}))
                let todayEvents = await eventDataManager.getTodayEvents(from: actualEvents)
                let upcomingEvents = await eventDataManager.getUpcomingEvents(from: actualEvents)
                let eventsDatesWithoutToday = await eventDataManager.getActiveDates(for: actualEvents)
                
                await MainActor.run {
                    self.actualEvents = actualEvents
                    self.upcomingEvents = upcomingEvents
                    self.eventsDates = eventsDatesWithoutToday
                    self.todayEvents = todayEvents
                    self.displayedEvents = upcomingEvents
                    //isLoading = false
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
        
        func goToMaps() {
            let coordinate = place.coordinate
            let stringUrl = "maps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)"
            guard let url = URL(string: stringUrl) else { return }
            UIApplication.shared.open(url)
        }
    }
}
