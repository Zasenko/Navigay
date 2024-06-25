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
    private let placeDataManager: PlaceDataManagerProtocol
    private let eventDataManager: EventDataManagerProtocol
    private let catalogDataManager: CatalogDataManagerProtocol
    private let commentsNetworkManager: CommentsNetworkManagerProtocol
    private let notificationsManager: NotificationsManagerProtocol
    @EnvironmentObject private var authenticationManager: AuthenticationManager

    init(modelContext: ModelContext,
         region: Region,
         catalogNetworkManager: CatalogNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         placeDataManager: PlaceDataManagerProtocol,
         eventDataManager: EventDataManagerProtocol,
         catalogDataManager: CatalogDataManagerProtocol,
         commentsNetworkManager: CommentsNetworkManagerProtocol,
         notificationsManager: NotificationsManagerProtocol) {
        self.modelContext = modelContext
        self.region = region
        self.catalogNetworkManager = catalogNetworkManager
        self.eventNetworkManager = eventNetworkManager
        self.placeNetworkManager = placeNetworkManager
        self.errorManager = errorManager
        self.placeDataManager = placeDataManager
        self.eventDataManager = eventDataManager
        self.catalogDataManager = catalogDataManager
        self.commentsNetworkManager = commentsNetworkManager
        self.notificationsManager = notificationsManager
    }
    
    var body: some View {
        Section {
            HStack {
                AppImages.iconRegion
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                Text(region.name ?? "").bold()
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)
            .offset(x: 70)
            
            ForEach(region.cities.sorted(by: { $0.name < $1.name } )) { city in
                NavigationLink {
                    CityView(viewModel: CityView.CityViewModel(modelContext: modelContext, city: city, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager, commentsNetworkManager: commentsNetworkManager, notificationsManager: notificationsManager))
                } label: {
                    CityCell(city: city, showCountryRegion: false, showLocationsCount: true)
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .listRowSeparator(.hidden)
    }
}
