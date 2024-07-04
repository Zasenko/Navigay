//
//  PlaceViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 23.12.23.
//

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
        
        var comments: [DecodedComment] = []
        var isCommentsLoading = true
        var showAddCommentView: Bool = false
        var showRegistrationView: Bool = false
        var showLoginView: Bool = false

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
        let notificationsManager: NotificationsManagerProtocol
        
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
             notificationsManager: NotificationsManagerProtocol,
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
            self.notificationsManager = notificationsManager
        }
        
        //MARK: - Functions
        
        func getEventsFromDB() {
            allPhotos = place.getAllPhotos()
            if place.lastUpdateComplite == nil {
                isLoading = true
                Task {
                    await fetchPlace()
                }
            } else {
                Task {
                    let events = place.events.sorted(by: { $0.id < $1.id })
                    let actualEvents = eventDataManager.getActualEvents(for: events)
                    let todayEvents = eventDataManager.getTodayEvents(from: actualEvents)
                    let upcomingEvents = eventDataManager.getUpcomingEvents(from: actualEvents)
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
        
        func showUpcomingEvents() {
            displayedEvents = upcomingEvents
        }
        
        func getEvents(for date: Date) {
            let events = eventDataManager.getEvents(for: date, events: place.events)
            displayedEvents = events
            Task {
                await fetchEvents(for: date)
            }
        }
        
        func fetchComments() {
            print("--------------------")
            print(placeDataManager.comments)
            print("----------------")

            if let comments = placeDataManager.comments[place] {
                self.comments = comments
                isCommentsLoading = false
            } else {
                Task {
                    let message = "Oops! Looks like the comments failed to load. Don't worry, we're actively working to resolve the issue."
                    do {
                        let decodedComments = try await commentsNetworkManager.fetchComments(placeID: place.id)
                        let activeComments = decodedComments.filter( { $0.isActive } )
                        placeDataManager.addComments(activeComments, for: place)
                        await MainActor.run {
                            comments = activeComments
                            isCommentsLoading = false
                        }
                    } catch NetworkErrors.noConnection {
                    } catch NetworkErrors.apiError(let apiError) {
                        errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
                    } catch {
                        errorManager.showError(model: ErrorModel(error: error, message: message))
                    }
                }
            }
        }
        
        func deleteComment(id: Int) {
            comments.removeAll(where: { $0.id == id})
            //commentsNetworkManager.
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
                return
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
            allPhotos = place.getAllPhotos()
            let eventsItems = eventDataManager.update(decodedEvents: decodedPlace.events, for: place, modelContext: modelContext)
            Task {
                let todayEventsSorted = eventsItems.today.sorted(by: { $0.id < $1.id })
                let upcomingEventsSorted = eventsItems.upcoming.sorted(by: { $0.id < $1.id }).sorted(by: { $0.startDate < $1.startDate })
                let activeDates = decodedPlace.events?.calendarDates?.compactMap( { $0.dateFromString(format: "yyyy-MM-dd") }) ?? []
                await MainActor.run {
                    self.upcomingEvents = upcomingEventsSorted
                    self.eventsDates = activeDates
                    self.todayEvents = todayEventsSorted
                    self.displayedEvents = upcomingEventsSorted
                    self.eventsCount = decodedPlace.events?.eventsCount ?? 0
                    self.place.eventsCount = decodedPlace.events?.eventsCount ?? 0
                    self.place.eventsDates = activeDates
                    self.isLoading = false
                }
            }
        }
        
        private func fetchEvents(for date: Date) async {
            let message = "Something went wrong. The information didn't update. Please try again later."
            do {
                let events = try await eventNetworkManager.fetchEvents(placeId: place.id, date: date)
                await MainActor.run {
                    let events = eventDataManager.update(decodedEvents: events, for: place, on: date, modelContext: modelContext)
                    self.displayedEvents = events
                }
            } catch NetworkErrors.apiError(let error) {
                if let error, error.show {
                    errorManager.showError(model: ErrorModel(error: NetworkErrors.api, message: error.message))
                } else {
                    errorManager.showError(model: ErrorModel(error: NetworkErrors.api, message: message))
                }
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: message))
            }
        }
    }
}
