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
    
    // MARK: - Init
    
    init(errorManager: ErrorManagerProtocol, networkManager: NetworkManagerProtocol, notificationsManager: NotificationsManagerProtocol) {

        let aroundManager = AroundManager(aroundNetworkManager: AroundNetworkManager(networkManager: networkManager),
                                          placeNetworkManager: PlaceNetworkManager(networkManager: networkManager),
                                          eventNetworkManager: EventNetworkManager(networkManager: networkManager),
                                          catalogNetworkManager: CatalogNetworkManager(networkManager: networkManager),
                                          errorManager: errorManager,
                                          placeDataManager: PlaceDataManager(),
                                          eventDataManager: EventDataManager(),
                                          catalogDataManager: CatalogDataManager(),
                                          commentsNetworkManager: CommentsNetworkManager(networkManager: networkManager),
                                          searchDataManager: SearchDataManager(),
                                          notificationsManager: notificationsManager)
        _locationManager = StateObject(wrappedValue: LocationManager())
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
                CatalogView(viewModel: CatalogView.CatalogViewModel(
                    modelContext: modelContext,
                    catalogNetworkManager: aroundManager.catalogNetworkManager,
                    placeNetworkManager: aroundManager.placeNetworkManager,
                    eventNetworkManager: aroundManager.eventNetworkManager,
                    errorManager: aroundManager.errorManager, placeDataManager: aroundManager.placeDataManager, eventDataManager: aroundManager.eventDataManager, catalogDataManager: aroundManager.catalogDataManager, commentsNetworkManager: aroundManager.commentsNetworkManager, notificationsManager: aroundManager.notificationsManager))
            case .search:
                SearchView(viewModel: SearchView.SearchViewModel(modelContext: modelContext, catalogNetworkManager: aroundManager.catalogNetworkManager, placeNetworkManager: aroundManager.placeNetworkManager, eventNetworkManager: aroundManager.eventNetworkManager, errorManager: aroundManager.errorManager, placeDataManager: aroundManager.placeDataManager, eventDataManager: aroundManager.eventDataManager, catalogDataManager: aroundManager.catalogDataManager, commentsNetworkManager: aroundManager.commentsNetworkManager, searchDataManager: aroundManager.searchDataManager, notificationsManager: aroundManager.notificationsManager))
            case .user:
                AppUserView(modelContext: modelContext, userNetworkManager: UserNetworkManager(networkManager: authenticationManager.networkManager), placeNetworkManager: aroundManager.placeNetworkManager, eventNetworkManager: aroundManager.eventNetworkManager, errorManager: aroundManager.errorManager, placeDataManager: aroundManager.placeDataManager, eventDataManager: aroundManager.eventDataManager, commentsNetworkManager: aroundManager.commentsNetworkManager, notificationsManager: aroundManager.notificationsManager)
            case .admin:
                if let user = authenticationManager.appUser, (user.status == .admin || user.status == .moderator) {
                    AdminView(viewModel: AdminViewModel(user: user, errorManager: aroundManager.errorManager, networkManager: AdminNetworkManager(networkManager: authenticationManager.networkManager)))
                } else {
                    EmptyView()
                }
            }
            tabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: authenticationManager.appUser?.photoUrl, initial: true) { _, newValue in
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
                    aroundManager.errorManager.showError(model: ErrorModel(error: NetworkErrors.api, message: error.message))
                } else {
                    aroundManager.errorManager.showError(model: ErrorModel(error: NetworkErrors.api, message: message))
                }
            } catch {
                aroundManager.errorManager.showError(model: ErrorModel(error: error, message: message))
            }
        }
    }
    
    private func getFromDb(userLocation: CLLocation) {
        Task {
            let radius: Double = 30000
            
            let allPlaces = aroundManager.placeDataManager.getAllPlaces(modelContext: modelContext)
            let allEvents = aroundManager.eventDataManager.getAllEvents(modelContext: modelContext)
            
            let aroundPlaces = await aroundManager.placeDataManager.getAroundPlaces(radius: radius, allPlaces: allPlaces, userLocation: userLocation)
            let aroundEvents = await aroundManager.eventDataManager.getAroundEvents(radius: radius, allEvents: allEvents, userLocation: userLocation)
            
            if !aroundPlaces.isEmpty || !aroundEvents.isEmpty {
                let groupedPlaces = await aroundManager.placeDataManager.createHomeGroupedPlaces(places: aroundPlaces)
                let actualEvents = aroundManager.eventDataManager.getActualEvents(for: aroundEvents)
                let todayEvents = aroundManager.eventDataManager.getTodayEvents(from: actualEvents)
                let upcomingEvents = aroundManager.eventDataManager.getUpcomingEvents(from: actualEvents)
                let eventsDatesWithoutToday = aroundManager.eventDataManager.getActiveDates(for: actualEvents)
                let activeDates = aroundManager.eventDataManager.dateEvents?.keys.sorted().filter( { $0.isFutureDay } )
                await MainActor.run {
                    aroundManager.todayEvents = todayEvents
                    aroundManager.displayedEvents = upcomingEvents
                    aroundManager.eventsCount = aroundManager.eventDataManager.aroundEventsCount ?? actualEvents.count
                    aroundManager.groupedPlaces = groupedPlaces
                    aroundManager.upcomingEvents = upcomingEvents
                    aroundManager.aroundPlaces = aroundPlaces
                    aroundManager.eventsDates = activeDates ?? eventsDatesWithoutToday
                    aroundPlaces.forEach { place in
                        let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                        place.getDistanceText(distance: distance, inKm: true)
                    }
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
        return aroundManager.catalogDataManager.getCitiesAround(count: 3, userLocation: location, modelContext: modelContext)
    }
    
    private func update(decodedResult: AroundItemsResult, userLocation: CLLocation) {
        if decodedResult.foundAround {
            aroundManager.isLocationsAround20Found = true
            let countries = aroundManager.catalogDataManager.updateCountries(decodedCountries: decodedResult.countries, modelContext: modelContext)
            let regions = aroundManager.catalogDataManager.updateRegions(decodedRegions: decodedResult.regions, countries: countries, modelContext: modelContext)
            let cities = aroundManager.catalogDataManager.updateCities(decodedCities: decodedResult.cities, regions: regions, modelContext: modelContext)
            let places = aroundManager.placeDataManager.updatePlaces(decodedPlaces: decodedResult.places, for: cities, modelContext: modelContext)
            let eventsItems = aroundManager.eventDataManager.updateEvents(decodedEvents: decodedResult.events, for: cities, modelContext: modelContext)
            aroundManager.eventDataManager.aroundEventsCount = eventsItems.count
            places.forEach { place in
                let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                place.getDistanceText(distance: distance, inKm: true)
            }
            updateFetchedResult(places: places.sorted(by: { $0.name < $1.name }), events: eventsItems, userLocation: userLocation)
        } else {
            aroundManager.isLocationsAround20Found = false
            let countries = aroundManager.catalogDataManager.updateCountries(decodedCountries: decodedResult.countries, modelContext: modelContext)
            let regions = aroundManager.catalogDataManager.updateRegions(decodedRegions: decodedResult.regions, countries: countries, modelContext: modelContext)
            let cities = aroundManager.catalogDataManager.updateCities(decodedCities: decodedResult.cities, regions: regions, modelContext: modelContext)
            aroundManager.citiesAround = cities
            aroundManager.isLoading = false
        }
    }
    
    private func updateFetchedResult(places: [Place], events: EventsItems, userLocation: CLLocation) {
        Task {
            let groupedPlaces = await aroundManager.placeDataManager.createHomeGroupedPlaces(places: places)
            let todayEvents = events.today.sorted(by: { $0.id < $1.id })
            let upcomingEvents = events.upcoming.sorted(by: { $0.id < $1.id }).sorted(by: { $0.startDate < $1.startDate })
            let activeDates = events.allDates.keys.sorted().filter { date -> Bool in
                if date.isFutureDay {
                    return true
                } else if date.isToday {/// this for Notifications
                    let hour = Calendar.current.component(.hour, from: date)
                    return hour < 6
                } else {
                    return false
                }
            }
            await MainActor.run {
                aroundManager.todayEvents = todayEvents
                aroundManager.displayedEvents = upcomingEvents
                aroundManager.eventsCount = events.count
                aroundManager.eventsDates = activeDates
                aroundManager.groupedPlaces = groupedPlaces
                aroundManager.upcomingEvents = upcomingEvents
                aroundManager.aroundPlaces = places
                aroundManager.dateEvents = events.allDates
                aroundManager.eventDataManager.aroundEventsCount = events.count
                aroundManager.eventDataManager.dateEvents = events.allDates
            }
            await aroundManager.updateCategories()
            await MainActor.run {
                aroundManager.isLoading = false
            }
            
            let allPlaces = aroundManager.placeDataManager.getAllPlaces(modelContext: modelContext)
            let allEvents = aroundManager.eventDataManager.getAllEvents(modelContext: modelContext)
            
            let aroundEvents = await aroundManager.eventDataManager.getAroundEvents(radius: 30000, allEvents: allEvents, userLocation: userLocation)
            let oldEvents = aroundManager.eventDataManager.getActualEvents(for: aroundEvents)
            let oldPlaces = await aroundManager.placeDataManager.getAroundPlaces(radius: 30000, allPlaces: allPlaces, userLocation: userLocation)
            
            let placesIDs = Set(places.map { $0.id })
            let placesToDelete = oldPlaces.filter { !placesIDs.contains($0.id) }
            
            let eventsIDs = Set(events.allDates.values.flatMap { $0 })
            let eventsToDelete = oldEvents.filter { !eventsIDs.contains($0.id) }
            
            await MainActor.run {
                eventsToDelete.forEach( { print("---deleted event: ", $0.id)})
                eventsToDelete.forEach( { modelContext.delete($0) } )
                placesToDelete.forEach( { modelContext.delete($0) } )
            }
            aroundManager.notificationsManager.addAroundNotification(dates: activeDates)
        }
    }
}

//#Preview {
//    TabBarView(authenticationManager: AuthenticationManager(keychainManager: KeychainManager(), networkManager: AuthNetworkManager(appSettingsManager: AppSettingsManager()), errorManager: ErrorManager()), appSettingsManager: AppSettingsManager())
//}
