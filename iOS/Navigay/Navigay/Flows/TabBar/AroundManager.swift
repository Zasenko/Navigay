//
//  AroundManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 22.06.24.
//

import SwiftUI
import CoreLocation

final class AroundManager: ObservableObject {
    
    @Published var todayEvents: [Event] = []
    @Published var upcomingEvents: [Event] = []
    @Published var displayedEvents: [Event] = []
    @Published var eventsCount: Int = 0
    
    @Published var showCalendar: Bool = false
    @Published var eventsDates: [Date] = []
    @Published var selectedDate: Date? = nil
    @Published var dateEvents: [Date: [Int]] = [:]
    @Published var selectedEvent: Event?
    
    @Published var aroundPlaces: [Place] = [] /// for Map
    @Published var groupedPlaces: [SortingCategory: [Place]] = [:]
    
    @Published var locationUpdatedAtInit: Bool = false
    @Published var isLoading: Bool = true
    @Published var isLocationsAround20Found: Bool = true
    @Published var citiesAround: [City] = []
    
    @Published var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    
    @Published var showMap: Bool = false
    
    @Published var sortingHomeCategories: [SortingCategory] = []
    @Published var selectedHomeSortingCategory: SortingCategory = .all
    
    @Published var sortingMapCategories: [SortingCategory] = []
    
    let placeDataManager: PlaceDataManagerProtocol
    var eventDataManager: EventDataManagerProtocol
    let catalogDataManager: CatalogDataManagerProtocol
    
    let catalogNetworkManager: CatalogNetworkManagerProtocol
    let commentsNetworkManager: CommentsNetworkManagerProtocol
    let aroundNetworkManager: AroundNetworkManagerProtocol
    let eventNetworkManager: EventNetworkManagerProtocol
    let placeNetworkManager: PlaceNetworkManagerProtocol
    let errorManager: ErrorManagerProtocol
    let notificationsManager: NotificationsManagerProtocol
    
    // MARK: - Init
    
    init(aroundNetworkManager: AroundNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         catalogNetworkManager: CatalogNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         placeDataManager: PlaceDataManagerProtocol,
         eventDataManager: EventDataManagerProtocol,
         catalogDataManager: CatalogDataManagerProtocol,
         commentsNetworkManager: CommentsNetworkManagerProtocol,
         notificationsManager: NotificationsManagerProtocol) {
        self.aroundNetworkManager = aroundNetworkManager
        self.eventNetworkManager = eventNetworkManager
        self.placeNetworkManager = placeNetworkManager
        self.errorManager = errorManager
        self.placeDataManager = placeDataManager
        self.eventDataManager = eventDataManager
        self.catalogDataManager = catalogDataManager
        self.catalogNetworkManager = catalogNetworkManager
        self.commentsNetworkManager = commentsNetworkManager
        self.notificationsManager = notificationsManager
    }
    
}

extension AroundManager {
    
    
    // MARK: - Functions
        
    func fetch(userLocation: CLLocation) async throws -> AroundItemsResult {
        let decodedResult = try await aroundNetworkManager.fetchAround(location: userLocation)
        return decodedResult
    }
    
    func updateCategories() async {
        var mapCategories: [SortingCategory] = []
        var homeCategories: [SortingCategory] = []
        var selectedCategory: SortingCategory = .all
        if eventsCount > 0 {
            homeCategories.append(.events)
            selectedCategory = .events
        }
        
        let placesTypes = groupedPlaces.keys
        
        placesTypes.forEach { mapCategories.append($0) }
        placesTypes.forEach { homeCategories.append($0) }
        
        if !todayEvents.isEmpty {
            mapCategories.append(.events)
        }
        if mapCategories.count > 1 {
            mapCategories.append(.all)
        }
        
        let sortedMapCategories = mapCategories.sorted(by: {$0.getSortPreority() < $1.getSortPreority()})
        let sortedHomeCategories = homeCategories.sorted(by: {$0.getSortPreority() < $1.getSortPreority()})
        
        if selectedCategory != .events, let firstPlacesCategory = sortedHomeCategories.first {
            selectedCategory = firstPlacesCategory
        }
        
        await MainActor.run { [sortedMapCategories, sortedHomeCategories, selectedCategory] in
            withAnimation {
                sortingMapCategories = sortedMapCategories
                sortingHomeCategories = sortedHomeCategories
                selectedHomeSortingCategory = selectedCategory
                isLoading = false
            }
        }
    }
    
    func fetchEvents(for date: Date, ids: [Int]) async throws -> DecodedSearchItems {
        return try await eventNetworkManager.fetchEvents(ids: ids) 
    }
    
}
