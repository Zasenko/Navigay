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
        
        // MARK: - Properties
        
        var modelContext: ModelContext
        var event: Event
        var image: Image?
        var position: MapCameraPosition = .automatic
        var selectedTag: UUID? = nil /// for Map (big Pin)
        let placeNetworkManager: PlaceNetworkManagerProtocol //?????????
        let eventNetworkManager: EventNetworkManagerProtocol
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let errorManager: ErrorManagerProtocol
        let commentsNetworkManager: CommentsNetworkManagerProtocol
        let notificationsManager: NotificationsManagerProtocol
        
        //MARK: - Inits
        
        init(event: Event, modelContext: ModelContext, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, placeDataManager: PlaceDataManagerProtocol, eventDataManager: EventDataManagerProtocol, commentsNetworkManager: CommentsNetworkManagerProtocol, notificationsManager: NotificationsManagerProtocol) {
            self.event = event
            self.modelContext = modelContext
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
            self.commentsNetworkManager = commentsNetworkManager
            self.notificationsManager = notificationsManager
            self.selectedTag = event.tag
            centerMapPin()
            loadEvent()
        }
        
        //MARK: - Functions
        
        func centerMapPin() {
            position = .camera(MapCamera(centerCoordinate: event.coordinate, distance: 1500))
        }
        
        func likeButtonTapped() {
            event.isLiked.toggle()
            if event.isLiked {
                notificationsManager.addEventNotification(event: event)
            } else {
                notificationsManager.removeEventNotification(event: event)
            }
        }
        
        func loadEvent() {
            debugPrint("loadEvent()")
            loadPoster()
            Task {
                guard !eventDataManager.loadedEvents.contains(where: { $0.id == event.id}) else {
                    return
                }
                do {
                    let decodedEvent = try await eventNetworkManager.fetchEvent(id: event.id)
                    await MainActor.run {
                        updateEvent(decodedEvent: decodedEvent)
                    }
                } catch NetworkErrors.noConnection {
                } catch NetworkErrors.apiError(let apiError) {
                    errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
                } catch {
                    errorManager.showError(model: ErrorModel(error: error, message: errorManager.updateMessage))
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
        
        private func loadPoster() {
            if let img = event.posterImg {
                self.image = img
            } else {
                self.image = event.smallPosterImg
                Task(priority: .high) {
                    if let url = event.poster {
                        if let image = await ImageLoader.shared.loadImage(urlString: url) {
                            await MainActor.run {
                                self.image = image
                                event.posterImg = image
                            }
                        }
                    }
                }
            }
        }
        
        private func updateEvent(decodedEvent: DecodedEvent) {
            event.updateEventComplete(decodedEvent: decodedEvent)
            eventDataManager.addLoadedEvents(event)
            Task(priority: .high) {
                if let url = event.poster {
                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
                        await MainActor.run {
                            self.image = image
                            event.posterImg = image
                        }
                    }
                }
            }
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
                    placeDataManager.updateTimeTable(timetable: decodedPlace.timetable, for: place, modelContext: modelContext)
                    eventPlace = place
                } else {
                    let place = Place(decodedPlace: decodedPlace)
                    placeDataManager.updateTimeTable(timetable: decodedPlace.timetable, for: place, modelContext: modelContext)
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
    }
}
