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
    @ObservedObject var authenticationManager: AuthenticationManager
    
    init(modelContext: ModelContext,
         city: City,
         catalogNetworkManager: CatalogNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         authenticationManager: AuthenticationManager,
         placeDataManager: PlaceDataManagerProtocol,
         eventDataManager: EventDataManagerProtocol,
         catalogDataManager: CatalogDataManagerProtocol) {
        let viewModel = CityViewModel(modelContext: modelContext, city: city, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager)
        _viewModel = State(initialValue: viewModel)
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
//                VStack(spacing: 0) {
//                    Divider()
                    listView(size: geometry.size)
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
                }
            }
        }
    }
    
    @ViewBuilder
    private func listView(size: CGSize) -> some View {
        List {
            if !viewModel.allPhotos.isEmpty {
                PhotosTabView(allPhotos: $viewModel.allPhotos, width: size.width)
                    .frame(width: size.width, height: (size.width / 4) * 5)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding(.bottom)
            }
            
            if let user = authenticationManager.appUser, user.status == .admin {
                adminPanel
            }
            
            if viewModel.actualEvents.count > 0 {
                EventsView(modelContext: viewModel.modelContext, authenticationManager: authenticationManager, selectedDate: $viewModel.selectedDate, displayedEvents: $viewModel.displayedEvents, actualEvents: $viewModel.actualEvents, todayEvents: $viewModel.todayEvents, upcomingEvents: $viewModel.upcomingEvents, eventsDates: $viewModel.eventsDates, size: size, eventDataManager: viewModel.eventDataManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager)
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
//        .navigationDestination(item: $viewModel.adminCity) { adminCity in
//            EditCityView(viewModel: EditCityViewModel(city: adminCity, errorManager: viewModel.errorManager, networkManager: AdminNetworkManager(errorManager: viewModel.errorManager)))
//        }
    }
    
    private var adminPanel: some View {
        Section {
            NavigationLink {
                EditCityView(viewModel: EditCityViewModel(id: viewModel.city.id, userId: authenticationManager.appUser?.id ?? 0, errorManager: viewModel.errorManager, networkManager: AdminNetworkManager(errorManager: viewModel.errorManager)))
            } label: {
                Text("Edit")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.green.gradient)
                    )
            }
        }
        .listRowSeparator(.hidden)
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
                        PlaceView(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, showOpenInfo: false)
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


