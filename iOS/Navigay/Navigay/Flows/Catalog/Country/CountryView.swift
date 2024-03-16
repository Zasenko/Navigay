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
    @ObservedObject var authenticationManager: AuthenticationManager // TODO: убрать юзера из вью модели так как он в authenticationManager
    
    init(modelContext: ModelContext,
         country: Country,
         catalogNetworkManager: CatalogNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         authenticationManager: AuthenticationManager,
         placeDataManager: PlaceDataManagerProtocol,
         eventDataManager: EventDataManagerProtocol,
         catalogDataManager: CatalogDataManagerProtocol) {
        let viewModel = CountryViewModel(modelContext: modelContext, country: country, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager)
        _viewModel = State(initialValue: viewModel)
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
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
                        .padding(.bottom, 20)
                    }
                    Text("Cities")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .offset(x: 70)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowSeparator(.hidden)
                    if viewModel.country.showRegions {
                        ForEach(viewModel.country.regions.sorted(by: { $0.id < $1.id } )) { region in
                            RegionView(modelContext: viewModel.modelContext, region: region, catalogNetworkManager: viewModel.catalogNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, catalogDataManager: viewModel.catalogDataManager)
                        }
                    } else {
                        CitiesView(modelContext: viewModel.modelContext, cities: viewModel.country.regions.flatMap( { $0.cities } ).sorted(by: { $0.id < $1.id } ), catalogNetworkManager: viewModel.catalogNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, catalogDataManager: viewModel.catalogDataManager)
                    }
                    
                    Section {
                        if let about = viewModel.country.about {
                            Text(about)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 50)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
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
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                        } label: {
                            AppImages.iconSettings
                                .bold()
                                .tint(.blue)
                        }
                    }
                }
                .onAppear() {
                    viewModel.fetch()
                }
            }
        }
    }
}

//
//#Preview {
//    CountryView(country: Country(decodedCountry: DecodedCountry(id: 1, isoCountryCode: "RUS", name: "Russia", flagEmoji: "🇷🇺", photo: "https://thumbs.dreamstime.com/b/церковь-pokrovsky-3476006.jpg", showRegions: true, isActive: true, about: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text.", regions: [])), networkManager: CatalogNetworkManager(appSettingsManager: AppSettingsManager()))
//}
