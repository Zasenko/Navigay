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
        viewModel.fetch()
    }
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(.blue)
                .frame(maxHeight: .infinity)
        } else {
            NavigationStack {
                VStack(spacing: 0) {
                    Divider()
                    if viewModel.isSearching {
                        searchList
                            .onChange(of: viewModel.searchText, initial: false) { _, newValue in
                                viewModel.textSubject.send(newValue)
                                viewModel.searchInDB(text: newValue)
                            }
                    } else {
                        listView
                    }
                }
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    if viewModel.isSearching {
                        ToolbarItem(placement: .principal) {
                            searchView
                        }
                    } else {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Catalog")
                                .font(.title2.bold())
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            searchButton
                        }
                    }
                }
                .toolbarBackground(AppColors.background)
            }
        }
    }
    
    private var searchButton: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation {
                    viewModel.isSearching = true
                    focused = true
                }
            } label: {
                AppImages.iconSearch
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .bold()
                //    .matchedGeometryEffect(id: "img", in: namespace)
                    .frame(width: 40, height: 40)
            }
        }
      //  .matchedGeometryEffect(id: "v", in: namespace)
        .frame(width: 40, height: 40)
        .background(AppColors.lightGray6)
        .cornerRadius(16)
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
        List(viewModel.countries) { country in
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
            .listRowBackground(AppColors.background)
            .listSectionSeparator(.hidden)
            //  .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        // .scrollContentBackground(.hidden)
    }
    
    private var searchList: some View {
        List {
            Section {
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
            } header: {
                Text("Countries")
            }
            
            Section {
                ForEach(viewModel.searchRegions) { region in
                    //                    Text("region: ") + Text(region.name ?? "")
                    //                    Text("region country: ") + Text(region.country?.name ?? "")
                    //                    ForEach(region.cities) { city in
                    //                        Text("region city: ") + Text(city.name)
                    //                    }
                VStack {
                    
                    HStack {
                        if let url = region.photo {
                            ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                                AppColors.lightGray6
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.lightGray5, lineWidth: 1))
                        }
                        VStack(alignment: .leading) {
                            if let name = region.name {
                                Text(name)
                                    .bold()
                            }
                            if let country = region.country {
                                Text(country.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    
                    CitiesView(modelContext: viewModel.modelContext, cities: region.cities, catalogNetworkManager: viewModel.catalogNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager, user: viewModel.user, authenticationManager: authenticationManager)
                                        
                    
                    
                }
                    
                }
            } header: {
                Text("Regions")
            }
            
            Section {
                ForEach(viewModel.searchCities) { city in
                    HStack {
                        if let url = city.photo {
                            ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                                AppColors.lightGray6
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.lightGray5, lineWidth: 1))
                        }
                        VStack(alignment: .leading) {
                            Text(city.name)
                                .bold()
                            if let region = city.region {
                                HStack(spacing: 20) {
                                    Text(region.country?.name ?? "")
                                    Text(region.name ?? "")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                }
            } header: {
                Text("Cities")
            }
            
            
            Section {
                ForEach(viewModel.searchEvents) { event in
                    Text(event.name)
                }
            } header: {
                Text("Events")
            }
            
            Section {
                ForEach(viewModel.searchPlaces) { place in
                    Text(place.name)
                }
            } header: {
                Text("Places")
            }

            
        }
        .listStyle(.plain)
    }
}

//#Preview {
//    SearchView(networkManager: CatalogNetworkManager(appSettingsManager: AppSettingsManager()))
//        .modelContainer(for: [
//            Country.self, Region.self, City.self], inMemory: false)
//}
