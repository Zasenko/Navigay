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
    @ObservedObject var authenticationManager: AuthenticationManager // TODO: убрать юзера из вью модели так как он в authenticationManager
    
    // MARK: - Init
    
    init(modelContext: ModelContext,
         aroundNetworkManager: AroundNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         locationManager: LocationManager,
         errorManager: ErrorManagerProtocol,
         user: AppUser?,
         authenticationManager: AuthenticationManager) {
        _viewModel = State(initialValue: HomeViewModel(modelContext: modelContext, aroundNetworkManager: aroundNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, user: user))
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
                    MapView(viewModel: MapViewModel(showMap: $viewModel.showMap, events: $viewModel.todayAndTomorrowEvents, places: $viewModel.aroundPlaces, categories: $viewModel.sortingCategories, selectedCategory: $viewModel.selectedSortingCategory))
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
    
    @ViewBuilder
    private func EventsView(width: CGFloat) -> some View {
        Section {
            HStack {
                Text(viewModel.selectedDate?.formatted(date: .long, time: .omitted) ?? "Upcoming events")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    viewModel.showCalendar = true
                } label: {
                    HStack {
                        AppImages.iconCalendar
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        Text("Select date")
                            .font(.caption)
                            .multilineTextAlignment(.trailing)
                            .lineSpacing(-10)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
                }
               // .buttonStyle(.borderedProminent)
                //.foregroundStyle(.blue)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
            LazyVGrid(columns: viewModel.gridLayout, spacing: 20) {
                ForEach(viewModel.displayedEvents) { event in
                    EventCell(event: event, width: (width / 2) - 30, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, showCountryCity: false)
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
    
    private var placesView: some View {
        ForEach(viewModel.groupedPlaces.keys.sorted(), id: \.self) { key in
            Section {
//                Text(key.getPluralName().uppercased())
//                    .foregroundColor(.white)
//                    .font(.caption)
//                    .bold()
//                    .modifier(CapsuleSmall(background: key.getColor(), foreground: .white))
//                    .frame(maxWidth: .infinity)
//                    .padding(.top)
                Text(key.getPluralName())
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .padding(.top, 50)
                    .padding(.bottom, 10)
                    .offset(x: 70)
                ForEach(viewModel.groupedPlaces[key] ?? []) { place in
                    NavigationLink {
                        PlaceView(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager)
                    } label: {
                        PlaceCell(place: place, showOpenInfo: true, showDistance: true, showCountryCity: false)
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
