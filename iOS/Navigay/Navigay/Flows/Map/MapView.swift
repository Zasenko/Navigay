//
//  MapView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.10.23.
//

import SwiftUI
import SwiftData
import MapKit

struct MapView: View {
    
    @Binding var showMap: Bool
        
    @Binding var events: [Event]
    @Binding var places: [Place]
    
    @Binding var categories: [SortingMapCategory]
    @Binding var selectedCategory: SortingMapCategory
    
    @State private var filteredPlaces: [Place] = []
    @State private var filteredEvents: [Event] = []
//
//    @State private var selectedResult: MKMapItem?
//    
//    @State private var selectedPlace: Place?
//    @State private var selectedEvent: Event?
//    
    @State private var selectedTag: UUID? = nil
    @State private var position: MapCameraPosition = .automatic
//
//    @State private var route: MKRoute?
    
    init(events: Binding<[Event]>, places: Binding<[Place]>, showMap: Binding<Bool>, categories: Binding<[SortingMapCategory]>, selectedCategory: Binding<SortingMapCategory>) {
        _events = events
        _places = places
        _showMap = showMap
        _categories = categories
        _selectedCategory = selectedCategory
    }
    
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
//                    Annotation(event.name, coordinate: event.coordinate, anchor: .bottom) {
//                        MapEventPin(event: event, selectedTag: $selectedTag)
//                        VStack(spacing: 0) {
//                            Image("7x5")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: event.tag == selectedTag ? 50 : 30, height: event.tag == selectedTag ? 50 : 30)
//                                .clipped()
//                            Image(systemName: "triangle.fill")
//                        }
//                    }
                    Marker(event.name, monogram: Text(""), coordinate: event.coordinate)
                    .annotationTitles(.hidden)
                    .tag(event.tag)
                }
                .annotationTitles(.hidden)
                
                //     UserAnnotation()
                
                //                if let route {
                //                    MapPolyline(route)
                //                        .stroke(.blue, lineWidth: 5)
                //                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
            .mapControlVisibility(.hidden)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    MapSortingMenuView(categories: $categories, selectedCategory: $selectedCategory)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            showMap.toggle()
                        }
                    } label: {
                        AppImages.iconXCircle
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30, alignment: .leading)
                            .tint(.primary)
                    }
                }
            }
            .onChange(of: selectedCategory, initial: true) { _, newValue in
                filterLocations(category: newValue)
            }
            
            
            
            
            
//            .onChange(of: selectedTag) { oldValue, newValue in
//                if newValue == nil {
//                    selectedEvent = nil
//                    selectedPlace = nil
//                    withAnimation {
//                        position = .automatic
//                    }
//                } else if let p = filteredPlaces.first(where: { $0.tag == newValue}) {
//                    selectedEvent = nil
//                    selectedPlace = p
//                    withAnimation {
//                        position = .camera(MapCamera(centerCoordinate: p.coordinate, distance: 500))
//                    }
//                } else if let e = allEvents.first(where: { $0.tag == newValue}) {
//                    selectedPlace = nil
//                    selectedEvent = e
//                    withAnimation {
//                        position = .camera(MapCamera(centerCoordinate: e.coordinate, distance: 500))
//                    }
//                }
//            }
//            .safeAreaInset(edge: .bottom) {
//                
//                HStack {
//                    //                if let selectedResult {
//                    //                    ItemInfoView(selectedResult: $selectedResult, route: $route)
//                    //                        .frame(height: 128)
//                    //                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                    //                        .padding([.top, .horizontal])
//                    //                }
//                    
//                    if let selectedEvent {
//                        Text(selectedEvent.name)
//                    }
//                    
//                    if let selectedPlace {
//                        NavigationLink {
//                            //TODO!!!! networkManager errorManager appSettingsManager
//                            PlaceView(place: selectedPlace, networkManager: PlaceNetworkManager(appSettingsManager: AppSettingsManager()), errorManager: ErrorManagerProtocol())
//                        } label: {
//                            PlaceCell(place: selectedPlace)
//                                .padding()
//                                .background(selectedPlace.type.getColor())
//                            
//                                .clipShape(RoundedRectangle(cornerRadius: 20))
//                                .padding([.horizontal, .bottom])
//                                .transition(.move(edge: .bottom).combined(with: .opacity))
//                        }
//                        
//                        
//                    }
//                }
//                
//            }
        }
    }
//    
//    func getDirections() {
//        route = nil
//        guard let selectedResult else { return }
//        let request = MKDirections.Request()
//        request.source = .forCurrentLocation()
//        request.transportType = .walking
//        request.destination = selectedResult
//        
//        Task {
//            let directions = MKDirections(request: request)
//            let response = try? await directions.calculate()
//            route = response?.routes.first
//        }
//    }
    
    
    
    
    
    func filterLocations(category: SortingMapCategory) {
        withAnimation {
//            selectedAnnotation = nil
//            selectedPlace = nil
//            selectedEvent = nil
        }
        withAnimation {
        switch category {
        case .bar:
            filteredPlaces = places.filter( { $0.type == .bar } )
            filteredEvents = []
        case .cafe:
            filteredPlaces = places.filter( { $0.type == .cafe } )
            filteredEvents = []
        case .restaurant:
            filteredPlaces = places.filter( { $0.type == .restaurant } )
            filteredEvents = []
        case .club:
            filteredPlaces = places.filter( { $0.type == .club } )
            filteredEvents = []
        case .hotel:
            filteredPlaces = places.filter( { $0.type == .hotel } )
            filteredEvents = []
        case .sauna:
            filteredPlaces = places.filter( { $0.type == .sauna } )
            filteredEvents = []
        case .cruiseBar:
            filteredPlaces = places.filter( { $0.type == .cruiseBar } )
            filteredEvents = []
        case .beach:
            filteredPlaces = places.filter( { $0.type == .beach } )
            filteredEvents = []
        case .shop:
            filteredPlaces = places.filter( { $0.type == .shop } )
            filteredEvents = []
        case .gym:
            filteredPlaces = places.filter( { $0.type == .gym } )
            filteredEvents = []
        case .culture:
            filteredPlaces = places.filter( { $0.type == .culture } )
            filteredEvents = []
        case .community:
            filteredPlaces = places.filter( { $0.type == .community } )
            filteredEvents = []
        case .hostel:
            filteredPlaces = places.filter( { $0.type == .hostel } )
            filteredEvents = []
        case .medicine:
            filteredPlaces = places.filter( { $0.type == .medicine } )
            filteredEvents = []
        case .other:
            filteredPlaces = places.filter( { $0.type == .other } )
            filteredEvents = []
        case .events:
            filteredPlaces = []
            filteredEvents = events
        case .all:
            filteredPlaces = places
            filteredEvents = events
        }
            
            
            position  = .automatic
        }
    }
}

//#Preview {
//    MapView(showMap: .constant(true))
//}

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

//struct MapEventPin: View {
//    
//    //MARK: - Properties
//    
//    let event: Event
//    @Binding var selectedTag: UUID?
//    
//    //MARK: - Private Properties
//    
//    @State private var image: Image = AppImages.iconAdmin
//    
//    //MARK: - Body
//    
//    var body: some View {
//            image
//                .resizable()
//                .scaledToFill()
//                .frame(width: 100, height: 100)
//                .scaleEffect(event.tag == selectedTag ? 1 : 0.3, anchor: .bottom)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .animation(.default, value: selectedTag)
//                .overlay(alignment: .bottom) {
//                    Image(systemName: "arrowtriangle.left.fill")
//                        .rotationEffect (Angle(degrees: 270))
//                        .foregroundColor(.white)
//                        .offset(y: 10)
//                }
//        
//        .onAppear() {
//            if let url = event.smallPoster {
//                Task {
//                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
//                        await MainActor.run {
//                            self.image = image
//                        }
//                    }
//                }
//            }
//        }
//        
//    }
//}
