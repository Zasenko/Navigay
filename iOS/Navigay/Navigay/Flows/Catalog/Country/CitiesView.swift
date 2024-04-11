//
//  CitiesView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import SwiftUI
import SwiftData

struct CitiesView: View {
    
    private var modelContext: ModelContext
    private var cities: [City]
    private let catalogNetworkManager: CatalogNetworkManagerProtocol
    private let eventNetworkManager: EventNetworkManagerProtocol
    private let placeNetworkManager: PlaceNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol
    private let placeDataManager: PlaceDataManagerProtocol
    private let eventDataManager: EventDataManagerProtocol
    private let catalogDataManager: CatalogDataManagerProtocol
    
    @ObservedObject var authenticationManager: AuthenticationManager
    
    init(modelContext: ModelContext,
         cities: [City],
         catalogNetworkManager: CatalogNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         authenticationManager: AuthenticationManager,
         placeDataManager: PlaceDataManagerProtocol,
         eventDataManager: EventDataManagerProtocol,
         catalogDataManager: CatalogDataManagerProtocol) {
        self.modelContext = modelContext
        self.cities = cities
        self.catalogNetworkManager = catalogNetworkManager
        self.eventNetworkManager = eventNetworkManager
        self.placeNetworkManager = placeNetworkManager
        self.errorManager = errorManager
        self.placeDataManager = placeDataManager
        self.eventDataManager = eventDataManager
        self.catalogDataManager = catalogDataManager
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
    }
    
    var body: some View {
        Section {
            Section {
                ForEach(cities) { city in
                    NavigationLink {
                        CityView(viewModel: CityView.CityViewModel(modelContext: modelContext, city: city, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager))
                    } label: {
                        CityCell(city: city, showCountryRegion: false)
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .listRowSeparator(.hidden)
        }
    }
}
