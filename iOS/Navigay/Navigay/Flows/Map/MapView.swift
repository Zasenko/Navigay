//
//  MapView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.10.23.
//

import SwiftUI
import SwiftData
import MapKit

func haversine(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
    let dLat = (lat2 - lat1).degreesToRadians
    let dLon = (lon2 - lon1).degreesToRadians
    let lat1Rad = lat1.degreesToRadians
    let lat2Rad = lat2.degreesToRadians
    
    let a = pow(sin(dLat/2), 2) + pow(sin(dLon/2), 2) * cos(lat1Rad) * cos(lat2Rad)
    let c = 2 * atan2(sqrt(a), sqrt(1-a))
    let radiusOfEarth = 6371.0 // Радиус Земли в километрах
    let distance = radiusOfEarth * c
    
    return distance
}

extension CLLocationCoordinate2D {
    static let parking = CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369)
}

extension MKCoordinateRegion {
    static let boston = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.360256, longitude: -71.057279),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    static let northShore = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.547408, longitude: -70.870085),
        span: MKCoordinateSpan( latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
}

struct bb: View {
    
    @Binding var position: MapCameraPosition
    @Binding var searchResults: [MKMapItem]
    
    var visibleRegion: MKCoordinateRegion?
    
    var body: some View {
        HStack {
            Button {
                search(for: "playground")
            } label: {
                Label("Playgrounds", systemImage: "figure.and.child.holdinghands")
            }
            .buttonStyle(.borderedProminent)
            Button {
                search(for: "beach")
            } label: {
                Label("Beaches", systemImage: "beach.umbrella")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                withAnimation {
                    position = .region(.boston)
                }
            } label: {
                Label("Boston", systemImage: "building.2")
            }
            .buttonStyle(.bordered)
            Button {
                withAnimation {
                    position = .region(.northShore)
                }
                
            } label: {
                Label("North Shore", systemImage: "water.waves")
            }
            .buttonStyle(.bordered)
            
            Button {
                withAnimation {
                    position = .camera(
                        MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 48.24608899975663, longitude: 16.43973750035735),
                                  distance: 980,
                                  heading: 242,
                                  pitch: 60)
                    )
                }
                
            } label: {
                Label("My", systemImage: "heart")
            }
            .buttonStyle(.bordered)
            
            Button {
                withAnimation {
                    position =  .userLocation(followsHeading: true, fallback: .automatic)
                      //  .userLocation(fallback: .automatic)
                }
            } label: {
                Label("My", systemImage: "person")
            }
            .buttonStyle(.bordered)
            
            Button {
                withAnimation {
                    position = .item(MKMapItem(placemark: MKPlacemark(coordinate: .parking)))
                }
            } label: {
                Label("My", systemImage: "mappin")
            }
            .buttonStyle(.bordered)
        }
        .labelStyle(.iconOnly)
    }
    
    func search(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = visibleRegion ??  MKCoordinateRegion(
            center: .parking,
            span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125))
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response?.mapItems ?? []
        }
    }
}

struct MapView: View {
    
    @ObservedObject var locationManager: LocationManager
    
  //  @Namespace var mapScope
    
    @State private var position: MapCameraPosition = .automatic
    
    @State private var visibleRegion: MKCoordinateRegion?
    //    @Query(filter: #Predicate<Place>{ $0.isActive == true }, animation: .snappy)
    //    private var allPlaces: [Place]
    //
    //    @Query(filter: #Predicate<Event>{ $0.isActive == true }, animation: .snappy)
    //    private var allEvents: [Event]
    //
    //    @State private var filteredPlaces: [Place] = []
    //    @State private var selectedPlace: Place? = nil
    
    
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedResult: MKMapItem?
    @State private var selectedTag: Int?
    
    @State private var route: MKRoute?
    
    let gradient = LinearGradient(colors: [.red, .yellow, .green], startPoint: .leading, endPoint: .trailing)
    
    let stroke = StrokeStyle(lineWidth: 5,
                             lineCap: .round,
                             lineJoin: .round,
                            // miterLimit: <#T##CGFloat#>,
                             dash: [10, 10])
                            // dashPhase: <#T##CGFloat#>)
    
    var body: some View {
        
        Map(position: $position, selection: $selectedResult) {
            Annotation("Parking", coordinate: .parking, anchor: .bottom) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.orange)
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.black, lineWidth: 3)
                    Image("test200x200")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(4)
                }
            }
            .annotationTitles(.hidden)
            .tag(1225544)
            
            ForEach(searchResults, id: \.self) { result in
                Marker(item: result)
                    .tint(.mint)
                    .tag(result.placemark.hashValue)
            }
            .annotationTitles(.hidden)
            UserAnnotation()
            if let route {
                MapPolyline(route)
                    //.stroke(.blue, lineWidth: 5)
                    .stroke(gradient, style: stroke)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .safeAreaInset(edge: .top) {
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    if let selectedResult {
                        ItemInfoView(selectedResult: $selectedResult, route: $route)
                            .frame(height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding([.top, .horizontal])
                    }
                    bb(position: $position, searchResults: $searchResults, visibleRegion: visibleRegion)
                        .padding(.top)
                }
                
                Spacer()
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    if let selectedResult {
                        ItemInfoView(selectedResult: $selectedResult, route: $route)
                            .frame(height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding([.top, .horizontal])
                    }
                    bb(position: $position, searchResults: $searchResults, visibleRegion: visibleRegion)
                        .padding(.top)
                }
                
                Spacer()
            }
          //  .background(.thinMaterial)
        }
        .onChange(of: searchResults) {
            position = .automatic
        }
        .onChange(of: selectedResult) {
            getDirections()
        }
        .onMapCameraChange { context in
            visibleRegion = context.region
        }
        .mapControlVisibility(.hidden)
//        .mapControls {
//            MapUserLocationButton()
//            MapCompass()
//        }
       // .mapScope(mapScope)
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
//        .onChange(of: locationManager.userLocation, initial: true) { oldValue, newValue in
//            DispatchQueue.main.async {
//                let userLocation = newValue
//                //   guard let userLocation = newValue else { return }
//                let userLatitude = userLocation.coordinate.latitude
//                let userLongitude = userLocation.coordinate.longitude
//                let radius: Double = 20 // Радиус в километрах
//                
//                filteredPlaces = allPlaces.filter { place in
//                    let distance = haversine(lat1: userLatitude.degreesToRadians, lon1: userLongitude.degreesToRadians, lat2: place.latitude.degreesToRadians, lon2: place.longitude.degreesToRadians)
//                    return distance <= radius
//                }
//            }
//        }
        
        
        //        VStack {
        //
        //            Map(initialPosition: position, scope: mapScope) {
        //                UserAnnotation {
        //                    AppImages.iconHeartFill
        //                }
        //
        //                ForEach(filteredPlaces) { place in
        ////                    Marker(place.name, systemImage: "heart", coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
        //                    Annotation(place.name, coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)) {
        //                        VStack {
        //                            Text(place.type.getImage())
        //                                .font(selectedPlace ==  place ? .title : .callout)
        //                                .padding()
        //                                .background(place.type.getColor())
        //                                .clipShape(.circle)
        //                        }
        //                        .onTapGesture {
        //
        //                            if selectedPlace == place {
        //                                selectedPlace = nil
        //                            } else {
        //                                selectedPlace = place
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //            .onTapGesture {
        //                selectedPlace = nil
        //            }
        //            .sheet(item: $selectedPlace) { place in
        //                Text(place.name)
        //            }
        //            .onChange(of: locationManager.userLocation, initial: true) { oldValue, newValue in
        //                DispatchQueue.main.async {
        //                    guard let userLocation = newValue else { return }
        //                    let userLatitude = userLocation.coordinate.latitude
        //                    let userLongitude = userLocation.coordinate.longitude
        //                    let radius: Double = 20 // Радиус в километрах
        //
        //                    filteredPlaces = allPlaces.filter { place in
        //                        let distance = haversine(lat1: userLatitude.degreesToRadians, lon1: userLongitude.degreesToRadians, lat2: place.latitude.degreesToRadians, lon2: place.longitude.degreesToRadians)
        //                        return distance <= radius
        //                    }
        //                }
        //            }
        //
        ////            Map(position: $position) {
        ////       // Map(interactionModes: [.pan, .pitch, .zoom, .rotate]) {
        ////            Marker("Tower Bridge", coordinate: .towerBridge)
        ////            Marker("Hyde Park", coordinate: .hydepark)
        ////            Marker("Bank of England",
        ////                   systemImage: "sterlingsign", coordinate: .boe)
        ////            .tint(.green)
        ////
        ////            Annotation("Kings Cross",
        ////                       coordinate: .kingsCross, anchor: .bottom) {
        ////                VStack {
        ////                    Text("Get the train here!")
        ////                    Image(systemName: "train.side.front.car")
        ////                }
        ////                .foregroundColor(.blue)
        ////                .padding()
        ////                .background(in: .capsule)
        ////            }
        ////        }
        //        .mapControls {
        //          MapPitchToggle()
        //          MapUserLocationButton()
        //          MapCompass()
        //        }
        //        .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .including([.publicTransport])))
        //        .mapScope(mapScope)
        ////
        ////            .hybrid(elevation: .realistic,
        ////          pointsOfInterest: .including([.publicTransport]),
        ////          showsTraffic: true))
        //        .mapControlVisibility(.hidden)
        //        }

#Preview {
    MapView(locationManager: LocationManager())
        .modelContainer(for: [
            Place.self, Event.self], inMemory: true)
}

//ForEach(filteredPlaces) {
//    Marker($0.name, coordinate: $0.coordinate)
//}
//ForEach(allEvents) {
//    Annotation($0.name, coordinate: $0.coordinate, anchor: .bottom) {
//        ZStack {
//            RoundedRectangle(cornerRadius: 5)
//                .fill(.orange)
//            RoundedRectangle(cornerRadius: 5)
//                .stroke(.black, lineWidth: 3)
//            Image("test200x200")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 40, height: 40)
//                .padding(4)
//        }
//    }
//    .annotationTitles(.hidden)
//}
