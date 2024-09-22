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

    @StateObject private var viewModel: MapViewModel
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEvent: Event?
    
    init(viewModel: MapViewModel) {
        print("init MapView")
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                mapView
                infoView
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .bottomBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    MapSortingMenuView(categories: viewModel.categories, selectedCategory: $viewModel.selectedCategory)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        AppImages.iconXCircle
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .tint(.primary)
                    }
                }
            }
            .onChange(of: viewModel.selectedCategory, initial: false) { _, newValue in
                viewModel.filterLocations(category: newValue)
            }
            .onChange(of: viewModel.selectedTag) { _, newValue in
                withAnimation {
                    if newValue == nil {
                        viewModel.selectedEvent = nil
                        viewModel.selectedPlace = nil
                        viewModel.showInfo = false
                    } else if let place = viewModel.filteredPlaces.first(where: { $0.tag == newValue}) {
                        viewModel.selectedEvent = nil
                        viewModel.selectedPlace = place
                        viewModel.showInfo = true
                    } else if let event = viewModel.filteredEvents.first(where: { $0.tag == newValue}) {
                        viewModel.selectedPlace = nil
                        viewModel.selectedEvent = event
                        viewModel.showInfo = true
                    }
                }
            }
        }
    }
    
    private var mapView: some View {
        Map(position: $viewModel.position, selection: $viewModel.selectedTag) {
            ForEach(viewModel.filteredPlaces) {
                Marker($0.name, monogram: Text($0.type.getImage()), coordinate: $0.coordinate)
                    .tint(.primary)
                    .tag($0.tag)
            }
            .annotationTitles(.hidden)
            ForEach(viewModel.filteredEvents) { event in
                Annotation(event.name, coordinate: event.coordinate, anchor: .bottom) {
                    MapEventPin(event: event, selectedTag: $viewModel.selectedTag)
                }
                .tag(event.tag)
            }
            .annotationTitles(.hidden)
            if let userLocation = locationManager.userLocation {
                Marker("", monogram: Text("👤"), coordinate: userLocation.coordinate)
                    .tint(Color.black)
                    .annotationTitles(.hidden)
            }
            //                if let route {
            //                    MapPolyline(route)
            //                        .stroke(.blue, lineWidth: 5)
            //                }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
        .mapControlVisibility(.hidden)
    }
    
    private var infoView: some View {
        VStack {
            if viewModel.showInfo {
                if let selectedEvent = viewModel.selectedEvent {
                    // eventCell(event: selectedEvent)
                    // .transition(.move(edge: .bottom).combined(with: .opacity))
                    Button {
                        self.selectedEvent = selectedEvent
                    } label: {
                        EventMapCell(event: selectedEvent, showDistance: true, showCountryCity: false, showLike: true)
                    }
                } else if let selectedPlace = viewModel.selectedPlace {
                    NavigationLink {
                        PlaceView(viewModel: PlaceView.PlaceViewModel(place: selectedPlace, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, commentsNetworkManager: viewModel.commentsNetworkManager, notificationsManager: viewModel.notificationsManager, showOpenInfo: true))
                    } label: {
                        PlaceMapCell(place: selectedPlace, showOpenInfo: true, showDistance: true, showCountryCity: false, showLike: true)
                        //  .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .transition(.move(edge: .bottom))
        .fullScreenCover(item: $selectedEvent) { event in
            EventView(viewModel: EventView.EventViewModel(event: event, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, commentsNetworkManager: viewModel.commentsNetworkManager, notificationsManager: viewModel.notificationsManager))
        }
    }

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
