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
    let errorManager: ErrorManagerProtocol
    
    @State private var groupedPlaces: [PlaceType: [Place]] = [:]
    @State private var aroundEvents: [Event] = []
    
    @State private var isLoading: Bool = false
    
    init(networkManager: AroundNetworkManagerProtocol, locationManager: LocationManager, errorManager: ErrorManagerProtocol) {
        self.networkManager = networkManager
        self.eventNetworkManager = EventNetworkManager(appSettingsManager: networkManager.appSettingsManager)
        self.locationManager = locationManager
        self.errorManager = errorManager
    }
    
    var body: some View {
        if isLoading {
            ProgressView()
                .tint(.blue)
                .frame(maxHeight: .infinity)
            
        } else {
            NavigationStack {
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
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(alignment: .center, spacing: 20) {
                                    ForEach(aroundEvents.sorted(by: { $0.startDate < $1.startDate } )) { event in
                                        EventCell(event: event)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.bottom)
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
                                    PlaceView(place: place, networkManager: eventNetworkManager)
                                } label: {
                                    PlaceCell(place: place)
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listSectionSeparator(.hidden)
                .listStyle(.plain)
                .onChange(of: locationManager.userLocation, initial: true) { oldValue, newValue in
                    guard let userLocation = newValue else { return }
                    let radius: Double = 20000 // Радиус в метрах
                    let aroundPlaces  = allPlaces.filter { place in
                        let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                        return distance <= radius
                    }
                    createGrouppedExpenses(aroundPlaces)
                    aroundEvents = allEvents.filter { event in
                        let distance = userLocation.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
                        return distance <= radius && event.isActive == true//) && (event.startDate.isToday || event.startDate.isTomorrow )
                    }
                    //запрос в сеть
                    if aroundEvents.isEmpty && groupedPlaces.isEmpty {
                        isLoading = true
                    }
                    load(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                }
            }
        }
    }
    
    private func load(latitude: Double, longitude: Double) {
        Task {
            let errorModel = ErrorModel(massage: "Something went wrong. The information has not been updated. Please try again later.", img: nil, color: nil)
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
                                place.updatePlaceIncomplete(decodedPlace: decodedPlace)
                            } else if decodedPlace.isActive {
                                let place = Place(decodedPlace: decodedPlace)
                                context.insert(place)
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
                await MainActor.run {
                    let userLocation = CLLocation(latitude: latitude, longitude: longitude)
                    let radius: Double = 20000 // Радиус в метрах
                    let aroundPlaces  = allPlaces.filter { place in
                        let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                        return distance <= radius
                    }
                    createGrouppedExpenses(aroundPlaces)
                    aroundEvents = allEvents.filter { event in
                        let distance = userLocation.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
                        return distance <= radius && event.isActive == true//) && (event.startDate.isToday || event.startDate.isTomorrow )
                    }
                    isLoading = false
                }
            } catch {
                debugPrint(error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            }
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
            self.groupedPlaces = updatedPlaces
        }
    }
}

//#Preview {
//    HomeView()
//}
