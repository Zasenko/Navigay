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
    //    @State private var selectedResult: MKMapItem?
    //
    @State private var selectedPlace: Place?
    @State private var selectedEvent: Event?
    //
    @State private var selectedTag: UUID? = nil //!!!!!!!!!!!!!!!
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
                    if let url = event.smallPoster {
                        Annotation(event.name, coordinate: event.coordinate, anchor: .bottom) {
                            MapEventPin(event: event, url: url, selectedTag: $selectedTag)
                        }
                        .tag(event.tag)
                    } else {
                        Marker(event.name, monogram: Text("🎉"), coordinate: event.coordinate)
                            .tint(Color.black)
                            .tag(event.tag)
                    }
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
            .safeAreaInset(edge: .bottom) {
                if let selectedEvent {
                    Text(selectedEvent.name)
                        .padding()
                        .background(AppColors.background)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding([.horizontal, .bottom])
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if let selectedPlace {
                    PlaceCell(place: selectedPlace)
                        .padding()
                        .background(selectedPlace.type.getColor())
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding([.horizontal, .bottom])
                        .transition(.move(edge: .bottom).combined(with: .opacity))

                } else {
                    EmptyView()
                        .frame(width: 1, height: 1)
                }
            }
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
         //   }
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
            .onChange(of: selectedTag) { _, newValue in
                if newValue == nil {
                    selectedEvent = nil
                    selectedPlace = nil
                    withAnimation(.spring()) {
                        position = .automatic
                    }
                } else if let place = filteredPlaces.first(where: { $0.tag == newValue}) {
                    selectedEvent = nil
                    selectedPlace = place
                    withAnimation(.spring()) {
                        position = .camera(MapCamera(centerCoordinate: place.coordinate, distance: 500))
                    }
                } else if let event = filteredEvents.first(where: { $0.tag == newValue}) {
                    selectedPlace = nil
                    selectedEvent = event
                    withAnimation(.spring()) {
                        position = .camera(MapCamera(centerCoordinate: event.coordinate, distance: 500))
                    }
                }
            }
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
        selectedPlace = nil
        selectedEvent = nil
        selectedTag = nil
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
        withAnimation(.spring()) {
            if filteredPlaces.count == 1, let place = filteredPlaces.first {
                selectedTag = place.tag
            } else if filteredPlaces.isEmpty, filteredEvents.count == 1, let event = filteredEvents.first {
                selectedTag = event.tag
            } else {
                position  = .automatic
            }
        }
    }
}

//#Preview {
//    MapView(events: <#T##Binding<[Event]>#>, places: <#T##Binding<[Place]>#>, showMap: <#T##Binding<Bool>#>, categories: <#T##Binding<[SortingMapCategory]>#>, selectedCategory: <#T##Binding<SortingMapCategory>#>)
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
