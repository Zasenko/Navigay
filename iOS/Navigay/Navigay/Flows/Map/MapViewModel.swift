//
//  MapViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 24.12.23.
//

import SwiftUI
import MapKit
import SwiftData

final class MapViewModel: ObservableObject {

    let events: [Event]
    let places: [Place]
    let categories: [SortingMapCategory]
    
    @Published var selectedCategory: SortingMapCategory = .all
    
    @Published var filteredPlaces: [Place] = []
    @Published var filteredEvents: [Event] = []
    
    @Published var selectedTag: UUID? = nil
    @Published var selectedPlace: Place? = nil
    @Published var selectedEvent: Event? = nil
    
    @Published var showInfo: Bool = false
    @Published var position: MapCameraPosition = .automatic
    
    var modelContext: ModelContext
    let placeDataManager: PlaceDataManagerProtocol
    let eventDataManager: EventDataManagerProtocol
    let eventNetworkManager: EventNetworkManagerProtocol
    let placeNetworkManager: PlaceNetworkManagerProtocol
    let errorManager: ErrorManagerProtocol
    
    init(events: [Event], places: [Place], categories: [SortingMapCategory], modelContext: ModelContext, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, placeDataManager: PlaceDataManagerProtocol, eventDataManager: EventDataManagerProtocol) {
        self.events = events
        self.places = places
        self.categories = categories
        self.modelContext = modelContext
        self.eventNetworkManager = eventNetworkManager
        self.placeNetworkManager = placeNetworkManager
        self.errorManager = errorManager
        self.placeDataManager = placeDataManager
        self.eventDataManager = eventDataManager
    }
}

extension MapViewModel {
    
    func filterLocations(category: SortingMapCategory) {
        selectedPlace = nil
        selectedEvent = nil
        selectedTag = nil
        switch category {
        case .bar:
            getPlaces(type: .bar)
        case .cafe:
            getPlaces(type: .cafe)
        case .restaurant:
            getPlaces(type: .restaurant)
        case .club:
            getPlaces(type: .club)
        case .hotel:
            getPlaces(type: .hotel)
        case .sauna:
            getPlaces(type: .sauna)
        case .cruiseBar:
            getPlaces(type: .cruiseBar)
        case .cruiseClub:
            getPlaces(type: .cruiseClub)
        case .beach:
            getPlaces(type: .beach)
        case .shop:
            getPlaces(type: .shop)
        case .gym:
            getPlaces(type: .gym)
        case .culture:
            getPlaces(type: .culture)
        case .community:
            getPlaces(type: .community)
        case .hostel:
            getPlaces(type: .hostel)
        case .medicine:
            getPlaces(type: .medicine)
        case .other:
            getPlaces(type: .other)
        case .events:
            filteredPlaces = []
            filteredEvents = events
        case .all:
            filteredPlaces = places
            filteredEvents = events
        case .rights:
            getPlaces(type: .rights)
        }
        withAnimation {
            position  = .automatic
            showInfo = false
        }
    }
    
    private func getPlaces(type: PlaceType) {
        filteredPlaces = places.filter( { $0.type == type } )
        filteredEvents = []
    }
}


