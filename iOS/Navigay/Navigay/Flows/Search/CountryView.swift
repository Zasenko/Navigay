//
//  CountryView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData

struct CountryView: View {
    
    private let country: Country
    @State private var image: Image = AppImages.iconAdmin
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    private let networkManager: CatalogNetworkManagerProtocol
    
    init(country: Country, networkManager: CatalogNetworkManagerProtocol) {
        self.country = country
        self.networkManager = networkManager
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                List {
                    Section {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .clipped()
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    if country.showRegions {
                        ForEach(country.regions.filter( { $0.isActive == true } )) { region in
                            RegionView(region: region, networkManager: networkManager)
                        }
                    } else {
                        CitiesView(cities: country.regions.flatMap( { $0.cities.filter { $0.isActive == true } } ), networkManager: networkManager)
                    }
                    
                    Section {
                        if let about = country.about {
                            Text(about)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                }
                .listStyle(.plain)
                .navigationBarBackButtonHidden()
                .toolbarBackground(AppColors.background)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("\(country.flagEmoji) \(country.name)")
                            .font(.title2.bold())
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            AppImages.iconLeft
                                .bold()
                        }
                        .tint(.primary)
                    }
                }
                .onAppear() {
                    if !networkManager.loadedCountries.contains(where: { $0 == country.id}) {
                        fetch()
                    }
                    if let url = country.photo {
                        Task {
                            if let image = await ImageLoader.shared.loadImage(urlString: url) {
                                await MainActor.run {
                                    self.image = image
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetch() {
        Task {
            do {
                let result = try await networkManager.fetchCountry(id: country.id)
                guard
                    result.result,
                    let decodedCountry = result.country
                else {
                    //    errorManager.showApiError(error: result.error)
                    return
                }
                await MainActor.run {
                    if country.isDeleted {
                        print("isDeleted")
                    }
                    if country.hasChanges {
                        print("hasChanges")
                    }
                    country.updateCountry(decodedCountry: decodedCountry)
                    updateRegions(decodedRegions: decodedCountry.regions)
                }
                
            } catch {
                print(error)
                //  errorManager.showError(error: error)
            }
        }
    }
    
    func updateRegions(decodedRegions: [DecodedRegion]?) {
        if let decodedRegions = decodedRegions, !decodedRegions.isEmpty {
            for decodedRegion in decodedRegions {
                if let region = country.regions.first(where: { $0.id == decodedRegion.id} ) {
                    region.updateRegion(decodedRegion: decodedRegion)
                    updateCities(decodedCities: decodedRegion.cities, for: region)
                } else if decodedRegion.isActive {
                    let region = Region(decodedRegion: decodedRegion)
                    country.regions.append(region)
                    updateCities(decodedCities: decodedRegion.cities, for: region)
                }
            }
        } else {
            country.regions.forEach( { context.delete($0) } )
        }
    }
    
    func updateCities(decodedCities: [DecodedCity]?, for region: Region) {
        if let decodedCities = decodedCities, !decodedCities.isEmpty {
            for decodedCity in decodedCities {
                if let city = region.cities.first(where: { $0.id == decodedCity.id} ) {
                    city.updateCityIncomplete(decodedCity: decodedCity)
                } else if decodedCity.isActive {
                    let city = City(decodedCity: decodedCity)
                    region.cities.append(city)
                }
            }
        } else {
            region.cities.forEach( { context.delete($0) } )
        }
    }
}

struct RegionView: View {
    
    private let region: Region
    let networkManager: CatalogNetworkManagerProtocol
    
    init(region: Region, networkManager: CatalogNetworkManagerProtocol) {
        self.region = region
        self.networkManager = networkManager
    }
    
    var body: some View {
        Section {
            ForEach(region.cities.filter( { $0.isActive == true } )) { city in
                NavigationLink {
                    CityView(city: city, networkManager: networkManager)
                } label: {
                    Text(city.name)
                }
            }
        } header: {
            Text(region.name ?? "")
                .bold()
        }
    }
}

struct CitiesView: View {
    private var cities: [City]
    let networkManager: CatalogNetworkManagerProtocol
    init(cities: [City], networkManager: CatalogNetworkManagerProtocol) {
        self.cities = cities
        self.networkManager = networkManager
    }
    
    var body: some View {
        Section {
            ForEach(cities.filter( { $0.isActive == true } )) { city in
                NavigationLink {
                    CityView(city: city, networkManager: networkManager)
                } label: {
                    Text(city.name)
                }
            }
        }
    }
}

//#Preview {
//    CountryView(country: Country(decodedCountry: DecodedCountry(id: 1, isoCountryCode: "RUS", name: "Russia", flagEmoji: "🇷🇺", photo: "https://thumbs.dreamstime.com/b/церковь-pokrovsky-3476006.jpg", showRegions: true, isActive: true, about: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text.", regions: [])), networkManager: CatalogNetworkManager(appSettingsManager: AppSettingsManager()))
//}
