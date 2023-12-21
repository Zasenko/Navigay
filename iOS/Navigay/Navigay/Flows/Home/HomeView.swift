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
    
    // MARK: - Init
    
    init(modelContext: ModelContext,
         networkManager: AroundNetworkManagerProtocol,
         locationManager: LocationManager,
         errorManager: ErrorManagerProtocol) {
        let viewModel = HomeViewModel(modelContext: modelContext, networkManager: networkManager, errorManager: errorManager)
        _viewModel = State(wrappedValue: viewModel)
        _locationManager = ObservedObject(wrappedValue: locationManager)
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
                    MapView(events: $viewModel.todayAndTomorrowEvents, places: $viewModel.aroundPlaces, showMap: $viewModel.showMap, categories: $viewModel.sortingCategories, selectedCategory: $viewModel.selectedSortingCategory)
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
    
    // MARK: - Views
    
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
                                    .font(.caption).bold()
                                    .multilineTextAlignment(.trailing)
                                    .lineSpacing(-10)
                                AppImages.iconLocation
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
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
                EventsView(width: width)
            }
            PlacesView
            
            Color.clear
                .frame(height: 50)
                .listSectionSeparator(.hidden)
        }
        .listSectionSeparator(.hidden)
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func EventsView(width: CGFloat) -> some View {
        Section {
            HStack {
                Text("Upcoming events")
                    .font(.title3).bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    viewModel.showCalendar = true
                } label: {
                    HStack {
                        Text("Select\ndate")
                            .font(.caption)
                            .multilineTextAlignment(.trailing)
                            .lineSpacing(-10)
                        AppImages.iconCalendar
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                }
                .foregroundStyle(.blue)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
            LazyVGrid(columns: viewModel.gridLayout, spacing: 20) {
                ForEach(viewModel.displayedEvents) { event in
                    EventCell(event: event, width: (width / 2) - 30, networkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager)
                }
            }
            .padding(.horizontal, 20)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
            viewModel.showCalendar = false
            if let date = newValue {
                viewModel.getEvents(for: date)
            } else {
                viewModel.getUpcomingEvents()
            }
            
        }
        .sheet(isPresented:  $viewModel.showCalendar) {} content: {
            CalendarView(selectedDate: $viewModel.selectedDate, eventsDates: $viewModel.eventsDates)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(25)
        }
    }
    
    private var PlacesView: some View {
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
