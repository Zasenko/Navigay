//
//  MapView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.10.23.
//

import SwiftUI
import SwiftData
import MapKit

struct MapEventPin: View {
    
    //MARK: - Properties
    
    let event: Event
    @Binding var selectedTag: UUID?
    
    //MARK: - Private Properties
    
    @State private var image: Image = AppImages.iconAdmin
    
    //MARK: - Body
    
    var body: some View {
            image
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .scaleEffect(event.tag == selectedTag ? 1 : 0.3, anchor: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .animation(.default, value: selectedTag)
                .overlay(alignment: .bottom) {
                    Image(systemName: "arrowtriangle.left.fill")
                        .rotationEffect (Angle(degrees: 270))
                        .foregroundColor(.white)
                        .offset(y: 10)
                }
        
        .onAppear() {
            if let url = event.cover {
                Task {
                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
                        await MainActor.run {
                            self.image = image
                        }
                    }
                }
            }
        }
        
    }
}

struct MapView: View {
    
    @ObservedObject var locationManager: LocationManager
    
    @Query(filter: #Predicate<Place>{ $0.isActive == true }, animation: .snappy)
    private var allPlaces: [Place]
    
    @Query(filter: #Predicate<Event>{ $0.isActive == true }, animation: .snappy)
    private var allEvents: [Event]
    
    @State private var filteredPlaces: [Place] = []
    @State private var filteredEvents: [Event] = []
    
    @State private var selectedResult: MKMapItem?
    
    @State private var selectedPlace: Place?
    @State private var selectedEvent: Event?
    
    @State private var selectedTag: UUID?
    
    @State private var position: MapCameraPosition = .automatic
    
    @State private var route: MKRoute?
    
    var body: some View {
        NavigationStack {
            Map(position: $position, selection: $selectedTag) {
                ForEach(filteredPlaces) {
                    Marker($0.name, monogram: Text($0.type.getImage()), coordinate: $0.coordinate)
                        .tint($0.type.getColor())
                        .tag($0.tag)
                }
                .annotationTitles(.hidden)
                
                ForEach(filteredEvents) { event in
                    Annotation(event.name, coordinate: event.coordinate, anchor: .bottom) {
                        MapEventPin(event: event, selectedTag: $selectedTag)
                        //                    VStack(spacing: 0) {
                        //                        Image("7x5")
                        //                            .resizable()
                        //                            .scaledToFit()
                        //                            .frame(width: event.tag == selectedTag ? 50 : 30, height: event.tag == selectedTag ? 50 : 30)
                        //                            .clipped()
                        //                        Image(systemName: "triangle.fill")
                        //                    }
                    }
                    .annotationTitles(.hidden)
                    .tag(event.tag)
                }
                .annotationTitles(.hidden)
                
                //     UserAnnotation()
                
                if let route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
            .mapControlVisibility(.hidden)
            .onChange(of: locationManager.userLocation, initial: true) { oldValue, newValue in
                guard let userLocation = newValue else { return }
                let radius: Double = 20000 // Радиус в метрах
                filteredPlaces = allPlaces.filter { place in
                    let distance = userLocation.distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
                    return distance <= radius
                }
                
                filteredEvents = allEvents.filter { event in
                    let distance = userLocation.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
                    return distance <= radius && event.isActive == true && (event.startDate.isToday || event.startDate.isTomorrow )
                }
                if selectedTag == nil {
                    withAnimation {
                        position = .automatic
                    }
                }
            }
            .onChange(of: selectedTag) { oldValue, newValue in
                if newValue == nil {
                    selectedEvent = nil
                    selectedPlace = nil
                    withAnimation {
                        position = .automatic
                    }
                } else if let p = filteredPlaces.first(where: { $0.tag == newValue}) {
                    selectedEvent = nil
                    selectedPlace = p
                    withAnimation {
                        position = .camera(MapCamera(centerCoordinate: p.coordinate, distance: 500))
                    }
                } else if let e = allEvents.first(where: { $0.tag == newValue}) {
                    selectedPlace = nil
                    selectedEvent = e
                    withAnimation {
                        position = .camera(MapCamera(centerCoordinate: e.coordinate, distance: 500))
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                HStack {
                    Text("All places")
                    Spacer()
                }.padding(.leading)
            }
            .safeAreaInset(edge: .bottom) {
                
                HStack {
                    //                if let selectedResult {
                    //                    ItemInfoView(selectedResult: $selectedResult, route: $route)
                    //                        .frame(height: 128)
                    //                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    //                        .padding([.top, .horizontal])
                    //                }
                    
                    if let selectedEvent {
                        Text(selectedEvent.name)
                    }
                    
                    if let selectedPlace {
                        NavigationLink {
                            PlaceView(place: selectedPlace, networkManager: EventNetworkManager(appSettingsManager: AppSettingsManager()))
                        } label: {
                            PlaceCell(place: selectedPlace)
                                .padding()
                                .background(selectedPlace.type.getColor())
                            
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding([.horizontal, .bottom])
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        
                    }
                }
                
            }
        }
    }
    
    func getDirections() {
        route = nil
        guard let selectedResult else { return }
        let request = MKDirections.Request()
        request.source = .forCurrentLocation()
        request.transportType = .walking
        request.destination = selectedResult
        
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
}

struct ItemInfoView: View {
    
    @Binding var selectedResult: MKMapItem?
    @Binding var route: MKRoute?
    @State private var lookAroundScene: MKLookAroundScene?
    
    private var travelTime: String? {
        guard let route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }
    
    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text("\(selectedResult?.name ?? "")")
                    if let travelTime {
                        Text(travelTime)
                    }
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding(10)
            }
            .onAppear {
                getLookAroundScene()
            }
            .onChange(of: selectedResult) {
                getLookAroundScene()
            }
    }
    
    func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            if let selectedResult = selectedResult {
                let request = MKLookAroundSceneRequest(mapItem: selectedResult)
                lookAroundScene = try? await request.scene
            }
        }
    }
}

#Preview {
    MapView(locationManager: LocationManager())
        .modelContainer(for: [
            Place.self, Event.self], inMemory: true)
}
