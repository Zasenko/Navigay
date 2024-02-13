//
//  HomeView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    // MARK: - Private Properties
    
    @ObservedObject private var locationManager: LocationManager
    @State private var viewModel: HomeViewModel
    @ObservedObject var authenticationManager: AuthenticationManager
    
    // MARK: - Init
    
    init(modelContext: ModelContext,
         aroundNetworkManager: AroundNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         locationManager: LocationManager,
         errorManager: ErrorManagerProtocol,
         authenticationManager: AuthenticationManager) {
        _viewModel = State(initialValue: HomeViewModel(modelContext: modelContext, aroundNetworkManager: aroundNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager))
        _locationManager = ObservedObject(wrappedValue: locationManager)
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
    }

    // MARK: - Body
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.blue)
                    .frame(maxHeight: .infinity)
            } else {
                if viewModel.showMap {
                    MapView(viewModel: MapViewModel(showMap: $viewModel.showMap, events: $viewModel.todayEvents, places: $viewModel.aroundPlaces, categories: $viewModel.sortingMapCategories, selectedCategory: $viewModel.selectedMapSortingCategory))
                } else {
                    mainView
                }
            }
        }
        .onChange(of: locationManager.userLocation, initial: true) { _, newValue in
            guard let userLocation = newValue else { return }
            viewModel.updateAroundPlacesAndEvents(userLocation: userLocation)
        }
    }
    
    // MARK: - Views
    
    private var mainView: some View {
        NavigationStack {
                VStack(spacing: 0) {
                    listView
                }
                .toolbarBackground(AppColors.background)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Around you")
                            .font(.title).bold()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation {
                                viewModel.selectedMapSortingCategory = .all
                                viewModel.showMap.toggle()
                            }
                        } label: {
                            HStack {
                                AppImages.iconLocation
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                Text("Show\non map")
                                    .font(.caption).bold()
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(-10)
                            }
                            .tint(.blue)
                        }
                    }
                }
            
        }
    }
    
    private var listView: some View {
        GeometryReader { proxy in
            List {
                if !viewModel.isLocationsAround20Found {
                    notFountView
                        .listRowSeparator(.hidden)
                }
                if viewModel.actualEvents.count > 0 {
                    EventsView(modelContext: viewModel.modelContext, authenticationManager: authenticationManager, selectedDate: $viewModel.selectedDate, displayedEvents: $viewModel.displayedEvents, actualEvents: $viewModel.actualEvents, todayEvents: $viewModel.todayEvents, upcomingEvents: $viewModel.upcomingEvents, eventsDates: $viewModel.eventsDates, size: proxy.size, eventDataManager: viewModel.eventDataManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                placesView
                
                Color.clear
                    .frame(height: 50)
                    .listSectionSeparator(.hidden)
            }
            .listSectionSeparator(.hidden)
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var notFountView: some View {
        VStack {
            AppImages.iconSearchLocation
                .font(.largeTitle)
                .padding(.vertical)
            Text("Unfortunately, we could not find any locations around you.")
            // Ты можешь помочь сообществу и добавить места в базу
            Text("These are the list of locations nearest to you:")
                .padding(.vertical)
        }
        .font(.title2)
        .fontWeight(.light)
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)
        .padding(.vertical)
    }
    
    private var placesView: some View {
        ForEach(viewModel.groupedPlaces.keys.sorted(), id: \.self) { key in
            Section {
                Text(key.getPluralName())
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .padding(.top, 50)
                    .padding(.bottom, 10)
                    .offset(x: 70)
                ForEach(viewModel.groupedPlaces[key] ?? []) { place in
                    NavigationLink {
                        PlaceView(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager, showOpenInfo: true)
                    } label: {
                        PlaceCell(place: place, showOpenInfo: viewModel.isLocationsAround20Found ? true : false, showDistance: true, showCountryCity: viewModel.isLocationsAround20Found ? false : true, showLike: true)
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .listRowSeparator(.hidden)
        }
    }
}

//#Preview {
//    let appSettingsManager = AppSettingsManager()
//    let errorManager = ErrorManager()
//    let networkManager = AroundNetworkManager(appSettingsManager: appSettingsManager, errorManager: errorManager)
//    let locationManager = LocationManager()
//    
//    return HomeView(networkManager: networkManager, locationManager: locationManager, errorManager: errorManager)
//        .modelContainer(for: [Place.self, Event.self], inMemory: false)
//}
