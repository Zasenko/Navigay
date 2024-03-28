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
    @ObservedObject var authenticationManager: AuthenticationManager
    
    init(modelContext: ModelContext,
         region: Region,
         catalogNetworkManager: CatalogNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         authenticationManager: AuthenticationManager,
         placeDataManager: PlaceDataManagerProtocol,
         eventDataManager: EventDataManagerProtocol,
         catalogDataManager: CatalogDataManagerProtocol) {
        self.modelContext = modelContext
        self.region = region
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
            HStack(spacing: 20) {
                AppImages.iconRegion
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                Group {
                    Text("Region: ")
                    + Text(region.name ?? "").bold()
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }
            .padding(.top, 20)
            .offset(x: 30)
            
            ForEach(region.cities.sorted(by: { $0.name < $1.name } )) { city in
                NavigationLink {
                    CityView(modelContext: modelContext, city: city, catalogNetworkManager: catalogNetworkManager, eventNetworkManager: eventNetworkManager, placeNetworkManager: placeNetworkManager, errorManager: errorManager, authenticationManager: authenticationManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager)
                } label: {
                    CityCell(city: city, showCountryRegion: false)
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .listRowSeparator(.hidden)
    }
}
