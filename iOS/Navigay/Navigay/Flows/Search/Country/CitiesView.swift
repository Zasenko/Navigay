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
    private let user: AppUser?
    @ObservedObject var authenticationManager: AuthenticationManager // TODO: убрать юзера из вью модели так как он в authenticationManager
    
    init(modelContext: ModelContext,
         cities: [City],
         catalogNetworkManager: CatalogNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         user: AppUser?,
         authenticationManager: AuthenticationManager) {
        self.modelContext = modelContext
        self.cities = cities
        self.catalogNetworkManager = catalogNetworkManager
        self.eventNetworkManager = eventNetworkManager
        self.placeNetworkManager = placeNetworkManager
        self.errorManager = errorManager
        self.user = user
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
    }
    
    var body: some View {
        Section {
            Section {
                ForEach(cities) { city in
                    NavigationLink {
                        CityView(modelContext: modelContext, city: city, catalogNetworkManager: catalogNetworkManager, eventNetworkManager: eventNetworkManager, placeNetworkManager: placeNetworkManager, errorManager: errorManager, user: user, authenticationManager: authenticationManager)
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
