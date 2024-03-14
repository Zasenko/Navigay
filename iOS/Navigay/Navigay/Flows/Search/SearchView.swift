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
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCancle: Bool = true
    @Namespace private var animation
    
    init(viewModel: SearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
        
    var body: some View {
        NavigationStack {
            
                VStack(spacing: 0) {
                    header
                    list
                }
                .onChange(of: viewModel.searchText, initial: false) { _, newValue in
                    viewModel.textSubject.send(newValue.lowercased())
                    //viewModel.textSubject2.send(newValue.lowercased())
                }
            
            .navigationBarBackButtonHidden()
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
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
                ToolbarItem(placement: .principal) {
                    Text("Search")
                        .font(.title2).bold()
                }
            }
            .toolbarBackground(AppColors.background)
            .onChange(of: viewModel.isSearching) { _, newValue in
                if newValue {
                    hideKeyboard()
                }
            }
        }
    }
    
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
                TextField("", text: $viewModel.searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .focused($focused)
                    .onAppear() {
                        focused = true
                    }
            }
            .padding(.trailing, 10)
            .background(AppColors.lightGray6)
            .cornerRadius(16)
            .frame(maxWidth: .infinity)
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
        .frame(maxWidth: .infinity)
        .animation(.interactiveSpring, value: viewModel.searchText.isEmpty)
    }
    
    private var list: some View {
        GeometryReader { proxy in
            List {
                
                // TODO: если результаты не найдены
                if viewModel.searchText.isEmpty {
                    lastSearchResultsView
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
                                CountryView(modelContext: viewModel.modelContext, country: country, catalogNetworkManager: viewModel.catalogNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, catalogDataManager: viewModel.catalogDataManager)
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
                                CityView(modelContext: viewModel.modelContext, city: city, catalogNetworkManager: viewModel.catalogNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, catalogDataManager: viewModel.catalogDataManager)
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
                        StaggeredGrid(columns: 3, showsIndicators: false, spacing: 10, list: viewModel.searchEvents) { event in
                            Button {
                                //   selectedEvent = event
                            } label: {
                                EventCell(event: event, showCountryCity: false, showStartDayInfo: true, showStartTimeInfo: false)
                                    .matchedGeometryEffect(id: "Event\(event.id)", in: animation)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom)
                        // TODO: - нажимать на кнопку
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    
                }
                Color.clear
                    .frame(height: 50)
                    .listRowSeparator(.hidden)
                
            }
            .listSectionSeparator(.hidden)
            .listStyle(.plain)
            .scrollIndicators(.hidden)
        }
    }
    
    private var lastSearchResultsView: some View {
        Section {
            ForEach(viewModel.catalogNetworkManager.loadedSearchText.keys.uniqued(), id: \.self) { key in
                Button {
                    hideKeyboard()
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
                        PlaceView(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, showOpenInfo: false)
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
}

//#Preview {
//    SearchView(networkManager: CatalogNetworkManager(appSettingsManager: AppSettingsManager()))
//        .modelContainer(for: [
//            Country.self, Region.self, City.self], inMemory: false)
//}
