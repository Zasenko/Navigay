//
//  HomeView2.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 28.05.24.
//

import SwiftUI
import SwiftData
import CoreLocation

struct HomeView: View {
    
    // MARK: - Properties

    @ObservedObject var aroundManager: AroundManager
    
    // MARK: - Private Properties
    
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext

    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                if aroundManager.isLoading {
                    ProgressView()
                        .tint(.blue)
                        .frame(maxHeight: .infinity)
                } else {
                    mainView
                        .fullScreenCover(isPresented: $aroundManager.showMap) {
                            MapView(viewModel: MapViewModel(events: aroundManager.todayEvents, places: aroundManager.aroundPlaces, categories: aroundManager.sortingMapCategories, modelContext: modelContext, placeNetworkManager: aroundManager.placeNetworkManager, eventNetworkManager: aroundManager.eventNetworkManager, errorManager: aroundManager.errorManager, placeDataManager: aroundManager.placeDataManager, eventDataManager: aroundManager.eventDataManager, commentsNetworkManager: aroundManager.commentsNetworkManager))
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
                if !(aroundManager.isLoading || locationManager.isAlertIfLocationDeniedDisplayed || !aroundManager.isLocationsAround20Found) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation {
                                aroundManager.showMap.toggle()
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
//            .onAppear() {
//                let category = aroundManager.selectedHomeSortingCategory
//                aroundManager.selectedHomeSortingCategory = .all
//                aroundManager.selectedHomeSortingCategory = category
//            }
            .sheet(isPresented:  $aroundManager.showCalendar) {} content: {
                CalendarView(selectedDate: $aroundManager.selectedDate, eventsDates: $aroundManager.eventsDates)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(25)
            }
            .fullScreenCover(item: $aroundManager.selectedEvent) { event in
                EventView(viewModel: EventView.EventViewModel.init(event: event, modelContext: modelContext, placeNetworkManager: aroundManager.placeNetworkManager, eventNetworkManager: aroundManager.eventNetworkManager, errorManager: aroundManager.errorManager, placeDataManager: aroundManager.placeDataManager, eventDataManager: aroundManager.eventDataManager, commentsNetworkManager: aroundManager.commentsNetworkManager))
            }
            .onChange(of: aroundManager.selectedDate, initial: false) { _, newValue in
                aroundManager.showCalendar = false
                if let date = newValue {
                    guard let userLocation = locationManager.userLocation else { return }
                    getEvents(for: date, userLocation: userLocation)
                } else {
                    aroundManager.displayedEvents = aroundManager.upcomingEvents
                }
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
                    if aroundManager.isLocationsAround20Found {
                        menuView
                        Divider()
                        if aroundManager.sortingHomeCategories.count > 0 {
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
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem()], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 0) {
                        ForEach(aroundManager.sortingHomeCategories, id: \.self) { category in
                            Button {
                                withAnimation(.easeIn) {
                                    aroundManager.selectedHomeSortingCategory = category
                                }
                            } label: {
                                Text(category.getName())
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.primary)
                                    .padding(5)
                                    .padding(.horizontal, 5)
                                    .background(aroundManager.selectedHomeSortingCategory == category ? AppColors.lightGray6 : .clear)
                                    .clipShape(.capsule)
                            }
                            .padding(.leading)
                            .id(category)
                        }
                    }
                    .padding(.trailing)
                }
                .frame(height: 40)
                .onChange(of: aroundManager.selectedHomeSortingCategory, initial: true) { oldValue, newValue in
                    withAnimation {
                        scrollProxy.scrollTo(newValue, anchor: .leading)
                    }
                }
            }
        }
    }

    private func tabView(size: CGSize) -> some View {
        TabView(selection: $aroundManager.selectedHomeSortingCategory) {
            ForEach(aroundManager.sortingHomeCategories, id: \.self) { category in
                categoryView(category: category, size: size)
                    .tag(category)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(width: .infinity, height: .infinity)
    }
        
    func categoryView(category: SortingCategory, size: CGSize) -> some View {
        ScrollViewReader { scrollProxy in
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
            .onChange(of: aroundManager.selectedDate, initial: false) { oldValue, newValue in
                withAnimation {
                    scrollProxy.scrollTo("UpcomingEvents", anchor: .top)
                }
            }
        }
    }
        
    private func eventsSection(size: CGSize) -> some View {
        EventsView(modelContext: modelContext, selectedDate: $aroundManager.selectedDate, displayedEvents: $aroundManager.displayedEvents, eventsCount: $aroundManager.eventsCount, todayEvents: $aroundManager.todayEvents, upcomingEvents: $aroundManager.upcomingEvents, eventsDates: $aroundManager.eventsDates, selectedEvent: $aroundManager.selectedEvent, showCalendar: $aroundManager.showCalendar, size: size, showLocation: true)
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
            ForEach(aroundManager.groupedPlaces[category] ?? []) { place in
                NavigationLink {
                    PlaceView(viewModel: PlaceView.PlaceViewModel(place: place, modelContext: modelContext, placeNetworkManager: aroundManager.placeNetworkManager, eventNetworkManager: aroundManager.eventNetworkManager, errorManager: aroundManager.errorManager, placeDataManager: aroundManager.placeDataManager, eventDataManager: aroundManager.eventDataManager, commentsNetworkManager: aroundManager.commentsNetworkManager, showOpenInfo: true))
                } label: {
                    PlaceCell(place: place, showOpenInfo: aroundManager.isLocationsAround20Found ? true : false, showDistance: true, showCountryCity: aroundManager.isLocationsAround20Found ? false : true, showLike: true)
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
                CitiesView(modelContext: modelContext, cities: aroundManager.citiesAround, showCountryRegion: true, catalogNetworkManager: aroundManager.catalogNetworkManager, eventNetworkManager: aroundManager.eventNetworkManager, placeNetworkManager: aroundManager.placeNetworkManager, errorManager: aroundManager.errorManager, authenticationManager: authenticationManager, placeDataManager: aroundManager.placeDataManager, eventDataManager: aroundManager.eventDataManager, catalogDataManager: aroundManager.catalogDataManager, commentsNetworkManager: aroundManager.commentsNetworkManager)
                
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
    
    // MARK: - Private Functions
    
    private func getEvents(for date: Date, userLocation: CLLocation) {
        let events = aroundManager.eventDataManager.getEvents(for: date, userLocation: userLocation, modelContext: modelContext)
        aroundManager.displayedEvents = events
        let ids = aroundManager.dateEvents.filter { $0.key == date }.flatMap { $0.value.map { $0 } }
        var savedEvents: [Event] = []
        var newIds: [Int] = []
        ids.forEach { id in
            if aroundManager.eventNetworkManager.loadedCalendarEventsId.contains(where: { $0 == id }) {
                if let event = aroundManager.eventDataManager.getEvent(id: id, modelContext: modelContext) {
                    savedEvents.append(event)
                } else {
                    newIds.append(id)
                }
            } else {
                newIds.append(id)
            }
        }
        guard !newIds.isEmpty else { return }
        
        Task {
            let message = "Something went wrong. The information didn't update. Please try again later."
            do {
                let items = try await aroundManager.fetchEvents(for: date, ids: newIds)
                await MainActor.run { [savedEvents] in
                    let countries = aroundManager.catalogDataManager.updateCountries(decodedCountries: items.countries, modelContext: modelContext)
                    let regions = aroundManager.catalogDataManager.updateRegions(decodedRegions: items.regions, countries: countries, modelContext: modelContext)
                    let cities = aroundManager.catalogDataManager.updateCities(decodedCities: items.cities, regions: regions, modelContext: modelContext)
                    var events = aroundManager.eventDataManager.updateEvents(decodedEvents: items.events, for: cities, modelContext: modelContext)
                    events.append(contentsOf: savedEvents)
                    aroundManager.displayedEvents = events
                }

            } catch NetworkErrors.apiError(let error) {
                if let error, error.show {
                    aroundManager.errorManager.showError(model: ErrorModel(error: NetworkErrors.api, message: error.message))
                } else {
                    aroundManager.errorManager.showError(model: ErrorModel(error: NetworkErrors.api, message: message))
                }
            } catch {
                aroundManager.errorManager.showError(model: ErrorModel(error: error, message: message))
            }
        }
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
