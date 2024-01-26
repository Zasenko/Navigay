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
         authenticationManager: AuthenticationManager) {
        _viewModel = State(initialValue: CityViewModel(modelContext: modelContext,
                                                       city: city,
                                                       catalogNetworkManager: catalogNetworkManager,
                                                       placeNetworkManager: placeNetworkManager,
                                                       eventNetworkManager: eventNetworkManager,
                                                       errorManager: errorManager))
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Divider()
                    listView(width: geometry.size.width)
                }
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
    private func listView(width: CGFloat) -> some View {
        List {
            if !viewModel.allPhotos.isEmpty {
                PhotosTabView(allPhotos: $viewModel.allPhotos, width: width)
                    .frame(width: width, height: (width / 4) * 5)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding(.bottom)
            }
            
            if let user = authenticationManager.appUser, user.status == .admin {
                adminPanel
            }
            
            if viewModel.todayEvents.count > 0 {
                todayEventsView(width: width)
            }
            if viewModel.upcomingEvents.count > 0 {
                eventsView(width: width)
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
    
    @ViewBuilder
    private func todayEventsView(width: CGFloat) -> some View {
        Section {
            Text("Today's Events")
                .font(.title2).bold()
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 30)
                .padding(.bottom, 10)
            LazyVGrid(columns: viewModel.gridLayout, spacing: 20) {
                ForEach(viewModel.todayEvents) { event in
                    EventCell(event: event, width: (width / 2) - 30, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, showCountryCity: false, authenticationManager: authenticationManager)
                }
            }
            .padding(.horizontal, 20)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    @ViewBuilder
    private func eventsView(width: CGFloat) -> some View {
        Section {
            HStack {
                Text(viewModel.selectedDate?.formatted(date: .long, time: .omitted) ?? "Upcoming Events")
                    .font(.title2).bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    viewModel.showCalendar = true
                } label: {
                    HStack {
                        AppImages.iconCalendar
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        Text("Select date")
                            .font(.caption)
                            .multilineTextAlignment(.trailing)
                            .lineSpacing(-10)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 10)
            LazyVGrid(columns: viewModel.gridLayout, spacing: 20) {
                ForEach(viewModel.displayedEvents) { event in
                    EventCell(event: event, width: (width / 2) - 30, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, showCountryCity: false, authenticationManager: authenticationManager)
                }
            }
            .padding(.horizontal, 20)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
            viewModel.showCalendar = false
            if let date = newValue {
                viewModel.getEvents(for: date)
            } else {
                viewModel.showUpcomingEvents()
            }
            
        }
        .sheet(isPresented:  $viewModel.showCalendar) {} content: {
            CalendarView(selectedDate: $viewModel.selectedDate, eventsDates: $viewModel.eventsDates)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(25)
        }
    }
    
    private var placesView: some View {
        ForEach(viewModel.groupedPlaces.keys.sorted(), id: \.self) { key in
            Section {
                Text(key.getPluralName())
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    .offset(x: 70)
                ForEach(viewModel.groupedPlaces[key] ?? []) { place in
                    NavigationLink {
                        PlaceView(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager)
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
    
    let background: Color
    let foreground: Color
    
    func body(content: Content) -> some View {
        content
            .padding(5)
            .padding(.horizontal, 5)
            .foregroundColor(foreground)
            .background(background)
            .clipShape(Capsule(style: .continuous))
    }
}


