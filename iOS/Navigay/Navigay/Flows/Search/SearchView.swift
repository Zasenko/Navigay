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
                        if viewModel.isSearching {
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
                        viewModel.textSubject.send(newValue)
                        viewModel.searchInDB(text: newValue)
                        focused = false
                    }
            }
        }
    }
    
    private var searchButton: some View {
        Button {
            withAnimation {
                viewModel.isSearching = true
                focused = true
            }
        } label: {
            HStack(spacing: 0) {
                AppImages.iconSearch
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .bold()
                //    .matchedGeometryEffect(id: "img", in: namespace)
                    .frame(maxWidth: .infinity)
            }
            //  .matchedGeometryEffect(id: "v", in: namespace)
            .frame(width: 40, height: 40)
            .background(AppColors.lightGray6)
            .cornerRadius(16)
        }
    }
    
    
    private var searchView: some View {
        HStack {
            HStack {
                AppImages.iconSearch
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .bold()
                //          .matchedGeometryEffect(id: "img", in: namespace)
                    .frame(height: 40)
                
                TextField("", text: $viewModel.searchText)
                    .textInputAutocapitalization(.never)
                    .lineLimit(1)
                    .focused($focused)
            }
            .padding(.horizontal, 10)
            // .matchedGeometryEffect(id: "v", in: namespace)
            .frame(maxWidth: .infinity)
            .background(AppColors.lightGray6)
            .cornerRadius(16)
            
            if viewModel.isSearching {
                Button("Cancel") {
                    withAnimation {
                        viewModel.searchText = ""
                        viewModel.isSearching = false
                        focused = false
                    }
                }
            }
        }
        // .padding()
        // .padding(.horizontal, 10)
        .padding(.leading, viewModel.isSearching ? 0 : 10)
        .frame(maxWidth: .infinity)
    }
    
    private var listView: some View {
        List {
            if viewModel.isSearching {
                if viewModel.searchText.isEmpty {
                    lastSearchResultsView
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listSectionSeparator(.hidden)
                } else {
                    searchResultsView
                        .listSectionSeparator(.hidden)
                }
            } else {
                allCountriesView
                //.listRowBackground(AppColors.background)
                    .listSectionSeparator(.hidden)
                //  .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }
    
    private var allCountriesView: some View {
        ForEach(viewModel.countries) { country in
            NavigationLink {
                CountryView(modelContext: viewModel.modelContext, country: country, catalogNetworkManager: viewModel.catalogNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, user: viewModel.user, authenticationManager: authenticationManager)
            } label: {
                HStack(alignment: .center, spacing: 20) {
                    Text(country.flagEmoji)
                        .font(.title)
                        .padding()
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text(country.name)
                            .font(.title2)
                        //                                    HStack {
                        //                                        Text("25 мест")
                        //                                        Text("| ")
                        //                                        Text("17 мероприятий")
                        //                                    }
                        //                                    .foregroundStyle(.secondary)
                        //                                    .font(.caption2)
                    }
                    
                }
            }
        }
    }
    
    private var lastSearchResultsView: some View {
        ForEach(viewModel.catalogNetworkManager.loadedSearchText.keys.sorted(), id: \.self) { key in
            Button {
                viewModel.searchInDB(text: key)
                viewModel.searchText = key
            } label: {
                Text(key)
                    .foregroundStyle(.secondary)
                    .bold()
                    .font(.body)
                    .padding()
            }
        }
    }
    
    private var searchResultsView: some View {
        
        // TODO: если результаты не найдены
        
        Section {
            if !viewModel.searchCountries.isEmpty {
                Section {
                    Text("Countries")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .padding(.top, 50)
                        .padding(.bottom, 20)
                    ForEach(viewModel.searchCountries) { country in
                        NavigationLink {
                            CountryView(modelContext: viewModel.modelContext, country: country, catalogNetworkManager: viewModel.catalogNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, user: viewModel.user, authenticationManager: authenticationManager)
                        } label: {
                            HStack(alignment: .center, spacing: 20) {
                                Text(country.flagEmoji)
                                    .font(.title)
                                    .padding()
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(country.name)
                                        .font(.title2)
                                    //                                    HStack {
                                    //                                        Text("25 мест")
                                    //                                        Text("| ")
                                    //                                        Text("17 мероприятий")
                                    //                                    }
                                    //                                    .foregroundStyle(.secondary)
                                    //                                    .font(.caption2)
                                }
                                
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowSeparator(.hidden)
            }
    //            if !viewModel.searchRegions.isEmpty {
    //                Section {
    //                    Text("Regions")
    //                        .font(.title3)
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
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .padding(.top, 50)
                        .padding(.bottom, 10)
                        .offset(x: 70)
                    ForEach(viewModel.searchCities) { city in
                        NavigationLink {
                            CityView(modelContext: viewModel.modelContext, city: city, catalogNetworkManager: viewModel.catalogNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager, user: viewModel.user, authenticationManager: authenticationManager)
                        } label: {
                            cityCell(city: city)
                       }
                    }
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowSeparator(.hidden)
            }
            
            if !viewModel.searchGroupedPlaces.isEmpty {
                Section {
                    Text("Places")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .padding(.top, 50)
                        .padding(.bottom, 20)
                    placesView
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                //.listRowSeparator(.hidden)
            }
            
            if !viewModel.searchEvents.isEmpty {
                Section {
                    Text("Events")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .padding(.top, 50)
                        .padding(.bottom, 20)
                    ForEach(viewModel.searchEvents) { event in
                        Text(event.name)
                    }
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
        }
    }
    
    //TODO: дубликат PlacesView
    private var placesView: some View {
        ForEach(viewModel.searchGroupedPlaces.keys.sorted(), id: \.self) { key in
            Section {
                Text(key.getPluralName().uppercased())
                    .foregroundColor(.white)
                    .font(.caption)
                    .bold()
                    .modifier(CapsuleSmall(background: key.getColor(), foreground: .white))
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                ForEach(viewModel.searchGroupedPlaces[key] ?? []) { place in
                    NavigationLink {
                        PlaceView(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager)
                    } label: {
                        PlaceCell(place: place, showOpenInfo: false, showDistance: false)
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .listRowSeparator(.hidden)
        }
    }
    
    @ViewBuilder
    private func cityCell(city: City) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                if let url = city.photo {
                    ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                        AppColors.lightGray6
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.lightGray5, lineWidth: 1))
                } else {
                    EmptyView()
                        .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(city.name)
                        .font(.body)
                        .bold()
                    if let region = city.region {
                        HStack(spacing: 10) {
                            Text(region.country?.name ?? "")
                                .bold()
                            Text(region.name ?? "")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
