//
//  CityView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI

struct CityView: View {

    let city: City
    @State private var image: Image = AppImages.iconAdmin
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let networkManager: CatalogNetworkManagerProtocol
    let eventNetworkManager: EventNetworkManagerProtocol
    let placeNetworkManager: PlaceNetworkManagerProtocol
    
    
   // @State private var groupedExpenses: [GroupedExpenses] = []
    @State private var originalGroupedPlaces: [PlaceType: [Place]] = [:]
    @Namespace var namespace
    
    
    init(city: City, networkManager: CatalogNetworkManagerProtocol) {
        self.city = city
        self.networkManager = networkManager
        self.eventNetworkManager = EventNetworkManager(appSettingsManager: networkManager.appSettingsManager)
        self.placeNetworkManager = PlaceNetworkManager(appSettingsManager: networkManager.appSettingsManager)
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
                    
//                    if city.events.count > 0 {
//                        Section {
//                            Text("Upcoming events".uppercased())
//                                .modifier(CapsuleSmall(background: .red, foreground: .white))
//                                .frame(maxWidth: .infinity)
//                                .padding(.top)
//                                .padding()
//                                .padding(.bottom)
//                            ScrollView(.horizontal, showsIndicators: false) {
//                                LazyHStack(alignment: .center, spacing: 20) {
//                                    ForEach(city.events) { event in
//                                        EventCell(event: event, width: (geometry.size.width - 10) / 2)
//                                            .padding(.horizontal)
//                                    }
//                                }
//                            }
//                            .padding(.bottom)
//                        }
//                        .listRowSeparator(.hidden)
//                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                        
//                    }
                    
//                    ForEach(originalGroupedPlaces.keys.sorted(), id: \.self) { key in
//                        Section {
//                            Text(key.getPluralName().uppercased())
//                                .foregroundColor(.white)
//                                .font(.caption)
//                                .bold()
//                                .modifier(CapsuleSmall(background: key.getColor(), foreground: .white))
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                            
//                            ForEach(originalGroupedPlaces[key] ?? []) { place in
//                                NavigationLink {
//                                    PlaceView(place: place, networkManager: placeNetworkManager, errorManager: ErrorManager)
//                                } label: {
//                                    PlaceCell(place: place)
//                                }
//                                
//                            }
//                        }
//                        .listRowSeparator(.hidden)
//                    }
                }
                .listSectionSeparator(.hidden)
                .listStyle(.plain)
                .toolbarTitleDisplayMode(.inline)
                .toolbarBackground(AppColors.background)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(city.name)
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
                    if !networkManager.loadedCities.contains(where: { $0 == city.id}) {
                        fetch()
                    }
                    if let url = city.photo {
                        Task {
                            if let image = await ImageLoader.shared.loadImage(urlString: url) {
                                await MainActor.run {
                                    self.image = image
                                }
                            }
                        }
                    }
                }
                
                .onChange(of: city.places, initial: true) { oldValue, newValue in
                    createGrouppedExpenses(newValue)
                }
            }
        }
    }
    
    func fetch() {
        Task {
            do {
                let result = try await networkManager.fetchCity(id: city.id)
                guard
                    result.result,
                    let decodedCity = result.city
                else {
                //    errorManager.showApiError(error: result.error)
                    return
                }
                await MainActor.run {
                    city.updateCity(decodedCity: decodedCity)
                    updatePlaces(decodedPlaces: decodedCity.places)
                    updateEvents(decodedEvents: decodedCity.events)
                }
                
            } catch {
                print(error)
              //  errorManager.showError(error: error)
            }
        }
    }
    
    func updatePlaces(decodedPlaces: [DecodedPlace]?) {
        if let decodedPlaces = decodedPlaces, !decodedPlaces.isEmpty {
            for decodedPlace in decodedPlaces {
                if let place = city.places.first(where: { $0.id == decodedPlace.id} ) {
                    place.updatePlaceIncomplete(decodedPlace: decodedPlace)
                    place.timetable.removeAll()
                    if let timetable = decodedPlace.timetable{
                        for day in timetable {
                            let workingDay = WorkDay(workDay: day)
                            place.timetable.append(workingDay)
                        }
                    }
                } else if decodedPlace.isActive {
                    let place = Place(decodedPlace: decodedPlace)
                    city.places.append(place)
                    if let timetable = decodedPlace.timetable {
                        for day in timetable {
                            let workingDay = WorkDay(workDay: day)
                            place.timetable.append(workingDay)
                        }
                    }
                }
            }
        } else {
            city.places.forEach( { context.delete($0) } )
        }
    }
    
    func updateEvents(decodedEvents: [DecodedEvent]?) {
        if let decodedEvents = decodedEvents, !decodedEvents.isEmpty {
            for decodedEvent in decodedEvents {
                if let event = city.events.first(where: { $0.id == decodedEvent.id} ) {
                    event.updateEventIncomplete(decodedEvent: decodedEvent)
                } else if decodedEvent.isActive {
                    let event = Event(decodedEvent: decodedEvent)
                    city.events.append(event)
                }
            }
        } else {
            city.events.forEach( { context.delete($0) } )
        }
    }
    
    func createGrouppedExpenses(_ places: [Place]) {
        var updatedPlaces: [PlaceType: [Place]] = [:]
        for place in places {
            if place.isActive {
                if var existingPlaces = updatedPlaces[place.type] {
                    existingPlaces.append(place)
                    updatedPlaces[place.type] = existingPlaces
                } else {
                    updatedPlaces[place.type] = [place]
                }
            }
        }
        withAnimation(.spring()) {
            self.originalGroupedPlaces = updatedPlaces
        }
        
//        Task.detached(priority: .high) {
//            
//            
//            
//            let groupedDict = Dictionary(grouping: expenses) { expense in
//                let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: expense.date)
//                return dateComponents
//            }
//            /// Sorting Dictionary in Descending Order
//            let sortedDict = groupedDict.sorted {
//                let calendar = Calendar.current
//                let date1 = calendar.date(from: $0.key) ?? .init()
//                let date2 = calendar.date(from: $1.key) ?? .init()
//                return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
//            }
//            // Adding to the Grouped Expenses Array
//            // UI Must be Updated on Main Thread
//            await MainActor.run {
//                groupedExpenses = sortedDict.compactMap({ dict in
//                    let date = Calendar.current.date(from: dict.key) ?? .init()
//                    return .init(date: date, expenses: dict.value)
//                })
//                originalGroupedExpenses = groupedExpenses
//            }
//        }
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
            .font(.caption)
            .bold()
            .padding(5)
            .padding(.horizontal, 5)
            .foregroundColor(foreground)
            .background(background)
            .clipShape(Capsule(style: .continuous))
    }
}
