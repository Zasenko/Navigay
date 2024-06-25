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
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                Map(position: $viewModel.position, selection: $viewModel.selectedTag) {
                    ForEach(viewModel.filteredPlaces) {
                        Marker($0.name, monogram: Text($0.type.getImage()), coordinate: $0.coordinate)
                            .tint($0.type.getColor())
                            .tag($0.tag)
                    }
                    .annotationTitles(.hidden)
                    ForEach(viewModel.filteredEvents) { event in
                        if let url = event.smallPoster {
                            Annotation(event.name, coordinate: event.coordinate, anchor: .bottom) {
                                MapEventPin(event: event, url: url, selectedTag: $viewModel.selectedTag, with: proxy.size.width)
                            }
                            .tag(event.tag)
                        } else {
                            Marker(event.name, monogram: Text("🎉"), coordinate: event.coordinate)
                                .tint(Color.black)
                                .tag(event.tag)
                        }
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
                .animation(.default, value: viewModel.position)
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
                .mapControlVisibility(.hidden)
                .safeAreaInset(edge: .bottom) {
                    if viewModel.showInfo {
                        if let selectedEvent = viewModel.selectedEvent {
                            eventCell(event: selectedEvent)
                            
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else if let selectedPlace = viewModel.selectedPlace {
                            placeCell(place: selectedPlace)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarTitleDisplayMode(.inline)
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
            .onChange(of: viewModel.selectedCategory, initial: true) { _, newValue in
                viewModel.filterLocations(category: newValue)
            }
            .onChange(of: viewModel.selectedTag) { _, newValue in
                if newValue == nil {
                    viewModel.selectedEvent = nil
                    viewModel.selectedPlace = nil
                    withAnimation {
                        viewModel.position = .automatic
                        viewModel.showInfo = false
                    }
                } else if let place = viewModel.filteredPlaces.first(where: { $0.tag == newValue}) {
                    viewModel.selectedEvent = nil
                    viewModel.selectedPlace = place
                    withAnimation {
                        viewModel.position = .camera(MapCamera(centerCoordinate: place.coordinate, distance: 500))
                    }
                    viewModel.showInfo = true
                } else if let event = viewModel.filteredEvents.first(where: { $0.tag == newValue}) {
                    viewModel.selectedPlace = nil
                    viewModel.selectedEvent = event
                    withAnimation {
                        viewModel.position = .camera(MapCamera(centerCoordinate: event.coordinate, distance: 500))
                        viewModel.showInfo = true
                    }
                }
            }
        }
    }
    
    private func placeCell(place: Place) -> some View {
        NavigationLink {
            PlaceView(viewModel: PlaceView.PlaceViewModel(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, commentsNetworkManager: viewModel.commentsNetworkManager, notificationsManager: viewModel.notificationsManager, showOpenInfo: true))
            
        } label: {
            HStack {
                HStack(spacing: 20) {
                    if let url = place.avatar {
                        ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                            AppColors.lightGray6
                        }
                        .clipShape(.circle)
                        .overlay(Circle().stroke(AppColors.lightGray5, lineWidth: 1))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.name)
                                .multilineTextAlignment(.leading)
                                .font(.body)
                                .bold()
                                .foregroundStyle(.primary)
                        if place.isOpenNow() {
                            Text("open now")
                                .bold()
                                .foregroundColor(.green)
                        }
                        HStack(alignment: .top, spacing: 5) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(place.address)
//                                                    if showCountryCity {
//                                                        HStack(spacing: 5) {
//                                                            Text(place.city?.name ?? "")
//                                                                .bold()
//                                                            Text("•")
//                                                            Text(place.city?.region?.country?.name ?? "")
//                                                        }
//                                                    }
                            }
                            HStack(alignment: .top, spacing: 5) {
                                Text("•")
                                Text(place.distanceText)
                            }
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if place.isLiked {
                        AppImages.iconHeartFill
                            .foregroundColor(.red)
                    }
                }
                AppImages.iconRight
                    .foregroundStyle(.secondary)
                    .bold()
                
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private func eventCell(event: Event) -> some View {
        Button {
            selectedEvent = event
        } label: {
            HStack(spacing: 20) {
                VStack(spacing: 0) {
                    Text(event.name)
                        .font(.body)
                        .bold()
                        .tint(.primary)
     
                    if let location = event.location {
                        Text(location)
                            .font(.footnote)
                            .bold()
                            .tint(.secondary)
                    }
                    Text(event.address)
                        .font(.footnote)
                        .tint(.secondary)
                    
                    // todo тот же код в EventView
                    if let finishDate = event.finishDate {
                        if finishDate.isSameDayWithOtherDate(event.startDate) {
                            Text(event.startDate.formatted(date: .long, time: .omitted))
                                .font(.footnote)
                                .bold()
                                .tint(.primary)
                            HStack {
                                if let startTime = event.startTime {
                                    HStack(spacing: 5) {
                                        AppImages.iconClock
                                            .font(.caption)
                                        Text(startTime.formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                    }
                                    .tint(.secondary)
                                }
                                if let finishTime = event.finishTime {
                                    Text("—")
                                        .tint(.secondary)
                                        .frame(width: 20, alignment: .center)
                                    HStack(spacing: 5) {
                                        AppImages.iconClock
                                            .font(.caption)
                                        Text(finishTime.formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                    }
                                    .tint(.secondary)
                                }
                            }
                            
                        } else {
                            HStack(alignment: .top) {
                                VStack(spacing: 5) {
                                    Text(event.startDate.formatted(date: .long, time: .omitted))
                                        .font(.footnote)
                                        .bold()
                                        .tint(.primary)
                                    if let startTime = event.startTime {
                                        HStack(spacing: 5) {
                                            AppImages.iconClock
                                                .font(.caption)
                                            Text(startTime.formatted(date: .omitted, time: .shortened))
                                                .font(.caption)
                                        }
                                        .tint(.secondary)
                                    }
                                }
                                Text("—")
                                    .frame(width: 20, alignment: .center)
                                VStack(spacing: 5) {
                                    Text(finishDate.formatted(date: .long, time: .omitted))
                                        .font(.footnote)
                                        .bold()
                                        .tint(.primary)
                                    if let finishTime = event.finishTime {
                                        HStack(spacing: 5) {
                                            AppImages.iconClock
                                                .font(.caption)
                                            Text(finishTime.formatted(date: .omitted, time: .shortened))
                                                .font(.caption)
                                        }
                                        .tint(.secondary)
                                    }
                                }
                            }
                        }
                    } else {
                        Text(event.startDate.formatted(date: .long, time: .omitted))
                            .font(.footnote)
                            .bold()
                            .tint(.primary)
                        if let startTime = event.startTime {
                            HStack(spacing: 5) {
                                AppImages.iconClock
                                    .font(.caption)
                                Text(startTime.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                            }
                            .tint(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 10) {
                    AppImages.iconInfoCircle
                        .foregroundStyle(.secondary)
                        .bold()
                    if event.isLiked {
                        AppImages.iconHeartFill
                            .foregroundStyle(.red)
                    }
                    if event.isFree {
                        Text("free")
                            .font(.footnote)
                            .bold()
                            .foregroundStyle(AppColors.background)
                            .padding(5)
                            .padding(.horizontal, 5)
                            .background(.green)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .transition(.move(edge: .bottom).combined(with: .opacity))
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
