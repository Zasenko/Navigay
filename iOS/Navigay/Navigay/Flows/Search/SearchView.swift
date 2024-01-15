//
//  SearchView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    
    @State private var viewModel: SearchViewModel
    @ObservedObject var authenticationManager: AuthenticationManager // TODO: убрать юзера из вью модели так как он в authenticationManager
    @FocusState private var focused: Bool
    //  @Namespace var namespace
    
    init(modelContext: ModelContext,
         catalogNetworkManager: CatalogNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         user: AppUser?,
         authenticationManager: AuthenticationManager) {
        _viewModel = State(initialValue: SearchViewModel(modelContext: modelContext, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, user: user))
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
        viewModel.getCountriesFromDB()
        viewModel.fetchCountries()
    }
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(.blue)
                .frame(maxHeight: .infinity)
        } else {
            NavigationStack {
                listView
                    .toolbarTitleDisplayMode(.inline)
                    .toolbar {
                        if viewModel.showSearchView {
                            ToolbarItem(placement: .principal) {
                                searchView
                            }
                        } else {
                            ToolbarItem(placement: .topBarLeading) {
                                Text("Catalog")
                                    .font(.title).bold()
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                searchButton
                            }
                        }
                    }
                    .toolbarBackground(AppColors.background)
                    .onChange(of: viewModel.searchText, initial: false) { _, newValue in
                        viewModel.textSubject.send(newValue.lowercased())
                        viewModel.textSubject2.send(newValue.lowercased())
                    }
                    .onChange(of: viewModel.isSearching) { _, newValue in
                        if newValue {
                            hideKeyboard()
                        }
                    }
            }
        }
    }
    
    private var searchButton: some View {
        Button {
            withAnimation {
                viewModel.searchCountries = []
                viewModel.searchRegions = []
                viewModel.searchCities = []
                viewModel.searchEvents = []
                viewModel.searchGroupedPlaces = [:]
                
                viewModel.showSearchView = true
                focused = true
            }
        } label: {
            AppImages.iconSearch
                .font(.callout)
                .bold()
                .frame(width: 40, height: 40)
                .tint(.blue)
        }
    }
    
    
    private var searchView: some View {
        HStack {
            HStack {
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
                TextField("", text: $viewModel.searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .lineLimit(1)
                    .focused($focused)
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .background(AppColors.lightGray6)
            .cornerRadius(16)
            
            if viewModel.showSearchView {
                Button("Cancel") {
                    withAnimation {
                        hideKeyboard()
                        viewModel.searchText = ""
                        viewModel.showSearchView = false
                    }
                }
            }
        }
        .padding(.leading, viewModel.showSearchView ? 0 : 10)
        .frame(maxWidth: .infinity)
    }
    
    private var listView: some View {
        GeometryReader { proxy in
            List {
                if viewModel.showSearchView {
                    if viewModel.searchText.isEmpty {
                        lastSearchResultsView
                            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                            .listSectionSeparator(.hidden)
                    } else {
                        searchResultsView(width: proxy.size.width)
                            .listSectionSeparator(.hidden)
                    }
                } else {
                    allCountriesView
                        .listSectionSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowSeparator(.hidden)
                    Color.clear
                        .frame(height: 50)
                        .listSectionSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var allCountriesView: some View {
        ForEach(viewModel.countries) { country in
            NavigationLink {
                CountryView(modelContext: viewModel.modelContext, country: country, catalogNetworkManager: viewModel.catalogNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, user: viewModel.user, authenticationManager: authenticationManager)
            } label: {
                countryCell(country: country)
            }
        }
    }
    
    private var lastSearchResultsView: some View {
        ForEach(viewModel.catalogNetworkManager.loadedSearchText.keys.sorted(), id: \.self) { key in
            Button {
                hideKeyboard()
                viewModel.searchText = key
            } label: {
                HStack {
                    Text(key)
                        .font(.body)
                        .padding(.vertical)
                        .tint(.secondary)
                   Spacer()
                }
            }
            .buttonStyle(.borderless)
        }
    }
    
    @ViewBuilder
    private func searchResultsView(width: CGFloat) -> some View {
        // TODO: если результаты не найдены
            Section {
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
                                CountryView(modelContext: viewModel.modelContext, country: country, catalogNetworkManager: viewModel.catalogNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, user: viewModel.user, authenticationManager: authenticationManager)
                            } label: {
                                countryCell(country: country)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowSeparator(.hidden)
                }
                //            if !viewModel.searchRegions.isEmpty {
                //                Section {
                //                    Text("Regions")
                //                        .font(.title)
                //                        .foregroundStyle(.secondary)
                //                        .padding(.top, 50)
                //                        .padding(.bottom, 20)
                //                    ForEach(viewModel.searchRegions) { region in
                //                        //                    Text("region: ") + Text(region.name ?? "")
                //                        //                    Text("region country: ") + Text(region.country?.name ?? "")
                //                        //                    ForEach(region.cities) { city in
                //                        //                        Text("region city: ") + Text(city.name)
                //                        //                    }
                //
                //                        VStack {
                //                            HStack(spacing: 20) {
                //                                if let url = region.photo {
                //                                    ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                //                                        AppColors.lightGray6
                //                                    }
                //                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                //                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.lightGray5, lineWidth: 1))
                //                                } else {
                //                                    EmptyView()
                //                                        .frame(width: 50, height: 50)
                //                                }
                //                                VStack(alignment: .leading) {
                //                                    if let name = region.name {
                //                                        Text(name)
                //                                            .bold()
                //                                    }
                //                                    if let country = region.country {
                //                                        Text(country.name)
                //                                            .font(.caption)
                //                                            .foregroundStyle(.secondary)
                //                                    }
                //                                }
                //                            }
                //                            HStack {
                //                                EmptyView()
                //                                    .frame(width: 50, height: 50)
                //                                CitiesView(modelContext: viewModel.modelContext, cities: region.cities, catalogNetworkManager: viewModel.catalogNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager, user: viewModel.user, authenticationManager: authenticationManager)
                //
                //                            }
                //                            .padding(.vertical, 10)
                //                            Divider()
                //                                .offset(x: 70)
                //                        }
                //                    }
                //                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                //                    .listRowSeparator(.hidden)
                //                }
                //            }
                
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
                                CityView(modelContext: viewModel.modelContext, city: city, catalogNetworkManager: viewModel.catalogNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager, user: viewModel.user, authenticationManager: authenticationManager)
                            } label: {
                                CityCell(city: city, showCountryRegion: true)
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
                        LazyVGrid(columns: viewModel.gridLayout, spacing: 20) {
                            ForEach(viewModel.searchEvents) { event in
                                EventCell(event: event, width: (width / 2) - 30, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, showCountryCity: true)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    
                }
            }
        Color.clear
            .frame(height: 50)
            .listSectionSeparator(.hidden)
    }
    
    //TODO: дубликат PlacesView
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
                        PlaceView(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager)
                    } label: {
                        PlaceCell(place: place, showOpenInfo: false, showDistance: false, showCountryCity: true)
                    }
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder
    private func countryCell(country: Country) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                Text(country.flagEmoji)
                    .font(.title)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                Text(country.name)
                    .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                // TODO:
                //                                    HStack {
                //                                        Text("25 мест")
                //                                        Text("| ")
                //                                        Text("17 мероприятий")
                //                                    }
                //                                    .foregroundStyle(.secondary)
                //                                    .font(.caption2)
            }
            .padding(.vertical, 10)
            Divider()
                .offset(x: 70)
        }
    }
}

//#Preview {
//    SearchView(networkManager: CatalogNetworkManager(appSettingsManager: AppSettingsManager()))
//        .modelContainer(for: [
//            Country.self, Region.self, City.self], inMemory: false)
//}
