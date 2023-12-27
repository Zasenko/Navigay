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
    
    //    @State private var selectedResult: MKMapItem?
    //    @State private var route: MKRoute?
    
    @ObservedObject var viewModel: MapViewModel
    
    init(viewModel: MapViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
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
                            MapEventPin(event: event, url: url, selectedTag: $viewModel.selectedTag)
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
            .sheet(isPresented: $viewModel.showInfo){
                viewModel.showInfo = false
                viewModel.selectedPlace = nil
                viewModel.selectedEvent = nil
                viewModel.selectedTag = nil
            } content: {
                VStack {
                    if let selectedEvent = viewModel.selectedEvent {
                        makeEventInfoView(event: selectedEvent)
                    } else if let selectedPlace = viewModel.selectedPlace {
                        makePlaceInfoView(place: selectedPlace)
                    } else {
                        EmptyView()
                            .frame(width: 1, height: 1)
                    }
                }
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(25)           
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.showInfo {
                        MapSortingMenuView(categories: $viewModel.categories, selectedCategory: $viewModel.selectedCategory)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !viewModel.showInfo {
                        Button {
                            withAnimation {
                                viewModel.showMap.toggle()
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
            }
            .onChange(of: viewModel.selectedCategory, initial: true) { _, newValue in
                viewModel.filterLocations(category: newValue)
            }
            .onChange(of: viewModel.selectedTag) { _, newValue in
                if newValue == nil {
                    viewModel.selectedEvent = nil
                    viewModel.selectedPlace = nil
                    withAnimation(.spring()) {
                        viewModel.position = .automatic
                        viewModel.showInfo = false
                    }
                } else if let place = viewModel.filteredPlaces.first(where: { $0.tag == newValue}) {
                    viewModel.selectedEvent = nil
                    viewModel.selectedPlace = place
                    withAnimation(.spring()) {
                        viewModel.position = .camera(MapCamera(centerCoordinate: place.coordinate, distance: 500))
                    }
                    viewModel.showInfo = true
                } else if let event = viewModel.filteredEvents.first(where: { $0.tag == newValue}) {
                    viewModel.selectedPlace = nil
                    viewModel.selectedEvent = event
                    withAnimation(.spring()) {
                        viewModel.position = .camera(MapCamera(centerCoordinate: event.coordinate, distance: 500))
                        viewModel.showInfo = true
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makePlaceInfoView(place: Place) -> some View {
        // todo get fuul info (placeNetworkManager)
        ScrollView {
            HStack {
                if let url = place.avatar {
                    ImageLoadingView(url: url, width: 80, height: 80, contentMode: .fill) {
                        Color.orange
                    }
                    .clipShape(Circle())
                    .padding()
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.type.getName().uppercased())
                        .font(.caption).bold()
                        .foregroundStyle(.secondary)
                    Text(place.name)
                        .font(.title).bold()
                        .foregroundColor(.primary)
                    Text(place.address)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            TagsView(tags: place.tags)
                .padding()
            
            VStack {
                ForEach(place.timetable.sorted(by: { $0.day.rawValue < $1.day.rawValue } )) { day in
                    let dayOfWeek = Date().dayOfWeek
                    HStack {
                        Text(day.day.getString())
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if dayOfWeek == day.day {
                            if place.isOpenNow() {
                                Text("open now")
                                    .font(.footnote).bold()
                                    .foregroundColor(.green)
                                    .padding(.trailing)
                            }
                        }
                        Text(day.open.formatted(date: .omitted, time: .shortened))
                        Text("—")
                        Text(day.close.formatted(date: .omitted, time: .shortened))
                    }
                    .font(.caption)
                    Divider()
                }
            }
            .padding()
        }
        .padding(.horizontal)
        .padding(.top)
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func makeEventInfoView(event: Event) -> some View {
        // todo get fuul info (EventnetworkManager)
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.title).bold()
                    .foregroundColor(.primary)
                Text(event.address)
                    .font(.body)
                    .foregroundColor(.secondary)
                //   .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            // location = decodedEvent.location
//            type = decodedEvent.type
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Start")
                        .font(.title2)
                        .bold()
                        .offset(x: 30)
                    HStack(spacing: 10) {
                        AppImages.iconCalendar
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(AppColors.lightGray5)
                            .frame(width: 20, height: 20, alignment: .leading)
                        Text(event.startDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.callout)
                    }
                    if let startTime = event.startTime {
                        HStack {
                            AppImages.iconClock
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(AppColors.lightGray5)
                                .frame(width: 20, height: 20, alignment: .leading)
                            Text(startTime.formatted(date: .omitted, time: .shortened))
                                .font(.callout)
                        }
                    }
                }
                .padding()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
                
                if let finishDate = event.finishDate {
                    VStack(alignment: .leading) {
                        Text("Finish")
                            .font(.title2)
                            .bold()
                            .offset(x: 30)
                        HStack(spacing: 10) {
                            AppImages.iconCalendar
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(AppColors.lightGray5)
                                .frame(width: 20, height: 20, alignment: .leading)
                            Text(finishDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.callout)
                        }
                        if let finishTime = event.finishTime {
                            HStack {
                                AppImages.iconClock
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(AppColors.lightGray5)
                                    .frame(width: 20, height: 20, alignment: .leading)
                                Text(finishTime.formatted(date: .omitted, time: .shortened))
                                    .font(.callout)
                            }
                        }
                    }
                    .padding()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
            TagsView(tags: event.tags)
                .padding(.bottom)
//            poster = decodedEvent.poster
            
            if event.isFree {
                //todo
                Text("Free event")
                    .padding()
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .scrollIndicators(.hidden)
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
