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
    
    @Query(filter: #Predicate<Place>{ $0.isActive == true }, animation: .snappy)
    private var allPlaces: [Place]
    
    @Query(filter: #Predicate<Event>{ $0.isActive == true }, animation: .snappy)
    private var allEvents: [Event]
    
    let networkManager: CatalogNetworkManagerProtocol
    let eventNetworkManager: EventNetworkManagerProtocol
    
    @State private var groupedPlaces: [PlaceType: [Place]] = [:]
    
    @State private var aroundEvents: [Event] = []
    
    init(networkManager: CatalogNetworkManagerProtocol, locationManager: LocationManager) {
        self.networkManager = networkManager
        self.eventNetworkManager = EventNetworkManager(appSettingsManager: networkManager.appSettingsManager)
        self.locationManager = locationManager
    }
    
    var body: some View {
        NavigationStack {
            List {
                
                if aroundEvents.count > 0 {
                    Section {
                        Text("Upcoming events".uppercased())
                            .foregroundColor(.white)
                            .font(.caption)
                            .bold()
                            .modifier(CapsuleSmall(background: .red))
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
                            .modifier(CapsuleSmall(background: key.getColor()))
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
