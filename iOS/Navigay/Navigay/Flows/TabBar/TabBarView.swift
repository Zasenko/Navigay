//
//  TabBarView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 04.10.23.
//

import SwiftUI
import CoreLocation
import SwiftData

enum TabBarRouter {
    case home, catalog, search, user, admin
}

struct TabBarView: View {
    
    // MARK: - Private Properties
    
    @State private var selectedPage: TabBarRouter = TabBarRouter.home
    @State private var userImage: Image? = nil
    @StateObject private var locationManager: LocationManager
    @StateObject private var aroundManager: AroundManager
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    
    private let homeButton = TabBarButton(title: "Around Me", img: AppImages.iconHome, page: .home)
    private let catalogButton = TabBarButton(title: "Catalog", img: AppImages.iconCatalog, page: .catalog)
    private let searchButton = TabBarButton(title: "Search", img: AppImages.iconSearch, page: .search)
    private let userButton = TabBarButton(title: "Around Me", img: AppImages.iconPerson, page: .user)
    private let adminButton = TabBarButton(title: "Admin Panel", img: AppImages.iconAdmin, page: .admin)
    
    private let errorManager: ErrorManagerProtocol
    private let aroundNetworkManager: AroundNetworkManagerProtocol
    private let catalogNetworkManager: CatalogNetworkManagerProtocol
    private let placeNetworkManager: PlaceNetworkManagerProtocol
    private let eventNetworkManager: EventNetworkManagerProtocol
    private let commentsNetworkManager: CommentsNetworkManagerProtocol
    private let placeDataManager: PlaceDataManagerProtocol
    private let eventDataManager: EventDataManagerProtocol
    private let catalogDataManager: CatalogDataManagerProtocol
    
    //MARK: - Init
    
    init(errorManager: ErrorManagerProtocol, networkManager: NetworkManagerProtocol, locationManager: LocationManager = LocationManager()) {
        self.errorManager = errorManager
        self.aroundNetworkManager = AroundNetworkManager(networkManager: networkManager)
        self.catalogNetworkManager = CatalogNetworkManager(networkManager: networkManager)
        self.eventNetworkManager = EventNetworkManager(networkManager: networkManager)
        self.placeNetworkManager = PlaceNetworkManager(networkManager: networkManager)
        self.commentsNetworkManager = CommentsNetworkManager(networkManager: networkManager)
        self.placeDataManager = PlaceDataManager()
        self.eventDataManager = EventDataManager()
        self.catalogDataManager = CatalogDataManager()
        let aroundManager = AroundManager(aroundNetworkManager: aroundNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, catalogNetworkManager: catalogNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager, commentsNetworkManager: commentsNetworkManager)
        _locationManager = StateObject(wrappedValue: locationManager)
        _aroundManager = StateObject(wrappedValue: aroundManager)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            switch selectedPage {
            case .home:
                HomeView(aroundManager: aroundManager)
                    .environmentObject(locationManager)
            case .catalog:
                CatalogView(viewModel: CatalogView.CatalogViewModel(modelContext: modelContext, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager, commentsNetworkManager: commentsNetworkManager))
            case .search:
                SearchView(viewModel: SearchView.SearchViewModel(modelContext: modelContext, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager, commentsNetworkManager: commentsNetworkManager))
            case .user:
                AppUserView(modelContext: modelContext, userNetworkManager: UserNetworkManager(networkManager: authenticationManager.networkManager), placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, commentsNetworkManager: commentsNetworkManager)
            case .admin:
                if let user = authenticationManager.appUser, (user.status == .admin || user.status == .moderator) {
                    AdminView(viewModel: AdminViewModel(user: user, errorManager: errorManager, networkManager: AdminNetworkManager(networkManager: authenticationManager.networkManager)))
                } else {
                    EmptyView()
                }
            }
            tabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: authenticationManager.appUser?.photo, initial: true) { _, newValue in
            guard let url = newValue else {
                self.userImage = nil
                return
            }
            Task {
                if let image = await ImageLoader.shared.loadImage(urlString: url) {
                    await MainActor.run {
                        self.userImage = image
                    }
                }
            }
        }
        .onChange(of: locationManager.userLocation, initial: true) { _, newValue in
            if let userLocation = newValue {
                getFromDb(userLocation: userLocation)
                fetch(userLocation: userLocation)
            } else {
                if locationManager.lastLatitude != 0 && locationManager.lastLongitude != 0 {
                    let userLocation = CLLocation(latitude: locationManager.lastLatitude, longitude: locationManager.lastLongitude)
                    getFromDb(userLocation: userLocation)
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var tabBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 40) {
                TabBarButtonView(selectedPage: $selectedPage, button: homeButton)
                TabBarButtonView(selectedPage: $selectedPage, button: catalogButton)
                TabBarButtonView(selectedPage: $selectedPage, button: searchButton)
                if let img = userImage {
                    Button {
                        selectedPage = .user
                    } label: {
                        img
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .clipShape(Circle())
                            .padding(3)
                            .overlay(
                                Circle()
                                    .stroke(selectedPage == .user ? authenticationManager.isUserOnline ? .green : .red : AppColors.lightGray5, lineWidth: selectedPage == .user ? 3 : 2)
                            )
                    }
                } else {
                    Button {
                        selectedPage = .user
                    } label: {
                        userButton.img
                            .resizable()
                            .scaledToFit()
                            .frame(width: authenticationManager.appUser == nil ? 25 : 22, height: authenticationManager.appUser == nil ? 25 : 22)
                            .clipShape(Circle())
                            .foregroundColor(selectedPage == .user ? .primary : AppColors.lightGray5)
                            .bold()
                            .padding(authenticationManager.appUser == nil ? 0 : 3)
                            .overlay(
                                Circle()
                                    .stroke(authenticationManager.appUser == nil ? .clear : selectedPage == .user ? authenticationManager.isUserOnline ? .green : .red : AppColors.lightGray5, lineWidth: selectedPage == .user ? 3 : 2)
                            )
                    }
                }
                if let user = authenticationManager.appUser, (user.status == .admin || user.status == .moderator) {
                    TabBarButtonView(selectedPage: $selectedPage, button: adminButton)
                }
            }
            .padding(.top, 10)
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }
    
    
    // MARK: - Private Functions
    
    private func fetch(userLocation: CLLocation) {
        Task {
            let message = "Something went wrong. The information didn't update. Please try again later."
            do {
                let result = try await aroundManager.fetch(userLocation: userLocation)
                await MainActor.run {
                    update(decodedResult: result, userLocation: userLocation)
                }
            } catch NetworkErrors.apiError(let error) {
                if let error, error.show {
                    errorManager.showError(model: ErrorModel(error: NetworkErrors.api, message: error.message))
                } else {
                    errorManager.showError(model: ErrorModel(error: NetworkErrors.api, message: message))
                }
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: message))
            }
        }
    }
    
    private func getFromDb(userLocation: CLLocation) {
        Task {
            let radius: Double = 20000
            
            let allPlaces = placeDataManager.getAllPlaces(modelContext: modelContext)
            let allEvents = eventDataManager.getAllEvents(modelContext: modelContext)
            
            let aroundPlaces = await placeDataManager.getAroundPlaces(radius: radius, allPlaces: allPlaces, userLocation: userLocation)
            let aroundEvents = await eventDataManager.getAroundEvents(radius: radius, allEvents: allEvents, userLocation: userLocation)
            
            if !aroundPlaces.isEmpty || !aroundEvents.isEmpty {
                let groupedPlaces = await placeDataManager.createHomeGroupedPlaces(places: aroundPlaces)
                let actualEvents = await eventDataManager.getActualEvents(for: aroundEvents)
                let todayEvents = await eventDataManager.getTodayEvents(from: actualEvents)
                let upcomingEvents = await eventDataManager.getUpcomingEvents(from: actualEvents)
                let eventsDatesWithoutToday = await eventDataManager.getActiveDates(for: actualEvents)
                let activeDates = eventDataManager.dateEvents?.keys.sorted().filter( { $0.isToday || $0.isFutureDay } )
                await MainActor.run {
                    aroundManager.upcomingEvents = upcomingEvents
                    aroundManager.aroundPlaces = aroundPlaces
                    aroundManager.eventsDates = activeDates ?? eventsDatesWithoutToday
                    aroundPlaces.forEach { place in
                        let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                        place.getDistanceText(distance: distance, inKm: true)
                    }
                    aroundManager.todayEvents = todayEvents
                    aroundManager.displayedEvents = upcomingEvents
                    aroundManager.eventsCount = eventDataManager.aroundEventsCount ?? actualEvents.count
                    aroundManager.groupedPlaces = groupedPlaces
                }
                await aroundManager.updateCategories()
            } else {
                await MainActor.run {
                    let cities = getCitiesAround(userLocation)
                    aroundManager.citiesAround = cities
                    aroundManager.isLocationsAround20Found = false
                    if !cities.isEmpty {
                        aroundManager.isLoading = false
                    }
                }
            }
        }
    }
    
    private func getCitiesAround(_ location: CLLocation) -> [City] {
        return catalogDataManager.getCitiesAround(count: 3, userLocation: location, modelContext: modelContext)
    }
    
    private func update(decodedResult: AroundItemsResult, userLocation: CLLocation) {
        if decodedResult.foundAround {
            aroundManager.isLocationsAround20Found = true
            let countries = catalogDataManager.updateCountries(decodedCountries: decodedResult.countries, modelContext: modelContext)
            let regions = catalogDataManager.updateRegions(decodedRegions: decodedResult.regions, countries: countries, modelContext: modelContext)
            let cities = catalogDataManager.updateCities(decodedCities: decodedResult.cities, regions: regions, modelContext: modelContext)
            let places = placeDataManager.updatePlaces(decodedPlaces: decodedResult.places, for: cities, modelContext: modelContext)
            let eventsItems = eventDataManager.updateEvents(decodedEvents: decodedResult.events, for: cities, modelContext: modelContext)
            aroundManager.eventDataManager.aroundEventsCount = eventsItems.count
            places.forEach { place in
                let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                place.getDistanceText(distance: distance, inKm: true)
            }
            updateFetchedResult(places: places.sorted(by: { $0.name < $1.name }), events: eventsItems, userLocation: userLocation)
            aroundManager.isLoading = false
        } else {
            aroundManager.isLocationsAround20Found = false
            let countries = catalogDataManager.updateCountries(decodedCountries: decodedResult.countries, modelContext: modelContext)
            let regions = catalogDataManager.updateRegions(decodedRegions: decodedResult.regions, countries: countries, modelContext: modelContext)
            let cities = catalogDataManager.updateCities(decodedCities: decodedResult.cities, regions: regions, modelContext: modelContext)
            aroundManager.citiesAround = cities
            aroundManager.isLoading = false
        }
    }
    
    private func updateFetchedResult(places: [Place], events: EventsItems, userLocation: CLLocation) {
        Task {
            let groupedPlaces = await placeDataManager.createHomeGroupedPlaces(places: places)
            let todayEvents = events.today.sorted(by: { $0.id < $1.id })
            let upcomingEvents = events.upcoming.sorted(by: { $0.id < $1.id }).sorted(by: { $0.startDate < $1.startDate })
           let activeDates = events.allDates.keys.sorted().filter( { $0.isToday || $0.isFutureDay } )
            await MainActor.run {
                aroundManager.upcomingEvents = upcomingEvents
                aroundManager.aroundPlaces = places
                aroundManager.eventsDates = activeDates
                aroundManager.todayEvents = todayEvents
                aroundManager.displayedEvents = upcomingEvents
                aroundManager.groupedPlaces = groupedPlaces
                aroundManager.eventsCount = events.count
                aroundManager.dateEvents = events.allDates
                aroundManager.eventDataManager.aroundEventsCount = events.count
                aroundManager.eventDataManager.dateEvents = events.allDates
            }
            await aroundManager.updateCategories()
        }
    }
}

//#Preview {
//    TabBarView(authenticationManager: AuthenticationManager(keychainManager: KeychainManager(), networkManager: AuthNetworkManager(appSettingsManager: AppSettingsManager()), errorManager: ErrorManager()), appSettingsManager: AppSettingsManager())
//}
