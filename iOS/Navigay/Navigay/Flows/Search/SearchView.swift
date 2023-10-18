//
//  SearchView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Country>{ $0.isActive == true }, sort: \Country.name, order: .forward, animation: .snappy)
    private var countries: [Country]
    private let networkManager: CatalogNetworkManagerProtocol
    @State private var searchText: String = ""
    
    init(networkManager: CatalogNetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(countries) { country in
                    Section {
                        NavigationLink {
                            CountryView(country: country, networkManager: networkManager)
                        } label: {
                            HStack(alignment: .center, spacing: 20) {
                                Text(country.flagEmoji)
                                    .font(.title)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(country.name)
                                        .font(.title2)
                                    HStack {
                                        Text("25 мест")
                                        Text("| ")
                                        Text("17 мероприятий")
                                    }
                                    .foregroundStyle(.secondary)
                                    .font(.caption2)
                                }
                                
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, placement: .automatic, prompt: nil)
            .toolbarTitleDisplayMode(.inline)
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Catalog")
                        .font(.title2.bold())
                }
            }
            .toolbarBackground(AppColors.background)
            .searchable(text: $searchText)
            .onAppear() {
                fetch()
            }
        }
    }
    
    func fetch() {
        if !networkManager.isCountriesLoaded {
            Task {
                do {
                    let result = try await networkManager.fetchCountries()
                    guard
                        result.result,
                        let decodedCountries = result.countries
                    else {
                        //    errorManager.showApiError(error: result.error)
                        return
                    }
                    
                    await MainActor.run {
                        for decodedCountry in decodedCountries {
                            if let country = countries.first(where: { $0.id == decodedCountry.id} ) {
                                country.updateCountryIncomplete(decodedCountry: decodedCountry)
                            } else if decodedCountry.isActive {
                                let country = Country(decodedCountry: decodedCountry)
                                context.insert(country)
                            }
                        }
                    }
                } catch {
                    print(error)
                    //  errorManager.showError(error: error)
                }
            }
        }
    }
}

#Preview {
    SearchView(networkManager: CatalogNetworkManager(appSettingsManager: AppSettingsManager()))
        .modelContainer(for: [
            Country.self, Region.self, City.self], inMemory: true)
}
