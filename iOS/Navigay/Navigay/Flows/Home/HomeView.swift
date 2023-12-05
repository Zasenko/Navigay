//
//  HomeView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI
import SwiftData
import CoreLocation

struct HomeView: View {
    
    @ObservedObject var locationManager: LocationManager
    @Environment(\.modelContext) private var context
    
    @Query(filter: #Predicate<Place>{ $0.isActive == true }, animation: .snappy)
    private var allPlaces: [Place]
    @Query(filter: #Predicate<Event>{ $0.isActive == true }, animation: .snappy)
    private var allEvents: [Event]
    
    let networkManager: AroundNetworkManagerProtocol
    let eventNetworkManager: EventNetworkManagerProtocol
    let placeNetworkManager: PlaceNetworkManagerProtocol
    let errorManager: ErrorManagerProtocol
    
    @State private var groupedPlaces: [PlaceType: [Place]] = [:]
    @State private var allAroundEvents: [Event] = []
    @State private var aroundEvents: [Event] = []
    
    @State private var showEvent: Bool = false
    @State private var selectedEvent: Event? = nil
    @State private var isLoading: Bool = false
    @State private var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
   
    init(networkManager: AroundNetworkManagerProtocol, locationManager: LocationManager, errorManager: ErrorManagerProtocol) {
        self.networkManager = networkManager
        self.eventNetworkManager = EventNetworkManager(appSettingsManager: networkManager.appSettingsManager)
        self.placeNetworkManager = PlaceNetworkManager(appSettingsManager: networkManager.appSettingsManager)
        self.locationManager = locationManager
        self.errorManager = errorManager
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .tint(.blue)
                    .frame(maxHeight: .infinity)
            } else {
                NavigationStack {
                    GeometryReader { proxy in
                        listView(width: proxy.size.width)
                            .toolbarBackground(AppColors.background)
                            .toolbarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    VStack(spacing: 0) {
                                        Text("Around you")
                                            .font(.headline).bold()
                                    }
                                }
                            }
                            .onChange(of: locationManager.userLocation, initial: true) { oldValue, newValue in
                                guard let userLocation = newValue else { return }
                                updateAroundPlacesAndEvents(userLocation: userLocation)
                            }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func listView(width: CGFloat) -> some View {
        List {
            if aroundEvents.count > 0 {
                Section {
                    Text("Upcoming events".uppercased())
                        .foregroundColor(.white)
                        .font(.caption)
                        .bold()
                        .modifier(CapsuleSmall(background: .red, foreground: .white))
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                        .padding()
                        .padding(.bottom)
                    LazyVGrid(columns: gridLayout, spacing: 20) {
                        ForEach(aroundEvents.sorted(by: { $0.startDate < $1.startDate } )) { event in
                            EventCell(event: event, width: (width / 2) - 30, networkManager: eventNetworkManager, errorManager: errorManager, placeNetworkManager: placeNetworkManager)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }

            ForEach(groupedPlaces.keys.sorted(), id: \.self) { key in
                Section {
                    Text(key.getPluralName().uppercased())
                        .foregroundColor(.white)
                        .font(.caption)
                        .bold()
                        .modifier(CapsuleSmall(background: key.getColor(), foreground: .white))
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                    
                    ForEach(groupedPlaces[key] ?? []) { place in
                        NavigationLink {
                            PlaceView(place: place, networkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager)
                        } label: {
                            PlaceCell(place: place)
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            Color.clear
                .frame(height: 50)
                .listSectionSeparator(.hidden)
        }
        .listSectionSeparator(.hidden)
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }
    
    private func updateAroundPlacesAndEvents(userLocation: CLLocation) {
            let radius: Double = 20000
            let aroundPlaces = allPlaces.filter { userLocation.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude)) <= radius }
            createGroupedPlaces(places: aroundPlaces)
            
        allAroundEvents = allEvents.filter { event in
            let distance = userLocation.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
            return distance <= radius
        }
        aroundEvents = allEvents.filter { event in
            let distance = userLocation.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
            let lastDayOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            let weekDays = Date().getAllDatesBetween(finishDate: lastDayOfWeek)
            var bool = false
            for day in weekDays {
                if day.isSameDayWithOtherDate(event.startDate) {
                    bool = true
                }
            }
            if !bool {
                if let finishDate = event.finishDate {
                    let allEventsDate = event.startDate.getAllDatesBetween(finishDate: finishDate)
                    for eventDay in allEventsDate {
                        for day in weekDays {
                            if day.isSameDayWithOtherDate(eventDay) {
                                if finishDate.isToday {
                                    if let finishTime = event.finishTime {
                                        if finishTime.isFutureHour(of: Date()) {
                                            bool = true
                                            break
                                        } else {
                                            bool = false
                                            break
                                        }
                                    } else {
                                        bool = true
                                        break
                                    }
                                } else {
                                    bool = true
                                    break
                                }
                            }
                        }
                    }
                }
            }
            return distance <= radius && bool
        }
            if allAroundEvents.isEmpty && groupedPlaces.isEmpty {
                isLoading = true
            }
            if !networkManager.userLocations.contains(where: { $0 == userLocation }) {
                load(location: userLocation)
            }
        }
    
    private func load(location: CLLocation) {
        Task {
            let errorModel = ErrorModel(massage: "Something went wrong. The information has not been updated. Please try again later.", img: nil, color: nil)
            let latitude: Double = location.coordinate.latitude
            let longitude: Double = location.coordinate.longitude
            do {
                let decodedResult = try await networkManager.fetchLocations(latitude: latitude, longitude: longitude)
                guard decodedResult.result else {
                    debugPrint("ERROR - getAdminInfo API:", decodedResult.error?.message ?? "---")
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    throw NetworkErrors.apiError
                }
                if let decodedPlaces = decodedResult.places {
                    await MainActor.run {
                        for decodedPlace in decodedPlaces {
                            if let place = allPlaces.first(where: { $0.id == decodedPlace.id} ) {
                                let lastUpdate = decodedPlace.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
                                if place.lastUpdateIncomplete != lastUpdate {
                                    place.updatePlaceIncomplete(decodedPlace: decodedPlace)
                                    let timetable = place.timetable
                                    place.timetable.removeAll()
                                    timetable.forEach( { context.delete($0) })
                                    if let timetable = decodedPlace.timetable {
                                        for day in timetable {
                                            let workingDay = WorkDay(workDay: day)
                                            place.timetable.append(workingDay)
                                        }
                                    }
                                }
                            } else if decodedPlace.isActive {
                                let place = Place(decodedPlace: decodedPlace)
                                context.insert(place)
                                if let timetable = decodedPlace.timetable {
                                    for day in timetable {
                                        let workingDay = WorkDay(workDay: day)
                                        place.timetable.append(workingDay)
                                    }
                                }
                            }
                        }
                    }
                }
                if let decodedEvents = decodedResult.events {
                    await MainActor.run {
                        for decodeEvent in decodedEvents {
                            if let event = allEvents.first(where: { $0.id == decodeEvent.id} ) {
                                event.updateEventIncomplete(decodedEvent: decodeEvent)
                            } else if decodeEvent.isActive {
                                let event = Event(decodedEvent: decodeEvent)
                                context.insert(event)
                            }
                        }
                    }
                }
                networkManager.addToUserLocations(location: location)
                
                await MainActor.run {
                    let userLocation = CLLocation(latitude: latitude, longitude: longitude)
                    let radius: Double = 20000 // Радиус в метрах
                    let aroundPlaces  = allPlaces.filter { place in
                        let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                        return distance <= radius
                    }
                    createGroupedPlaces(places: aroundPlaces)
                    allAroundEvents = allEvents.filter { event in
                        let distance = userLocation.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
                        return distance <= radius
                    }
                    aroundEvents = allEvents.filter { event in
                        let distance = userLocation.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
                        let lastDayOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                        let weekDays = Date().getAllDatesBetween(finishDate: lastDayOfWeek)
                        var bool = false
                        for day in weekDays {
                            if day.isSameDayWithOtherDate(event.startDate) {
                                bool = true
                            }
                        }
                        if !bool {
                            if let finishDate = event.finishDate {
                                let allEventsDate = event.startDate.getAllDatesBetween(finishDate: finishDate)
                                for eventDay in allEventsDate {
                                    for day in weekDays {
                                        if day.isSameDayWithOtherDate(eventDay) {
                                            if finishDate.isToday {
                                                if let finishTime = event.finishTime {
                                                    if finishTime.isFutureHour(of: Date()) {
                                                        bool = true
                                                        break
                                                    } else {
                                                        bool = false
                                                        break
                                                    }
                                                } else {
                                                    bool = true
                                                    break
                                                }
                                            } else {
                                                bool = true
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        return distance <= radius && bool
                    }
                    isLoading = false
                }
            } catch {
                isLoading = false
                debugPrint(error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            }
        }
    }

    private func createGroupedPlaces(places: [Place]) {
        let updatedPlaces = Dictionary(grouping: places.filter { $0.isActive }) { $0.type }
        withAnimation(.spring()) {
            self.groupedPlaces = updatedPlaces
        }
    }
}

#Preview {
    let appSettingsManager = AppSettingsManager()
    let networkManager = AroundNetworkManager(appSettingsManager: appSettingsManager)
    let locationManager = LocationManager()
    let errorManager = ErrorManager()
    return HomeView(networkManager: networkManager, locationManager: locationManager, errorManager: errorManager)
        .modelContainer(for: [Place.self, Event.self], inMemory: false)
}
