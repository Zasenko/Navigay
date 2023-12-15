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
            VStack(spacing: 0) {
                Divider()
                ListView
            }
              //  .searchable(text: $searchText, placement: .toolbar, prompt: nil)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Catalog")
                            .font(.title2.bold())
                    }
                    ToolbarItem(placement: .principal) {
                        SearchView
                    }
                }
                .toolbarBackground(AppColors.background)
                //.searchable(text: $searchText)
                .onAppear() {
                    fetch()
                }
        }
    }
    
    var SearchView: some View {
     //   HStack {
                TextField("", text: $searchText) {
                  //  authenticationManager.checkEmail(email: viewModel.email)
                }
                .textInputAutocapitalization(.never)
                .lineLimit(1)
                //.focused($focusedField, equals: .email)
            
//            AppImages.iconEnvelope
//                .font(.callout)
//                .foregroundColor(.secondary)
//                .bold()
      //  }
      //  .padding()
       // .padding(.horizontal, 10)
        .background(AppColors.lightGray6)
        .cornerRadius(16)
       // .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
//        .onTapGesture {
//            focusedField = .email
//        }
        .padding(.leading)
        .frame(maxWidth: .infinity)
    }
    
    private var ListView: some View {
        List(countries) { country in
            NavigationLink {
                CountryView(country: country, networkManager: networkManager)
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
            Country.self, Region.self, City.self], inMemory: false)
}
