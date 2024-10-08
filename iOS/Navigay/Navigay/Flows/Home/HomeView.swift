////
////  HomeView.swift
////  Navigay
////
////  Created by Dmitry Zasenko on 19.10.23.
////
//
//import SwiftUI
//import SwiftData
//import CoreLocation
//
//struct HomeView: View {
//    
//    // MARK: - Private Properties
//    
//    @EnvironmentObject private var locationManager: LocationManager
//    @State private var viewModel: HomeViewModel
//    @EnvironmentObject private var authenticationManager: AuthenticationManager
//    
//    @State private var showSorting: Bool = false
//    @State private var selectedSortedCategory: SortingCategory?
//    // MARK: - Init
//    
//    init(modelContext: ModelContext,
//         aroundNetworkManager: AroundNetworkManagerProtocol,
//         placeNetworkManager: PlaceNetworkManagerProtocol,
//         eventNetworkManager: EventNetworkManagerProtocol,
//         errorManager: ErrorManagerProtocol,
//         placeDataManager: PlaceDataManagerProtocol,
//         eventDataManager: EventDataManagerProtocol,
//         catalogDataManager: CatalogDataManagerProtocol) {
//        let viewModel = HomeViewModel(modelContext: modelContext, aroundNetworkManager: aroundNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager)
//        _viewModel = State(initialValue: viewModel)
//    }
//
//    // MARK: - Body
//    
//    var body: some View {
//        ZStack {
//            if viewModel.isLoading {
//                ProgressView()
//                    .tint(.blue)
//                    .frame(maxHeight: .infinity)
//            } else {
//                mainView
//                    .fullScreenCover(isPresented: $viewModel.showMap) {
//                        MapView(viewModel: MapViewModel(events: viewModel.todayEvents, places: viewModel.aroundPlaces, categories: viewModel.sortingMapCategories, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager))
//                    }
//                
//            }
//        }
//        .onChange(of: locationManager.userLocation, initial: true) { _, newValue in
//            guard let userLocation = newValue else { return }
//            viewModel.updateAroundPlacesAndEvents(userLocation: userLocation)
//        }
//        .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
//            viewModel.showCalendar = false
//            if let date = newValue {
//                fetchEvents(for: date)
//                //getEvents(for: date)
//            } else {
//                showUpcomingEvents()
//            }
//        }
//        .sheet(isPresented:  $viewModel.showCalendar) {} content: {
//            CalendarView(selectedDate: $viewModel.selectedDate, eventsDates: $viewModel.eventsDates)
//                .presentationDetents([.medium])
//                .presentationDragIndicator(.hidden)
//                .presentationCornerRadius(25)
//        }
//        .fullScreenCover(item: $viewModel.selectedEvent) { event in
//            EventView(viewModel: EventView.EventViewModel.init(event: event, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager))
//        }
//    }
//    
//    // MARK: - Views
//
//    private var mainView: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                if showSorting {
//                    VStack(spacing: 0) {
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            LazyHGrid(rows: [GridItem(.flexible(minimum: 100, maximum: 150))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, pinnedViews: []) {
//                                ForEach(viewModel.sortingHomeCategories, id: \.self) { category in
//                                    Button {
//                                        selectedSortedCategory = category
//                                    } label: {
//                                        HStack(spacing: 5) {
//                                            if !category.getImage().isEmpty {
//                                                Text(category.getImage())
//                                                    .font(.footnote)
//                                            }
//                                            Text(category.getName())
//                                                .font(.caption)
//                                                .bold()
//                                                .foregroundStyle(.primary)
//                                        }
//                                        .padding(5)
//                                        .padding(.horizontal, 5)
//                                        .background(AppColors.lightGray6)
//                                        .clipShape(.capsule)
//                                    }
//                                }
//                            }
//                            .padding(.horizontal)
//                            .frame(height: 50)
//                        }
//                        .frame(height: 50)
//                    }
//                    .transition(.move(edge: .top).combined(with: .opacity))
//                }
//                Divider()
//                listView
//            }
//            .animation(.easeInOut, value: showSorting)
//            .toolbarBackground(AppColors.background)
//            .toolbarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    HStack(alignment: .lastTextBaseline) {
//                        Text("Around you")
//                            .font(.title).bold()
//                        if viewModel.sortingHomeCategories.count > 1 {
//                            Button {
//                                withAnimation {
//                                    showSorting.toggle()
//                                }
//                            } label: {
//                                AppImages.iconDown
//                                    .font(.caption)
//                                    .fontWeight(.black)
//                                    .foregroundStyle(showSorting ? Color.secondary : .blue)
//                                    .rotationEffect(.degrees(showSorting ? -180 : 0))
//                            }
//                        }
//                    }
//                    .foregroundColor(.primary)
//                }
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                        withAnimation {
//                            viewModel.showMap.toggle()
//                        }
//                    } label: {
//                        AppImages.iconLocation
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 30, height: 30, alignment: .trailing)
//                            .tint(.blue)
//                    }
//                }
//            }
//        }
//    }
//    
//    private var listView: some View {
//        GeometryReader { proxy in
//            ScrollViewReader { scrollProxy in
//                List {
//                    if !viewModel.isLocationsAround20Found {
//                        notFountView
//                            .listRowSeparator(.hidden)
//                    }
//                    if viewModel.eventsCount > 0 {
//                        eventsView(size: proxy.size)
//                            .listRowSeparator(.hidden)
//                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                            .id(SortingCategory.events)
//                    }
//                    placesView
//                    Color.clear
//                        .frame(height: 50)
//                        .listSectionSeparator(.hidden)
//                }
//                .listSectionSeparator(.hidden)
//                .listStyle(.plain)
//                .scrollIndicators(.hidden)
//                .buttonStyle(PlainButtonStyle())
//                .onChange(of: selectedSortedCategory, initial: false) { oldValue, newValue in
//                    withAnimation {
//                        scrollProxy.scrollTo(newValue, anchor: .top)
//                    }
//                }
//                .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
//                    withAnimation {
//                        scrollProxy.scrollTo("UpcomingEvents", anchor: .top)
//                    }
//                }
//            }
//        }
//    }
//    
//    private var notFountView: some View {
//        VStack {
//            AppImages.iconSearchLocation
//                .font(.largeTitle)
//                .padding(.vertical)
//            Text("Unfortunately, we could not find any locations around you.")
//            //                    Text("Ты можешь помочь сообществу и добавить места в базу")
//            //                        .padding(.vertical)
//            //                        .font(.headline)
//            Text("These are the list of locations nearest to you:")
//                .padding(.vertical)
//        }
//        .font(.title2)
//        .fontWeight(.light)
//        .multilineTextAlignment(.center)
//        .foregroundStyle(.secondary)
//        .padding(.vertical)
//    }
//    
//    private func eventsView(size: CGSize) -> some View {
//        EventsView(modelContext: viewModel.modelContext, selectedDate: $viewModel.selectedDate, displayedEvents: $viewModel.displayedEvents, actualEvents: $viewModel.actualEvents, eventsCount: $viewModel.eventsCount, todayEvents: $viewModel.todayEvents, upcomingEvents: $viewModel.upcomingEvents, eventsDates: $viewModel.eventsDates, selectedEvent: $viewModel.selectedEvent, showCalendar: $viewModel.showCalendar, size: size)
//    }
//
//    private var placesView: some View {
//        ForEach(viewModel.groupedPlaces.keys.sorted(), id: \.self) { key in
//            Section {
//                Text(key.getPluralName())
//                    .font(.title)
//                    .foregroundStyle(.primary)
//                    .padding(.top, 50)
//                    .padding(.bottom, 10)
//                    .offset(x: 70)
//                ForEach(viewModel.groupedPlaces[key] ?? []) { place in
//                    NavigationLink {
//                        PlaceView(viewModel: PlaceView.PlaceViewModel(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, showOpenInfo: true))
//                    } label: {
//                        PlaceCell(place: place, showOpenInfo: viewModel.isLocationsAround20Found ? true : false, showDistance: true, showCountryCity: viewModel.isLocationsAround20Found ? false : true, showLike: true)
//                    }
//                }
//            }
//            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
//            .listRowSeparator(.hidden)
//            .id(key.getSortingMapCategory())
//        }
//    }
//    
//    private func fetchEvents(for date: Date) {
//        Task {
//            await viewModel.fetchEvents(for: date)
//        }
//    }
//    
////    private func getEvents(for date: Date) {
////        Task {
////            let events = await viewModel.eventDataManager.getEvents(for: date, events: viewModel.actualEvents )
////            await MainActor.run {
////                viewModel.displayedEvents = events
////            }
////        }
////    }
//    
//    private func showUpcomingEvents() {
//        viewModel.displayedEvents = viewModel.upcomingEvents
//    }
//}
//
////#Preview {
////    let appSettingsManager = AppSettingsManager()
////    let errorManager = ErrorManager()
////    let networkManager = AroundNetworkManager(appSettingsManager: appSettingsManager, errorManager: errorManager)
////    let locationManager = LocationManager()
////    
////    return HomeView(networkManager: networkManager, locationManager: locationManager, errorManager: errorManager)
////        .modelContainer(for: [Place.self, Event.self], inMemory: false)
////}
