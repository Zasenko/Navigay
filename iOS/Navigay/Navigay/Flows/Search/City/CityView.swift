//
//  CityView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData

struct CityView: View {

   // @State private var image: Image = AppImages.iconAdmin
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CityViewModel
    
   // @Namespace var namespace
    // @State private var groupedExpenses: [GroupedExpenses] = []
    // @State private var originalGroupedPlaces: [PlaceType: [Place]] = [:]
    
    
    init(modelContext: ModelContext, city: City, catalogNetworkManager: CatalogNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, placeNetworkManager: PlaceNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        debugPrint("init CityView, city id: ", city.id)
        _viewModel = State(initialValue: CityViewModel(modelContext: modelContext, city: city, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager))
        
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Divider()
                    ListView(width: geometry.size.width)
                    
                }
                .toolbarTitleDisplayMode(.inline)
                .toolbarBackground(AppColors.background)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(viewModel.city.name)
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
                
//                .onChange(of: viewModel.city.places, initial: true) { oldValue, newValue in
//                    viewModel.createGrouppedExpenses(newValue)
//                }
            }
        }
    }
    
    @ViewBuilder
    private func ListView(width: CGFloat) -> some View {
        List {
            // TODO: Photo tab view
            if let url = viewModel.city.photo {
                ImageLoadingView(url: url, width: width, height: (width / 4) * 5, contentMode: .fill) {
                    AppColors.lightGray6 // TODO: animation
                }
                .clipped()
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            
            if viewModel.displayedEvents.count > 0 {
                EventsView(width: width)
            }
            placesView
            Color.clear
                .frame(height: 50)
                .listSectionSeparator(.hidden)
        }
        .listSectionSeparator(.hidden)
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .buttonStyle(PlainButtonStyle())
        .onAppear() {
            viewModel.getPlacesAndEventsFromDB()
        }
    }
    
    @ViewBuilder
    private func EventsView(width: CGFloat) -> some View {
        Section {
            HStack {
                Text(viewModel.selectedDate?.formatted(date: .long, time: .omitted) ?? "Upcoming events")
                    .font(.title3).bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    viewModel.showCalendar = true
                } label: {
                    HStack {
                        Text("Select\ndate")
                            .font(.caption)
                            .multilineTextAlignment(.trailing)
                            .lineSpacing(-10)
                        AppImages.iconCalendar
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                }
                .foregroundStyle(.blue)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
            LazyVGrid(columns: viewModel.gridLayout, spacing: 20) {
                ForEach(viewModel.displayedEvents) { event in
                    EventCell(event: event, width: (width / 2) - 30, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager)
                }
            }
            .padding(.horizontal, 20)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
            viewModel.showCalendar = false
            Task {
                if let date = newValue {
                    await viewModel.getEvents(for: date)
                } else {
                    await viewModel.getUpcomingEvents(for: viewModel.city.events)
                }
            }
        }
        .sheet(isPresented:  $viewModel.showCalendar) {
            CalendarView(selectedDate: $viewModel.selectedDate, eventsDates: $viewModel.eventsDates)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(25)
        }
    }
    
    private var placesView: some View {
        ForEach(viewModel.groupedPlaces.keys.sorted(), id: \.self) { key in
            Section {
                Text(key.getPluralName().uppercased())
                    .foregroundColor(.white)
                    .font(.caption)
                    .bold()
                    .modifier(CapsuleSmall(background: key.getColor(), foreground: .white))
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                
                ForEach(viewModel.groupedPlaces[key] ?? []) { place in
                    NavigationLink {
                        PlaceView(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager)
                    } label: {
                        PlaceCell(place: place)
                    }
                }
            }
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


