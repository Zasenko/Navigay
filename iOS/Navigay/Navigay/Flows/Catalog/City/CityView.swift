//
//  CityView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData

struct CityView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CityViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.colorScheme) private var deviceColorScheme
    @State private var isScrolled: Bool = false
    @State private var scrollUp: Bool? = nil
    init(viewModel: CityViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                listView
                    .gesture(
                       DragGesture().onChanged { value in
                           isScrolled = true
                          if value.translation.height > 0 {
                              scrollUp = false
                          } else {
                              scrollUp = true
                          }
                       }
                    )
            }
            .toolbarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.background)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 10) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.blue)
                        }
                        Text(viewModel.city.name)
                            .font(.title2.bold())
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            dismiss()
                        }
                    } label: {
                        AppImages.iconLeft
                            .bold()
                            .frame(width: 30, height: 30, alignment: .leading)
                    }
                    .tint(.primary)
                }
                if let user = authenticationManager.appUser, user.status == .admin {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            EditCityView(viewModel: EditCityViewModel(id: viewModel.city.id, city: viewModel.city, user: user, errorManager: viewModel.errorManager, networkManager: EditCityNetworkManager(networkManager: authenticationManager.networkManager)))
                        } label: {
                            AppImages.iconSettings
                                .bold()
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
                viewModel.showCalendar = false
                if let date = newValue {
                    viewModel.getEvents(for: date)
                } else {
                    viewModel.showUpcomingEvents()
                }
            }
            .sheet(isPresented:  $viewModel.showCalendar) {} content: {
                CalendarView(selectedDate: $viewModel.selectedDate, eventsDates: $viewModel.eventsDates)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(25)
            }
            .fullScreenCover(item: $viewModel.selectedEvent) { event in
                EventView(viewModel: EventView.EventViewModel(event: event,
                                                              modelContext: viewModel.modelContext,
                                                              placeNetworkManager: viewModel.placeNetworkManager,
                                                              eventNetworkManager: viewModel.eventNetworkManager,
                                                              errorManager: viewModel.errorManager,
                                                              placeDataManager: viewModel.placeDataManager,
                                                              eventDataManager: viewModel.eventDataManager,
                                                              commentsNetworkManager: viewModel.commentsNetworkManager,
                                                              notificationsManager: viewModel.notificationsManager))
            }
        }
    }
    
    private var listView: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                List {
                    if !viewModel.allPhotos.isEmpty {
                        PhotosTabView(allPhotos: $viewModel.allPhotos, width: geometry.size.width)
                            .frame(width: geometry.size.width, height: (geometry.size.width / 4) * 5)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .padding(.bottom)
                    }
//                    if viewModel.city.isCapital || viewModel.city.isParadise {
//                        HStack {
//                            if viewModel.city.isCapital {
//                                VStack(spacing: 0) {
//                                    Text("⭐️")
//                                    Text("capital")
//                                }
//                                .frame(maxWidth: .infinity)
//                            }
//                            if viewModel.city.isParadise {
//                                VStack(spacing: 0) {
//                                    Text("🏳️‍🌈")
//                                    Text("heaven")
//                                }
//                                .frame(maxWidth: .infinity)
//                            }
//                        }
//                        .listRowSeparator(.hidden)
//                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                        .padding(.bottom)
//                    }
                    EmptyView()
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    Section {
                        eventsSection(size: geometry.size)
                        placesSection()
                    } header: {
                        if viewModel.sortingHomeCategories.count > 1 {
                            menuView
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    
                    Section {
                        if let about = viewModel.city.about {
                            Text(about)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding(.top, 40)
                                .listRowSeparator(.hidden)
                        }
                    }
                    Color.clear
                        .frame(height: 50)
                        .listSectionSeparator(.hidden)
                }
                .listSectionSeparator(.hidden)
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .buttonStyle(PlainButtonStyle())
                .onAppear() {
                    if !viewModel.isPresented {
                        viewModel.getPlacesAndEventsFromDB()
                    }
                }
                .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
                    withAnimation {
                        scrollProxy.scrollTo("UpcomingEvents", anchor: .top)
                    }
                }
                .onChange(of: viewModel.selectedHomeSortingCategory, initial: false) { oldValue, newValue in
                    if isScrolled {
                        withAnimation {
                            scrollProxy.scrollTo(newValue, anchor: .top)
                        }
                    }
                }
            }
        }
    }
    
    
    private func eventsSection(size: CGSize) -> some View {
        EventsView(modelContext: viewModel.modelContext, selectedDate: $viewModel.selectedDate, displayedEvents: $viewModel.displayedEvents, eventsCount: $viewModel.eventsCount, todayEvents: $viewModel.todayEvents, upcomingEvents: $viewModel.upcomingEvents, eventsDates: $viewModel.eventsDates, selectedEvent: $viewModel.selectedEvent, showCalendar: $viewModel.showCalendar, size: size, showLocation: true)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .id(SortingCategory.events)
            .onAppear() {
                if let scrollUp, !scrollUp {
                    viewModel.selectedMenuCategory = .events
                }
            }
            .onDisappear {
                if let scrollUp, scrollUp, let category = viewModel.sortingHomeCategories.first(where:  { $0.getSortPreority() > SortingCategory.events.getSortPreority()} )  {
                    viewModel.selectedMenuCategory = category
                }
            }
    }
    
    private func placesSection() -> some View {
        ForEach(viewModel.groupedPlaces.sorted(by: {$0.category.getSortPreority() < $1.category.getSortPreority()})) { groupedPlace in
            Section {
                Text(groupedPlace.category.getPluralName())
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.primary)
                    .offset(x: 70)
                    .padding(.top, 50)
                    .padding(.bottom, 10)
                ForEach(groupedPlace.places) { place in
                    NavigationLink {
                        PlaceView(viewModel: PlaceView.PlaceViewModel(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, commentsNetworkManager: viewModel.commentsNetworkManager, notificationsManager: viewModel.notificationsManager, showOpenInfo: false))
                    } label: {
                        PlaceCell(place: place, showOpenInfo: false, showDistance: false, showCountryCity: false, showLike: true)
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .listRowSeparator(.hidden)
            .id(groupedPlace.category)
            .onAppear {
                if let scrollUp, !scrollUp {
                    viewModel.selectedMenuCategory = groupedPlace.category
                }
            }
            .onDisappear {
                if let scrollUp, scrollUp, let category = viewModel.sortingHomeCategories.first(where:  { $0.getSortPreority() > groupedPlace.category.getSortPreority()} )  {
                    viewModel.selectedMenuCategory = category
                }
            }
        }
    }
    
    private var menuView: some View {
            ScrollViewReader { scrollProxy2 in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem()], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 10) {
                        ForEach(viewModel.sortingHomeCategories, id: \.self) { category in
                            Button {
                                withAnimation(.easeIn) {
                                    scrollUp = nil
                                    viewModel.selectedMenuCategory = category
                                    viewModel.selectedHomeSortingCategory = category
                                }
                            } label: {
                                Text(category.getName())
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(viewModel.selectedMenuCategory == category ? .white : .secondary)
                                    .padding(5)
                                    .padding(.horizontal, 5)
                                    .background(viewModel.selectedMenuCategory == category ? Color.primary : .clear)
                                    .clipShape(.capsule)
                            }
                            .id(category)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 10)
                .onChange(of: viewModel.selectedMenuCategory, initial: true) { oldValue, newValue in
                    withAnimation {
                        scrollProxy2.scrollTo(newValue, anchor: .top)
                    }
                }
        }
    }
}


//#Preview {
//    let errorManager: ErrorManagerProtocol = ErrorManager()
//    let keychainManager: KeychainManagerProtocol = KeychainManager()
//    let appSettingsManager: AppSettingsManagerProtocol = AppSettingsManager()
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
//        let catalogNetworkManager = CatalogNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//        let placeNetworkManager = PlaceNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//        let eventNetworkManager = EventNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//    let commentsNetworkManager = CommentsNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//    let authNetworkManager = AuthNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//
//        let placeDataManager = PlaceDataManager()
//        let eventDataManager = EventDataManager()
//        let catalogDataManager = CatalogDataManager()
//    
//    let auth = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: authNetworkManager, errorManager: errorManager)
//    let decodedCity = DecodedCity(id: 0, name: "Vienna", smallPhoto: "", photo: "", photos: nil, latitude: 48.16, longitude: 16.2, isCapital: true, isGayParadise: true, lastUpdate: "", about: "about", places: nil, events: nil, regionId: nil, region: nil, placesCount: nil, eventsCount: nil)
//    let city = City(decodedCity: decodedCity)
//    let vm = CityView.CityViewModel(modelContext: sharedModelContainer.mainContext, city: city, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager, commentsNetworkManager: commentsNetworkManager)
//    return CityView(viewModel: vm)
//        .environmentObject(auth)
//}


struct CapsuleSmall: ViewModifier {
    
    let foreground: Color
    
    init(foreground: Color = .primary) {
        self.foreground = foreground
    }
    
    func body(content: Content) -> some View {
        content
            .padding(5)
            .padding(.horizontal, 5)
            .foregroundColor(foreground)
            .background(.ultraThinMaterial)
            .clipShape(Capsule(style: .continuous))
    }
}


