//
//  CatalogView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 14.03.24.
//

import SwiftUI
import SwiftData

struct CatalogView: View {
    
    // MARK: - Private properties
    
    @State private var viewModel: CatalogViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    
    // MARK: - Init
    
    init(viewModel: CatalogViewModel) {
        _viewModel = State(initialValue: viewModel)
        viewModel.getCountriesFromDB()
        viewModel.fetchCountries()
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            listView
            .toolbarTitleDisplayMode(.inline)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Catalog")
                        .font(.title).bold()
                }
            }
            .toolbarBackground(AppColors.background)
            .animation(.default, value: viewModel.isLoading)
            .animation(.default, value: viewModel.countries.count)
        }
    }
    
    private var listView: some View {
        List {
            allCountriesView
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowSeparator(.hidden)
            Color.clear
                .frame(height: 50)
                .listRowSeparator(.hidden)
        }
        .listSectionSeparator(.hidden)
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }
    
    private var allCountriesView: some View {
        ForEach(viewModel.countries) { country in
            NavigationLink {
                CountryView(viewModel: CountryView.CountryViewModel(modelContext: viewModel.modelContext, country: country, catalogNetworkManager: viewModel.catalogNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, catalogDataManager: viewModel.catalogDataManager, commentsNetworkManager: viewModel.commentsNetworkManager))
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
                VStack(alignment: .leading, spacing: 0) {
                    Text(country.name)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        if country.eventsCount > 0 {
                            Text(String(country.eventsCount))
                            + Text(country.eventsCount > 1 ? " events" : " event")
                        }
                        if ((country.eventsCount > 0) && (country.placesCount > 0)) {
                            Text("•")
                        }
                        if country.placesCount > 0 {
                            Text(String(country.placesCount)) + Text(country.placesCount > 1 ? " places" : " place")
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                }
            }
            .padding(.vertical, 10)
            Divider()
                .offset(x: 70)
        }
    }
}
