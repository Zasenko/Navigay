//
//  HomeView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @ObservedObject private var locationManager: LocationManager
    @State private var viewModel: HomeViewModel
    
    init(modelContext: ModelContext, networkManager: AroundNetworkManagerProtocol, locationManager: LocationManager, errorManager: ErrorManagerProtocol) {
        let viewModel = HomeViewModel(modelContext: modelContext, networkManager: networkManager, errorManager: errorManager)
        _viewModel = State(initialValue: viewModel)
        _locationManager = ObservedObject(wrappedValue: locationManager)
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.blue)
                    .frame(maxHeight: .infinity)
            } else {
                if viewModel.showMap {
                    MapView(events: $viewModel.aroundEvents, places: $viewModel.aroundPlaces, showMap: $viewModel.showMap, categories: $viewModel.sortingCategories, selectedCategory: $viewModel.selectedSortingCategory)
                } else {
                    MainView
                }
            }
        }
        .onChange(of: locationManager.userLocation, initial: true) { _, newValue in
            guard let userLocation = newValue else { return }
            viewModel.updateAroundPlacesAndEvents(userLocation: userLocation)
        }
    }
    
    private var MainView: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    Divider()
                    ListView(width: proxy.size.width)
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
                                viewModel.selectedSortingCategory = .all
                                viewModel.showMap.toggle()
                            }
                        } label: {
                            HStack {
                                Text("Show\non map")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.trailing)
                                
                                AppImages.iconLocation
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30, alignment: .leading)
                                   // .bold()
                            }
                            .tint(.primary)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func ListView(width: CGFloat) -> some View {
        List {
            if !viewModel.foundAround {
                VStack {
                    AppImages.iconSearchLocation
                        .font(.largeTitle)
                        .padding(.vertical)
                    Text("Unfortunately, we could not find any locations around you.")
                    
//                    Text("Ты можешь помочь сообществу и добавить места в базу")
//                        .padding(.vertical)
//                        .font(.headline)
                    Text("These are the list of locations nearest to you:")
                        .padding(.vertical)
                }
                .font(.title)
                .fontWeight(.light)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.vertical)
                .listRowSeparator(.hidden)
            }
            
            
            if viewModel.aroundEvents.count > 0 {
                Section {
                    Text("Upcoming events".uppercased())
                        .foregroundColor(.white)
                        .font(.caption)
                        .bold()
                        .modifier(CapsuleSmall(background: .red, foreground: .white))
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                        .padding()
                        .padding(.bottom)
                    LazyVGrid(columns: viewModel.gridLayout, spacing: 20) {
                        ForEach(viewModel.aroundEvents) { event in
                            EventCell(event: event, width: (width / 2) - 30, networkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeNetworkManager: viewModel.placeNetworkManager)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            
            ForEach(viewModel.groupedPlaces.keys.sorted(), id: \.self) { key in
                Section {
                    Text(key.getPluralName().uppercased())
                        .foregroundColor(.white)
                        .font(.caption)
                        .bold()
                        .modifier(CapsuleSmall(background: key.getColor(), foreground: .white))
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                    
                    ForEach(viewModel.groupedPlaces[key] ?? []) { place in
                        NavigationLink {
                            PlaceView(place: place, networkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager)
                        } label: {
                            PlaceCell(place: place)
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            Color.clear
                .frame(height: 50)
                .listSectionSeparator(.hidden)
        }
        .listSectionSeparator(.hidden)
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }
}

//#Preview {
//    let appSettingsManager = AppSettingsManager()
//    let networkManager = AroundNetworkManager(appSettingsManager: appSettingsManager)
//    let locationManager = LocationManager()
//    let errorManager = ErrorManager()
//    return HomeView(networkManager: networkManager, locationManager: locationManager, errorManager: errorManager)
//        .modelContainer(for: [Place.self, Event.self], inMemory: false)
//}
