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
        var showInfo: Bool = false
        var position: MapCameraPosition = .automatic
        let placeNetworkManager: PlaceNetworkManagerProtocol //?????????
        let eventNetworkManager: EventNetworkManagerProtocol
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let errorManager: ErrorManagerProtocol

        //MARK: - Inits
        
        init(event: Event, modelContext: ModelContext, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, placeDataManager: PlaceDataManagerProtocol, eventDataManager: EventDataManagerProtocol) {
            self.event = event
            self.modelContext = modelContext
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
            position = .camera(MapCamera(centerCoordinate: event.coordinate, distance: 2000))
            loadEvent()
        }
        
        //MARK: - Functions
        
        func loadEvent() {
            debugPrint("loadEvent()")
            loadPoster()
            Task {
                guard !eventNetworkManager.loadedEvents.contains(where: { $0 == event.id}) else {
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
