//
//  CitiesView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import SwiftUI
import SwiftData

struct CitiesView: View {
    
    private var cities: [City]
    private let showCountryRegion: Bool
    
    private var modelContext: ModelContext
    private let catalogNetworkManager: CatalogNetworkManagerProtocol
    private let eventNetworkManager: EventNetworkManagerProtocol
    private let placeNetworkManager: PlaceNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol
    private let placeDataManager: PlaceDataManagerProtocol
    private let eventDataManager: EventDataManagerProtocol
    private let catalogDataManager: CatalogDataManagerProtocol
    private let commentsNetworkManager: CommentsNetworkManagerProtocol

    @ObservedObject var authenticationManager: AuthenticationManager
    
    init(modelContext: ModelContext,
         cities: [City],
         showCountryRegion: Bool,
         catalogNetworkManager: CatalogNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         authenticationManager: AuthenticationManager,
         placeDataManager: PlaceDataManagerProtocol,
         eventDataManager: EventDataManagerProtocol,
         catalogDataManager: CatalogDataManagerProtocol,
         commentsNetworkManager: CommentsNetworkManagerProtocol) {
        self.modelContext = modelContext
        self.cities = cities
        self.showCountryRegion = showCountryRegion
        
        self.catalogNetworkManager = catalogNetworkManager
        self.eventNetworkManager = eventNetworkManager
        self.placeNetworkManager = placeNetworkManager
        self.errorManager = errorManager
        self.placeDataManager = placeDataManager
        self.eventDataManager = eventDataManager
        self.catalogDataManager = catalogDataManager
        self.commentsNetworkManager = commentsNetworkManager

        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
    }
    
    var body: some View {
        Section {
            Section {
                ForEach(cities) { city in
                    NavigationLink {
                        CityView(viewModel: CityView.CityViewModel(modelContext: modelContext, city: city, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager, commentsNetworkManager: commentsNetworkManager))
                    } label: {
                        CityCell(city: city, showCountryRegion: showCountryRegion, showLocationsCount: true)
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .listRowSeparator(.hidden)
        }
    }
}
