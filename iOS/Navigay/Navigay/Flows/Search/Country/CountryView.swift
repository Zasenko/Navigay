//
//  CountryView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData

struct CountryView: View {
    
    @State private var viewModel: CountryViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    init(modelContext: ModelContext, country: Country, catalogNetworkManager: CatalogNetworkManagerProtocol, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        
        _viewModel = State(initialValue: CountryViewModel(modelContext: modelContext, country: country, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager))
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                List {
                    if let url = viewModel.country.photo {
                        ImageLoadingView(url: url, width: geometry.size.width, height: (geometry.size.width / 4) * 5, contentMode: .fill) {
                            AppColors.lightGray6 // TODO: animation in ImageLoadingView
                        }
                        .clipped()
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    if viewModel.country.showRegions {
                        ForEach(viewModel.country.regions.filter( { $0.isActive == true } )) { region in
                            RegionView(modelContext: viewModel.modelContext, region: region, catalogNetworkManager: viewModel.catalogNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager)
                        }
                    } else {
                        CitiesView(modelContext: viewModel.modelContext, cities: viewModel.country.regions.flatMap( { $0.cities.filter { $0.isActive == true } } ), catalogNetworkManager: viewModel.catalogNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager)
                    }
                    
                    Section {
                        if let about = viewModel.country.about {
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
                        Text("\(viewModel.country.flagEmoji) \(viewModel.country.name)")
                            .font(.title2.bold())
                    }
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
                }
                .onAppear() {
                    viewModel.fetch()
                }
            }
        }
    }
}

struct RegionView: View {
    
    private var modelContext: ModelContext
    private let region: Region
    private let catalogNetworkManager: CatalogNetworkManagerProtocol
    private let eventNetworkManager: EventNetworkManagerProtocol
    private let placeNetworkManager: PlaceNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol
    
    init(modelContext: ModelContext, region: Region, catalogNetworkManager: CatalogNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, placeNetworkManager: PlaceNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.modelContext = modelContext
        self.region = region
        self.catalogNetworkManager = catalogNetworkManager
        self.eventNetworkManager = eventNetworkManager
        self.placeNetworkManager = placeNetworkManager
        self.errorManager = errorManager
    }
    
    var body: some View {
        Section {
            ForEach(region.cities.filter( { $0.isActive == true } )) { city in
                NavigationLink {
                    CityView(modelContext: modelContext, city: city, catalogNetworkManager: catalogNetworkManager, eventNetworkManager: eventNetworkManager, placeNetworkManager: placeNetworkManager, errorManager: errorManager)
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
    
    private var modelContext: ModelContext
    private var cities: [City]
    private let catalogNetworkManager: CatalogNetworkManagerProtocol
    private let eventNetworkManager: EventNetworkManagerProtocol
    private let placeNetworkManager: PlaceNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol
    
    init(modelContext: ModelContext, cities: [City], catalogNetworkManager: CatalogNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, placeNetworkManager: PlaceNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.modelContext = modelContext
        self.cities = cities
        self.catalogNetworkManager = catalogNetworkManager
        self.eventNetworkManager = eventNetworkManager
        self.placeNetworkManager = placeNetworkManager
        self.errorManager = errorManager
    }
    
    var body: some View {
        Section {
            ForEach(cities.filter( { $0.isActive == true } )) { city in
                NavigationLink {
                    CityView(modelContext: modelContext, city: city, catalogNetworkManager: catalogNetworkManager, eventNetworkManager: eventNetworkManager, placeNetworkManager: placeNetworkManager, errorManager: errorManager)
                } label: {
                    Text(city.name)
                }
            }
        }
    }
}
//
//#Preview {
//    CountryView(country: Country(decodedCountry: DecodedCountry(id: 1, isoCountryCode: "RUS", name: "Russia", flagEmoji: "🇷🇺", photo: "https://thumbs.dreamstime.com/b/церковь-pokrovsky-3476006.jpg", showRegions: true, isActive: true, about: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text.", regions: [])), networkManager: CatalogNetworkManager(appSettingsManager: AppSettingsManager()))
//}
