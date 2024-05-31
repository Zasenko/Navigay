//
//  SearchView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI

struct SearchView: View {
    
    // MARK: - PrivateProperties
    
    @State private var viewModel: SearchViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss
    @Namespace private var animation
    
    // MARK: - Init
    
    init(viewModel: SearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    // MARK: - Body
        
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                    .background {
                        ZStack(alignment: .center) {
                            Image("bg2")
                                .resizable()
                                .scaledToFill()
                                .ignoresSafeArea()
                                .scaleEffect(CGSize(width: 1.5, height: 1.5))
                                .blur(radius: 50)
                                .saturation(3)
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .ignoresSafeArea()
                        }
                        .opacity(focused ? 1 : 0)
                        .animation(.easeInOut, value: focused)
                    }
                if focused {
                    Divider()
                }
                list
                    .background(AppColors.background)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: viewModel.isSearching) { _, newValue in
                if newValue {
                    hideKeyboard()
                }
            }
            .onChange(of: viewModel.searchText, initial: false) { _, newValue in
                viewModel.notFound = false
                viewModel.textSubject.send(newValue.lowercased())
            }
            .fullScreenCover(item: $viewModel.selectedEvent) { event in
                EventView(viewModel: EventView.EventViewModel.init(event: event, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager))
            }
        }
    }
    
    // MARK: - Views
    
    private var header: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                if viewModel.isSearching {
                    ProgressView()
                        .tint(.blue)
                        .frame(width: 40, height: 40)
                } else {
                    AppImages.iconSearch
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .bold()
                        .frame(width: 40, height: 40)
                }
                    TextField("Search...", text: $viewModel.searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .focused($focused)
            }
            .padding(.trailing, 10)
            .background(AppColors.lightGray6)
            .cornerRadius(16)
            .frame(maxWidth: .infinity)
            .onTapGesture {
                focused = true
            }
            if !viewModel.searchText.isEmpty {
                Button("Cancel") {
                    focused = false
                    viewModel.searchText = ""
                    viewModel.searchRegions = []
                    viewModel.searchCities = []
                    viewModel.searchEvents = []
                    viewModel.searchGroupedPlaces = [:]
                }
                .padding(.leading)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .animation(.interactiveSpring, value: viewModel.searchText.isEmpty)
    }
    
    private var list: some View {
        GeometryReader { proxy in
            List {
                if viewModel.searchText.isEmpty {
                    lastSearchResultsView
                }
                if viewModel.notFound {
                    notFoundView
                }
                if !viewModel.searchCountries.isEmpty {
                    Section {
                        Text("Countries")
                            .font(.title)
                            .foregroundStyle(.secondary)
                            .padding(.top, 50)
                            .padding(.bottom, 10)
                            .offset(x: 70)
                        ForEach(viewModel.searchCountries) { country in
                            NavigationLink {
                                CountryView(viewModel: CountryView.CountryViewModel(modelContext: viewModel.modelContext, country: country, catalogNetworkManager: viewModel.catalogNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, catalogDataManager: viewModel.catalogDataManager))
                            } label: {
                                countryCell(country: country)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowSeparator(.hidden)
                }
                
                if !viewModel.searchCities.isEmpty {
                    Section {
                        Text("Cities")
                            .font(.title)
                            .foregroundStyle(.secondary)
                            .padding(.top, 50)
                            .padding(.bottom, 10)
                            .offset(x: 70)
                        ForEach(viewModel.searchCities) { city in
                            NavigationLink {
                                CityView(viewModel: CityView.CityViewModel(modelContext: viewModel.modelContext, city: city, catalogNetworkManager: viewModel.catalogNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, catalogDataManager: viewModel.catalogDataManager))
                            } label: {
                                CityCell(city: city, showCountryRegion: true, showLocationsCount: false)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowSeparator(.hidden)
                }
                
                if !viewModel.searchGroupedPlaces.isEmpty {
                    placesView
                }
                
                if !viewModel.searchEvents.isEmpty {
                    Section {
                        Text("Events")
                            .font(.title)
                            .foregroundStyle(.secondary)
                            .padding(.top, 50)
                            .padding(.bottom, 20)
                            .offset(x: 90)
                        StaggeredGrid(columns: 3, showsIndicators: false, spacing: 10, list: viewModel.searchEvents) { event in
                            Button {
                                viewModel.selectedEvent = event
                            } label: {
                                EventCell(event: event, showCountryCity: true, showStartDayInfo: true, showStartTimeInfo: false)
                                    .matchedGeometryEffect(id: "Event\(event.id)", in: animation)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                }
                
                Color.clear
                    .frame(height: 50)
                    .listRowSeparator(.hidden)
            }
            .scrollContentBackground(.hidden)
            .listSectionSeparator(.hidden)
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .buttonStyle(PlainButtonStyle())
            .onTapGesture {
                focused = false
            }
        }
    }
    
    private var lastSearchResultsView: some View {
        Section {
            ForEach(viewModel.catalogNetworkManager.loadedSearchText.keys.uniqued(), id: \.self) { key in
                Button {
                    hideKeyboard()
                    viewModel.searchInDB(text: key)
                    viewModel.searchText = key
                } label: {
                    HStack(alignment: .firstTextBaseline) {
                        AppImages.iconArrowUpRight
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.blue)
                        Text(key)
                            .font(.body)
                            .padding(.vertical)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .listSectionSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    private var placesView: some View {
        Section {
            ForEach(viewModel.searchGroupedPlaces.keys.sorted(), id: \.self) { key in
                Text(key.getPluralName())
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .padding(.top, 50)
                    .padding(.bottom, 10)
                    .offset(x: 70)
                ForEach(viewModel.searchGroupedPlaces[key] ?? []) { place in
                    NavigationLink {
                        PlaceView(viewModel: PlaceView.PlaceViewModel(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, showOpenInfo: false))
                    } label: {
                        PlaceCell(place: place, showOpenInfo: false, showDistance: false, showCountryCity: true, showLike: true)
                    }
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .listRowSeparator(.hidden)
    }
    
    private func countryCell(country: Country) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                Text(country.flagEmoji)
                    .font(.title)
                    .frame(width: 50, height: 50, alignment: .center)
                    .clipShape(Circle())
                Text(country.name)
                    .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            Divider()
                .offset(x: 70)
        }
    }
    
    private var notFoundView: some View {
        Section {
            VStack {
                AppImages.iconSearchLocation
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundStyle(.secondary)
                    .padding()
                    .padding(.top)
                Group {
                    Text("Oops! No matches found.")
                        .font(.title2)
                    Text("Looks like our gay radar needs a caffeine boost! How about we try again?\n\nNavigay at your service!")
                        .font(.callout)
                }
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .textSelection(.enabled)
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
        .listSectionSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

//-
import SwiftData
#Preview {
    let errorManager: ErrorManagerProtocol = ErrorManager()
    let appSettingsManager: AppSettingsManagerProtocol = AppSettingsManager()
    let networkMonitorManager: NetworkMonitorManagerProtocol = NetworkMonitorManager(errorManager: errorManager)
    let keychainManager: KeychainManagerProtocol = KeychainManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AppUser.self, Country.self, Region.self, City.self, Event.self, Place.self, User.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    let placeNetworkManager = PlaceNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
    let eventNetworkManager = EventNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
    let catalogNetworkManager = CatalogNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
    let placeDataManager = PlaceDataManager()
    let eventDataManager = EventDataManager()
    let catalogDataManager = CatalogDataManager()
    
    let authNetworkManager = AuthNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
    let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: authNetworkManager, errorManager: errorManager)
    return SearchView(viewModel: SearchView.SearchViewModel(modelContext: sharedModelContainer.mainContext, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager))
        .environmentObject(authenticationManager)
}
