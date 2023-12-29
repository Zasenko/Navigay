//
//  MapViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 24.12.23.
//

import SwiftUI
import MapKit

final class MapViewModel: ObservableObject {

    @Binding var showMap: Bool
    @Binding var events: [Event]
    @Binding var places: [Place]
    @Binding var categories: [SortingMapCategory]
    @Binding var selectedCategory: SortingMapCategory
    
    @Published var filteredPlaces: [Place] = []
    @Published var filteredEvents: [Event] = []
    
    @Published var selectedTag: UUID? = nil //!!!!!!!!!!!!!!!
    @Published var selectedPlace: Place? = nil
    @Published var selectedEvent: Event? = nil
    
    @Published var showInfo: Bool = false
    @Published  var position: MapCameraPosition = .automatic
    
    init(showMap: Binding<Bool>, events: Binding<[Event]>, places: Binding<[Place]>, categories: Binding<[SortingMapCategory]>, selectedCategory: Binding<SortingMapCategory>) {
        _showMap = showMap
        _events = events
        _places = places
        _categories = categories
        _selectedCategory = selectedCategory
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
        }
        withAnimation(.spring()) {
            if filteredPlaces.count == 1, let place = filteredPlaces.first {
                selectedTag = place.tag
                showInfo = true
            } else if filteredPlaces.isEmpty, filteredEvents.count == 1, let event = filteredEvents.first {
                selectedTag = event.tag
                showInfo = true
            } else {
                position  = .automatic
                showInfo = false
            }
        }
    }
    
    private func getPlaces(type: PlaceType) {
        filteredPlaces = places.filter( { $0.type == type } )
        filteredEvents = []
//        let newFilteredPlaces = places.filter { $0.type == type }
//        
//        // Retain or add filteredPlaces that are present in the original places array
//        var updatedFilteredPlaces: [Place] = []
//        
//        filteredPlaces.forEach { place in
//            
//            if pla
//            
//            
//        }
//        
//        for filteredPlace in filteredPlaces {
//            
//            for newFilteredPlace in newFilteredPlaces {
//                
//                if
//                
//                if let matchingPlace = places.first(where: { $0 == filteredPlace }) {
//                    updatedFilteredPlaces.append(matchingPlace)
//                } else {
//                    
//                }
//                
//            }
//            
//        }
//        
//        self.filteredPlaces = updatedFilteredPlaces
//        self.filteredEvents = []
    }
}


