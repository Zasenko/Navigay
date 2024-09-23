//
//  OrganizerViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 22.09.24.
//

import Foundation
import SwiftData
import SwiftUI

extension OrganizerView {
    
    @Observable
    class OrganizerViewModel {
        
        //MARK: - Properties
        
        var isLoading: Bool = false
        
        var showHeaderTitle: Bool = false
        
        var modelContext: ModelContext
        var organizer: Organizer
        
        var allPhotos: [String] = []
        
        var comments: [DecodedComment] = []
        var isCommentsLoading = true
        var showAddCommentView: Bool = false
        var showRegistrationView: Bool = false
        var showLoginView: Bool = false

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
                
        let organizerNetworkManager: OrganizerNetworkManagerProtocol
        let commentsNetworkManager: CommentsNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        
        let placeDataManager: PlaceDataManagerProtocol
        let organizerDataManager: OrganizerDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let notificationsManager: NotificationsManagerProtocol
        
        var showAddEventView: Bool = false
        var showEditView: Bool = false
        
        //MARK: - Init
        
        init(organizer: Organizer,
             modelContext: ModelContext,
             organizerNetworkManager: OrganizerNetworkManagerProtocol,
             eventNetworkManager: EventNetworkManagerProtocol,
             errorManager: ErrorManagerProtocol,
             organizerDataManager: OrganizerDataManagerProtocol,
             eventDataManager: EventDataManagerProtocol,
             commentsNetworkManager: CommentsNetworkManagerProtocol,
             notificationsManager: NotificationsManagerProtocol,
             placeNetworkManager: PlaceNetworkManagerProtocol,
             placeDataManager: PlaceDataManagerProtocol,
             showOpenInfo: Bool) {
            self.organizer = organizer
            self.modelContext = modelContext
            self.eventNetworkManager = eventNetworkManager
            self.organizerNetworkManager = organizerNetworkManager
            self.errorManager = errorManager
            self.organizerDataManager = organizerDataManager
            self.eventDataManager = eventDataManager
            self.commentsNetworkManager = commentsNetworkManager
            self.notificationsManager = notificationsManager
            self.placeNetworkManager = placeNetworkManager
            self.placeDataManager = placeDataManager
        }
        
        //MARK: - Functions
        
        func getEventsFromDB() {
            allPhotos = organizer.getAllPhotos()
            if let result = organizerDataManager.loadedOrganizers[organizer] {
                self.todayEvents = result.todayEvents
                self.displayedEvents = result.upcomingEvents
                self.upcomingEvents = result.upcomingEvents
                self.eventsDates = organizer.eventsDates
                self.eventsCount = organizer.eventsCount
            } else {
                Task {
                    let events = organizer.events.sorted(by: { $0.id < $1.id })
                    let actualEvents = eventDataManager.getActualEvents(for: events)
                    let todayEvents = eventDataManager.getTodayEvents(from: actualEvents)
                    let upcomingEvents = eventDataManager.getUpcomingEvents(from: actualEvents)
                    await MainActor.run {
                        self.upcomingEvents = upcomingEvents
                        self.eventsDates = organizer.eventsDates
                        self.eventsCount = organizer.eventsCount
                        self.todayEvents = todayEvents
                        self.displayedEvents = upcomingEvents
                    }
                    await fetchOrganizer()
                }
            }
//            if place.lastUpdateComplite == nil {
//                isLoading = true
//                Task {
//                    await fetchPlace()
//                }
//            } else {
//                Task {
//                    let events = place.events.sorted(by: { $0.id < $1.id })
//                    let actualEvents = eventDataManager.getActualEvents(for: events)
//                    let todayEvents = eventDataManager.getTodayEvents(from: actualEvents)
//                    let upcomingEvents = eventDataManager.getUpcomingEvents(from: actualEvents)
//                    await MainActor.run {
//                        self.upcomingEvents = upcomingEvents
//                        self.eventsDates = place.eventsDates
//                        self.eventsCount = place.eventsCount
//                        self.todayEvents = todayEvents
//                        self.displayedEvents = upcomingEvents
//                    }
//                   await fetchPlace()
//                }
//            }
        }
        
        func showUpcomingEvents() {
            displayedEvents = upcomingEvents
        }
        
        func getEvents(for date: Date) {
            let events = eventDataManager.getEvents(for: date, events: organizer.events)
            displayedEvents = events
            Task {
               // await fetchEvents(for: date)
            }
        }
        
//        func fetchComments() {
//            if let comments = placeDataManager.loadedComments[place] {
//                self.comments = comments
//                isCommentsLoading = false
//            } else {
//                Task {
//                    let message = "Oops! Looks like the comments failed to load. Don't worry, we're actively working to resolve the issue."
//                    do {
//                        let decodedComments = try await commentsNetworkManager.fetchComments(placeID: place.id)
//                        let activeComments = decodedComments.filter( { $0.isActive } )
//                        placeDataManager.addLoadedComments(activeComments, for: place)
//                        await MainActor.run {
//                            comments = activeComments
//                            isCommentsLoading = false
//                        }
//                    } catch NetworkErrors.noConnection {
//                    } catch NetworkErrors.apiError(let apiError) {
//                        errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
//                    } catch {
//                        errorManager.showError(model: ErrorModel(error: error, message: message))
//                    }
//                }
//            }
//        }
        
        // when reporting
//        func deleteComment(id: Int) {
//            comments.removeAll(where: { $0.id == id})
//            placeDataManager.deleteLoadedComment(id: id, for: place)
//        }
        
        //todo deleteComment + api
        
        private func fetchOrganizer() async {
            await MainActor.run {
                isLoading = true
            }
            do {
                let decodedOrganizer = try await organizerNetworkManager.fetchOrganizer(id: organizer.id)
                await MainActor.run {
               //     updateFetchedResult(decodedOrganizer: decodedOrganizer)
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
        
//        private func updateFetchedResult(decodedOrganizer: DecodedOrganizer) {
//           // organizerDataManager.update(place: place, decodedPlace: decodedPlace, modelContext: modelContext)
//            allPhotos = organizer.getAllPhotos()
//            let eventsItems = eventDataManager.update(decodedEvents: decodedPlace.events, for: place, modelContext: modelContext)
//            Task {
//                let todayEventsSorted = eventsItems.today.sorted(by: { $0.id < $1.id })
//                let upcomingEventsSorted = eventsItems.upcoming.sorted(by: { $0.id < $1.id }).sorted(by: { $0.startDate < $1.startDate })
//                let activeDates = decodedPlace.events?.calendarDates?.compactMap( { $0.dateFromString(format: "yyyy-MM-dd") }) ?? []
//                await MainActor.run {
//                    self.todayEvents = todayEventsSorted
//                    self.displayedEvents = upcomingEventsSorted
//                    self.place.eventsCount = decodedPlace.events?.eventsCount ?? 0
//                    self.place.eventsDates = activeDates
//                    self.eventsCount = decodedPlace.events?.eventsCount ?? 0
//                    self.eventsDates = activeDates
//                    self.upcomingEvents = upcomingEventsSorted
//                    self.isLoading = false
//                }
//                placeDataManager.addLoadedPlace(place, with: PlaceItems(todayEvents: todayEventsSorted, upcomingEvents: upcomingEventsSorted))
//            }
//        }
        
//        private func fetchEvents(for date: Date) async {
//            let message = "Something went wrong. The information didn't update. Please try again later."
//            do {
//                let events = try await eventNetworkManager.fetchEvents(placeId: place.id, date: date)
//                await MainActor.run {
//                    let events = eventDataManager.update(decodedEvents: events, for: place, on: date, modelContext: modelContext)
//                    events.forEach( { eventDataManager.addLoadedCalendarEvents($0) } )
//                    self.displayedEvents = events
//                }
//            } catch NetworkErrors.apiError(let error) {
//                if let error, error.show {
//                    errorManager.showError(model: ErrorModel(error: NetworkErrors.api, message: error.message))
//                } else {
//                    errorManager.showError(model: ErrorModel(error: NetworkErrors.api, message: message))
//                }
//            } catch {
//                errorManager.showError(model: ErrorModel(error: error, message: message))
//            }
//        }
    }
}
