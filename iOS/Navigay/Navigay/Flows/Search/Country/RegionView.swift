//
//  RegionView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import SwiftUI
import SwiftData

struct RegionView: View {
    
    private var modelContext: ModelContext
    private let region: Region
    private let catalogNetworkManager: CatalogNetworkManagerProtocol
    private let eventNetworkManager: EventNetworkManagerProtocol
    private let placeNetworkManager: PlaceNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol
    private let user: AppUser?
    @ObservedObject var authenticationManager: AuthenticationManager // TODO: убрать юзера из вью модели так как он в authenticationManager
    
    init(modelContext: ModelContext,
         region: Region,
         catalogNetworkManager: CatalogNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         user: AppUser?,
         authenticationManager: AuthenticationManager) {
        self.modelContext = modelContext
        self.region = region
        self.catalogNetworkManager = catalogNetworkManager
        self.eventNetworkManager = eventNetworkManager
        self.placeNetworkManager = placeNetworkManager
        self.errorManager = errorManager
        self.user = user
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
    }
    
    var body: some View {
        Section {
            Text(region.name ?? "")
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.top, 20)
                .offset(x: 70)
            ForEach(region.cities) { city in
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
