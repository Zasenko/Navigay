//
//  HomeView2.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 28.05.24.
//

import SwiftUI
import SwiftData
import CoreLocation

struct HomeView2: View {
    
    // MARK: - Private Properties
    
    @EnvironmentObject private var locationManager: LocationManager
   // @StateObject private var locationManager: LocationManager
    @State private var viewModel: HomeViewModel2
    @EnvironmentObject private var authenticationManager: AuthenticationManager
   // @StateObject private var authenticationManager: AuthenticationManager
   // @State private var showSorting: Bool = true
    // MARK: - Init
    
    init(modelContext: ModelContext,
         aroundNetworkManager: AroundNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         catalogNetworkManager: CatalogNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         placeDataManager: PlaceDataManagerProtocol,
         eventDataManager: EventDataManagerProtocol,
         catalogDataManager: CatalogDataManagerProtocol) {
        let viewModel = HomeViewModel2(modelContext: modelContext, aroundNetworkManager: aroundNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, catalogNetworkManager: catalogNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager)
        _viewModel = State(initialValue: viewModel)
        
        //todo delete:
//        let keychainManager: KeychainManagerProtocol = KeychainManager()
//        let appSettingsManager: AppSettingsManagerProtocol = AppSettingsManager()
//        let networkMonitorManager: NetworkMonitorManagerProtocol = NetworkMonitorManager(errorManager: errorManager)
//        let authNetworkManager: AuthNetworkManagerProtocol = AuthNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//        _authenticationManager = StateObject(wrappedValue: AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: authNetworkManager, errorManager: errorManager))
//        _locationManager = StateObject(wrappedValue: LocationManager())
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.blue)
                        .frame(maxHeight: .infinity)
                } else {
                    mainView
                        .fullScreenCover(isPresented: $viewModel.showMap) {
                            MapView(viewModel: MapViewModel(events: viewModel.todayEvents, places: viewModel.aroundPlaces, categories: viewModel.sortingMapCategories, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager))
                        }
                }
            }
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Around you")
                        .font(.title).bold()
                        .foregroundColor(.primary)
                }
                
                if !(viewModel.isLoading || locationManager.isAlertIfLocationDeniedDisplayed || !viewModel.isLocationsAround20Found) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation {
                                viewModel.showMap.toggle()
                            }
                        } label: {
                            AppImages.iconLocation
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30, alignment: .trailing)
                                .tint(.blue)
                        }
                    }
                }
            }
            .task(priority: .high) {
                await MainActor.run {
                    let category = viewModel.selectedHomeSortingCategory
                    viewModel.selectedHomeSortingCategory = .all
                    viewModel.selectedHomeSortingCategory = category
                }
                if let userLocation = locationManager.userLocation {
                    viewModel.updateAtInit(userLocation: userLocation)
                }
            }
            .onChange(of: locationManager.userLocation, initial: false) { _, newValue in
                 guard let userLocation = newValue else { return }
                 viewModel.update(userLocation: userLocation)
            }
            .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
                viewModel.showCalendar = false
                if let date = newValue {
                    guard let userLocation = locationManager.userLocation else { return }
                    viewModel.getEvents(for: date, userLocation: userLocation)
                } else {
                    viewModel.displayedEvents = viewModel.upcomingEvents
                }
            }
            .sheet(isPresented:  $viewModel.showCalendar) {} content: {
                CalendarView(selectedDate: $viewModel.selectedDate, eventsDates: $viewModel.eventsDates)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(25)
            }
            .fullScreenCover(item: $viewModel.selectedEvent) { event in
                EventView(viewModel: EventView.EventViewModel.init(event: event, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager))
            }
        }
    }
    
    // MARK: - Views
        
    private var mainView: some View {
        GeometryReader { geomentry in
            if locationManager.isAlertIfLocationDeniedDisplayed {
                noLocationView
            } else {
                VStack(spacing: 0) {
                    if viewModel.isLocationsAround20Found {
                        menuView
                        Divider()
                        if viewModel.sortingHomeCategories.count > 0 {
                            tabView(size: geomentry.size)
                        }
                    } else {
                        notFoundView
                    }
                }
            }
        }
    }
    
    private var menuView: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.flexible(minimum: 100, maximum: 150))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, pinnedViews: []) {
                    ForEach(viewModel.sortingHomeCategories, id: \.self) { category in
                        Button {
                            withAnimation(.easeIn) {
                                viewModel.selectedHomeSortingCategory = category
                            }
                        } label: {
                            Text(category.getName())
                                .font(.caption)
                                .bold()
                                .foregroundStyle(.primary)
                                .padding(5)
                                .padding(.horizontal, 5)
                                .background(viewModel.selectedHomeSortingCategory == category ? AppColors.lightGray6 : .clear)
                                .clipShape(.capsule)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 40)
        }
    }

    private func tabView(size: CGSize) -> some View {
        TabView(selection: $viewModel.selectedHomeSortingCategory) {
            ForEach(viewModel.sortingHomeCategories, id: \.self) { category in
                categoryView(category: category, size: size)
                    .tag(category)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(width: .infinity, height: .infinity)
    }
        
    func categoryView(category: SortingCategory, size: CGSize) -> some View {
        List {
            switch category {
            case .events:
                eventsSection(size: size)
            default:
                placesSection(category: category)
            }
            Color.clear
                .frame(height: 50)
                .listSectionSeparator(.hidden)
        }
        .scrollIndicators(.hidden)
        .listSectionSeparator(.hidden)
        .listStyle(.plain)
        .buttonStyle(PlainButtonStyle())
    }
    
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
    
    private func eventsSection(size: CGSize) -> some View {
        EventsView(modelContext: viewModel.modelContext, selectedDate: $viewModel.selectedDate, displayedEvents: $viewModel.displayedEvents, actualEvents: $viewModel.actualEvents, eventsCount: $viewModel.eventsCount, todayEvents: $viewModel.todayEvents, upcomingEvents: $viewModel.upcomingEvents, eventsDates: $viewModel.eventsDates, selectedEvent: $viewModel.selectedEvent, showCalendar: $viewModel.showCalendar, size: size)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    private func placesSection(category: SortingCategory) -> some View {
        Section {
            Text(category.getPluralName())
                .font(.title2)
                .bold()
                .foregroundStyle(.primary)
                .offset(x: 70)
                .padding(.vertical)
            ForEach(viewModel.groupedPlaces[category] ?? []) { place in
                NavigationLink {
                    PlaceView(viewModel: PlaceView.PlaceViewModel(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, showOpenInfo: true))
                } label: {
                    PlaceCell(place: place, showOpenInfo: viewModel.isLocationsAround20Found ? true : false, showDistance: true, showCountryCity: viewModel.isLocationsAround20Found ? false : true, showLike: true)
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .listRowSeparator(.hidden)
    }
    
    private var notFoundView: some View {
        List {
            Section {
                VStack {
                    AppImages.iconSearchLocation
                        .font(.largeTitle)
                        .padding(.vertical)
                    Text("Unfortunately, we could not find any locations around you.")
                        .font(.title3)
                    Text("These are the list of cities nearest to you:")
                        .font(.title3)
                        .padding(.vertical)
                }
                .fontWeight(.light)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                CitiesView(modelContext: viewModel.modelContext, cities: viewModel.citiesAround, showCountryRegion: true, catalogNetworkManager: viewModel.catalogNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, catalogDataManager: viewModel.catalogDataManager)
                
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .listRowSeparator(.hidden)
//            Text("Ты можешь помочь сообществу и добавить места в базу")
//                .padding(.vertical)
//                .font(.headline)
            
        }
        .scrollIndicators(.hidden)
        .listSectionSeparator(.hidden)
        .listStyle(.plain)
        .buttonStyle(PlainButtonStyle())

    }
    
    private var noLocationView: some View {
        VStack(spacing: 0) {
            Text("Location Access")
                .font(.title)
                .padding(.vertical)
            Text("To provide accurate search results, this app needs access to your location. Would you like to go to Settings to enable location access?")
                .font(.title2)
                .fontWeight(.light)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.vertical)
            Button {
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                UIApplication.shared.open(url)
            } label: {
                Label(
                    title: { Text("Go to Settings") },
                    icon: { AppImages.iconSettings }
                )
            }
            .padding()
            .background(AppColors.lightGray6)
            .clipShape(Capsule())
            .padding(.vertical)
        }
        .padding()
    }
}

//#Preview {
//    let errorManager: ErrorManagerProtocol = ErrorManager()
//
//    let keychainManager: KeychainManagerProtocol = KeychainManager()
//let appSettingsManager: AppSettingsManagerProtocol = AppSettingsManager()
//    let networkMonitorManager: NetworkMonitorManagerProtocol = NetworkMonitorManager(errorManager: errorManager)
//    
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            AppUser.self, Country.self, Region.self, City.self, Event.self, Place.self, User.self
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
//    let aroundNetworkManager = AroundNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//    let placeNetworkManager = PlaceNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//    let eventNetworkManager = EventNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//    
//    let placeDataManager = PlaceDataManager()
//    let eventDataManager = EventDataManager()
//    let catalogDataManager = CatalogDataManager()
//    
//   return HomeView2(modelContext: ModelContext(sharedModelContainer), aroundNetworkManager: aroundNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager)
//}
