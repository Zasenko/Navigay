//
//  CatalogView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 14.03.24.
//

import SwiftUI
import SwiftData

struct CatalogView: View {
    
    @State private var viewModel: CatalogViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @FocusState private var focused: Bool
    //  @Namespace var namespace
    
    init(modelContext: ModelContext, viewModel: CatalogViewModel) {
        _viewModel = State(initialValue: viewModel)
        viewModel.getCountriesFromDB()
        viewModel.fetchCountries()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.showSearchView {
                    EmptyView()
                } else {
                    listView
                }
            }
            .toolbarTitleDisplayMode(.inline)
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
            .animation(.default, value: viewModel.isLoading)
            .animation(.default, value: viewModel.countries)
            .animation(.default, value: viewModel.showSearchView)
            .onChange(of: viewModel.isSearching) { _, newValue in
                if newValue {
                    hideKeyboard()
                }
            }
        }
    }
    
    private var searchButton: some View {
        Button {
            viewModel.showSearchView = true
            focused = true
        } label: {
            AppImages.iconSearch
                .bold()
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
                    hideKeyboard()
                    viewModel.searchText = ""
                    viewModel.showSearchView = false
                }
                .bold()
            }
        }
        .padding(.leading, viewModel.showSearchView ? 0 : 10)
        .frame(maxWidth: .infinity)
    }
    
    private var listView: some View {
        List {
            allCountriesView
                .listSectionSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowSeparator(.hidden)
            Color.clear
                .frame(height: 50)
                .listSectionSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }
    
    private var allCountriesView: some View {
        ForEach(viewModel.countries) { country in
            NavigationLink {
                CountryView(modelContext: viewModel.modelContext, country: country, catalogNetworkManager: viewModel.catalogNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, catalogDataManager: viewModel.catalogDataManager)
            } label: {
                countryCell(country: country)
            }
        }
    }
    
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
