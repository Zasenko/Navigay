//
//  CityView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData

struct CityView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CityViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    
    init(viewModel: CityViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            
            //                VStack(spacing: 0) {
            //                    Divider()
            listView
            //          }
                .toolbarTitleDisplayMode(.inline)
                .toolbarBackground(AppColors.background)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 10) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.blue)
                            }
                            Text(viewModel.city.name)
                                .font(.title2.bold())
                        }
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
                    if let user = authenticationManager.appUser, user.status == .admin {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink {
                                EditCityView(viewModel: EditCityViewModel(id: viewModel.city.id, city: viewModel.city, user: user, errorManager: viewModel.errorManager, networkManager: EditCityNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager)))
                            } label: {
                                AppImages.iconSettings
                                    .bold()
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
        }
    }
    
    private var listView: some View {
        GeometryReader { geometry in
            List {
                if !viewModel.allPhotos.isEmpty {
                    PhotosTabView(allPhotos: $viewModel.allPhotos, width: geometry.size.width)
                        .frame(width: geometry.size.width, height: (geometry.size.width / 4) * 5)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(.bottom)
                }
                
                if viewModel.actualEvents.count > 0 {
                    EventsView(modelContext: viewModel.modelContext, selectedDate: $viewModel.selectedDate, displayedEvents: $viewModel.displayedEvents, actualEvents: $viewModel.actualEvents, todayEvents: $viewModel.todayEvents, upcomingEvents: $viewModel.upcomingEvents, eventsDates: $viewModel.eventsDates, showCalendar: $viewModel.showCalendar, size: geometry.size, eventDataManager: viewModel.eventDataManager, placeDataManager: viewModel.placeDataManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                placesView
                
                Section {
                    if let about = viewModel.city.about {
                        Text(about)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 100)
                            .listRowSeparator(.hidden)
                    }
                }
                
            }
            .listSectionSeparator(.hidden)
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .buttonStyle(PlainButtonStyle())
            .onAppear() {
                viewModel.getPlacesAndEventsFromDB()
            }
        }
    }
    
    private var placesView: some View {
        ForEach(viewModel.groupedPlaces.keys.sorted(), id: \.self) { key in
            Section {
                Text(key.getPluralName())
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .padding(.top, 50)
                    .padding(.bottom, 10)
                    .offset(x: 70)
                ForEach(viewModel.groupedPlaces[key] ?? []) { place in
                    NavigationLink {
                        PlaceView(viewModel: PlaceView.PlaceViewModel(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, showOpenInfo: false))
                    } label: {
                        PlaceCell(place: place, showOpenInfo: false, showDistance: false, showCountryCity: false, showLike: true)
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .listRowSeparator(.hidden)
        }
    }

}

//
//#Preview {
//    CityView(city: City(id: 4, name: ""))
//        .modelContainer(for: [City.self], inMemory: true)
//}



struct CapsuleSmall: ViewModifier {
    
    let foreground: Color
    
    init(foreground: Color = .primary) {
        self.foreground = foreground
    }
    
    func body(content: Content) -> some View {
        content
            .padding(5)
            .padding(.horizontal, 5)
            .foregroundColor(foreground)
            .background(.ultraThinMaterial)
            .clipShape(Capsule(style: .continuous))
    }
}


