//
//  CountryView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData

struct CountryView: View {
    
    // MARK: - Properties
    
    @State private var viewModel: CountryViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Init
    
    init(viewModel: CountryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Divider()
                    List {
                        if let url = viewModel.country.photoUrl {
                            ImageLoadingView(url: url, width: geometry.size.width, height: (geometry.size.width / 4) * 5, contentMode: .fill) {
                                ImageFetchingView()
                            }
                            .clipped()
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .padding(.bottom, 20)
                        }
                        HStack {
                            Text("Cities")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button {
                                viewModel.showMap.toggle()
                                
                            } label: {
                                HStack(spacing: 4) {
                                    //                                AppImages.iconLocation
                                    //                                    .font(.headline)
                                    Text("Show on map")
                                        .font(.caption)
                                        .bold()
                                }
                                .foregroundStyle(.blue)
                                .padding()
                                .background(AppColors.lightGray6)
                                .clipShape(Capsule(style: .continuous))
                            }
                            .offset(x: -70)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .offset(x: 70)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowSeparator(.hidden)
                        regionsView
                        
                        Section {
                            Text(viewModel.country.about ?? "")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 50)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .buttonStyle(PlainButtonStyle())
                    .scrollIndicators(.hidden)
                }
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
                    if let user = authenticationManager.appUser, (user.status == .admin || user.status == .moderator)  {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink {
                                EditCountryView(viewModel: EditCountryViewModel(id: viewModel.country.id, country: viewModel.country, user: user, errorManager: viewModel.errorManager, networkManager: EditCountryNetworkManager(networkManager: authenticationManager.networkManager)))
                            } label: {
                                AppImages.iconSettings
                                    .bold()
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
                .onAppear() {
                    viewModel.fetch()
                }
                .fullScreenCover(isPresented: $viewModel.showMap) {
                    CitiesMapView(cities: viewModel.country.regions.flatMap( { $0.cities } ).sorted(by: { $0.id < $1.id } ))
                }
            }
        }
    }
    
    var regionsView: some View {
        Section {
            ForEach(viewModel.regions) { region in
                if viewModel.country.showRegions {
                    HStack {
                        AppImages.iconRegion
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                        Text(region.region.name ?? "").bold()
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    .offset(x: 70)
                }
                ForEach(region.cities) { city in
                    NavigationLink {
                        CityView(viewModel: CityView.CityViewModel(modelContext: viewModel.modelContext, city: city, catalogNetworkManager: viewModel.catalogNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, catalogDataManager: viewModel.catalogDataManager, commentsNetworkManager: viewModel.commentsNetworkManager, notificationsManager: viewModel.notificationsManager))
                    } label: {
                        CityCell(city: city, showCountryRegion: false, showLocationsCount: true)
                    }
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .listRowSeparator(.hidden)
    }
}

//
//#Preview {
//    CountryView(country: Country(decodedCountry: DecodedCountry(id: 1, isoCountryCode: "RUS", name: "Russia", flagEmoji: "🇷🇺", photo: "https://thumbs.dreamstime.com/b/церковь-pokrovsky-3476006.jpg", showRegions: true, isActive: true, about: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text.", regions: [])), networkManager: CatalogNetworkManager(appSettingsManager: AppSettingsManager()))
//}
