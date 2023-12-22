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
    
    @State private var showInfo: Bool = false
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
            .sheet(isPresented: $showInfo){
                showInfo = true
                selectedPlace = nil
                selectedEvent = nil
                selectedTag = nil
            } content: {
                VStack {
                    if let selectedEvent {
                        makeEventInfoView(event: selectedEvent)
                    } else if let selectedPlace {
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
                    if !showInfo {
                        MapSortingMenuView(categories: $categories, selectedCategory: $selectedCategory)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !showInfo {
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
                        showInfo = false
                    }
                } else if let place = filteredPlaces.first(where: { $0.tag == newValue}) {
                    selectedEvent = nil
                    selectedPlace = place
                    withAnimation(.spring()) {
                        position = .camera(MapCamera(centerCoordinate: place.coordinate, distance: 500))
                    }
                    showInfo = true
                } else if let event = filteredEvents.first(where: { $0.tag == newValue}) {
                    selectedPlace = nil
                    selectedEvent = event
                    withAnimation(.spring()) {
                        position = .camera(MapCamera(centerCoordinate: event.coordinate, distance: 500))
                        showInfo = true
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makePlaceInfoView(place: Place) -> some View {
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
                showInfo = true
            } else if filteredPlaces.isEmpty, filteredEvents.count == 1, let event = filteredEvents.first {
                selectedTag = event.tag
                showInfo = true
            } else {
                position  = .automatic
                showInfo = false
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
