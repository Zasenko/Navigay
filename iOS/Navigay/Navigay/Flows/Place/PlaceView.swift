//
//  PlaceView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData
import MapKit

//TODO: сообщить об ошибке (место закрыто, неправильная информация)
// рейтинг заведения

struct PlaceView: View {
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PlaceViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    
    // MARK: - Init
    
    init(viewModel: PlaceViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
        
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                listView
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.showHeaderTitle {
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 0) {
                            Text(viewModel.place.type.getName().uppercased())
                                .font(.caption).bold()
                                .foregroundStyle(.secondary)
                            Text(viewModel.place.name)
                                .font(.headline).bold()
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            dismiss()
                        }
                    } label: {
                        AppImages.iconLeft
                            .bold()
                            .frame(width: 30, height: 30, alignment: .leading)
                    }
                    .tint(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            viewModel.place.isLiked.toggle()
                            guard let user = authenticationManager.appUser else { return }
                            if let index = user.likedPlaces.firstIndex(where: {$0 == viewModel.place.id} ) {
                                user.likedPlaces.remove(at: index)
                            } else {
                                user.likedPlaces.append(viewModel.place.id)
                            }
                        } label: {
                            Image(systemName: viewModel.place.isLiked ? "heart.fill" : "heart")
                                .bold()
                                .frame(width: 30, height: 30, alignment: .leading)
                        }
                        .tint(viewModel.place.isLiked ? .red :  .secondary)
                        if let user = authenticationManager.appUser, (user.status == .admin || user.status == .moderator) {
                            Menu {
                                NavigationLink("Edit Place") {
                                    EditPlaceView(viewModel: EditPlaceViewModel(id: viewModel.place.id, place: viewModel.place, user: user, networkManager: EditPlaceNetworkManager(networkManager: authenticationManager.networkManager), errorManager: viewModel.errorManager))
                                }
                                NavigationLink("Add Event") {
                                    NewEventView(viewModel: NewEventViewModel(user: user, place: viewModel.place, copy: nil, networkManager: EditEventNetworkManager(networkManager: authenticationManager.networkManager), errorManager: viewModel.errorManager))
                                }
                            } label: {
                                AppImages.iconSettings
                                    .bold()
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .onAppear() {
                viewModel.allPhotos = viewModel.place.getAllPhotos()
                viewModel.getEventsFromDB()
            }
            .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
                viewModel.showCalendar = false
                if let date = newValue {
                    viewModel.getEvents(for: date)
                } else {
                    viewModel.showUpcomingEvents()
                }
            }
            .sheet(isPresented:  $viewModel.showCalendar) {} content: {
                CalendarView(selectedDate: $viewModel.selectedDate, eventsDates: $viewModel.eventsDates)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(25)
            }
            .fullScreenCover(item: $viewModel.selectedEvent) { event in
                EventView(viewModel: EventView.EventViewModel.init(event: event, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, commentsNetworkManager: viewModel.commentsNetworkManager))
            }
        }
    }
    
    // MARK: - Views
    
    private var listView: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                List {
                    headerView
                    headerSection(width: proxy.size.width)
                    
                    TagsView(tags: viewModel.place.tags)
                        .padding(.bottom)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    
                    createMap(size: proxy.size)
                    
                    if !viewModel.place.timetable.isEmpty {
                        TimetableView(place: viewModel.place, showOpenInfo: viewModel.showOpenInfo)
                    }
                    
                    
                    if let otherInfo = viewModel.place.otherInfo {
                        Text(otherInfo)
                        //.font(.caption)
                            .foregroundStyle(.secondary)
                            .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 50, trailing: 20))
                            .listSectionSeparator(.hidden)
                    }
                    
                    
                    ContactInfoView(phone: viewModel.place.phone, www: viewModel.place.www, facebook: viewModel.place.facebook, instagram: viewModel.place.instagram)
                        .listRowInsets(EdgeInsets(top: 50, leading: 20, bottom: 50, trailing: 20))
                        .listSectionSeparator(.hidden)
                    
                    if viewModel.eventsCount > 0 {
                        EventsView(modelContext: viewModel.modelContext, selectedDate: $viewModel.selectedDate, displayedEvents: $viewModel.displayedEvents, eventsCount: $viewModel.eventsCount, todayEvents: $viewModel.todayEvents, upcomingEvents: $viewModel.upcomingEvents, eventsDates: $viewModel.eventsDates, selectedEvent: $viewModel.selectedEvent, showCalendar: $viewModel.showCalendar, size: proxy.size, showLocation: false)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    
                    if let about = viewModel.place.about {
                        Text(about)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 50, leading: 20, bottom: 50, trailing: 20))
                    }
                    
                    if viewModel.place.photos.count > 0 {
                        //todo фотографии должны открываться
                        LazyVGrid(columns: viewModel.gridLayoutPhotos, spacing: 2) {
                            ForEach(viewModel.place.photos, id: \.self) { url in
                                ImageLoadingView(url: url, width: (proxy.size.width - 4) / 3, height: (proxy.size.width - 4) / 3, contentMode: .fill) {
                                    AppColors.lightGray6 //TODO animation
                                }
                                .clipped()
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 50, leading: 0, bottom: 50, trailing: 0))
                    }
                    CommentsView(viewModel: CommentsViewModel(commentsNetworkManager: viewModel.commentsNetworkManager, errorManager: viewModel.errorManager, size: proxy.size, place: viewModel.place))
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

                    Color.clear
                        .frame(height: 50)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .buttonStyle(PlainButtonStyle())
                .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
                    withAnimation {
                        scrollProxy.scrollTo("UpcomingEvents", anchor: .top)
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 20) {
            if let url = viewModel.place.avatar {
                ImageLoadingView(url: url, width: 60, height: 60, contentMode: .fill) {
                    Color.orange
                }
                .clipShape(Circle())
                .overlay(Circle().stroke(AppColors.lightGray5, lineWidth: 1))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.place.name)
                    .font(.title2).bold()
                    .foregroundColor(.primary)
                Text(viewModel.place.address)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .onAppear {
            viewModel.showHeaderTitle = false
        }
        .onDisappear {
            viewModel.showHeaderTitle = true
        }
    }
    
    @ViewBuilder
    private func headerSection(width: CGFloat) -> some View {
        ZStack {
            if !viewModel.allPhotos.isEmpty {
                PhotosTabView(allPhotos: $viewModel.allPhotos, width: width)
                    .frame(width: width, height: ((width / 4) * 5) + 20)///20 is spase after tabview for circls
            }
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    @ViewBuilder
    private func createMap(size: CGSize) -> some View {
        VStack {
            Map(position: $viewModel.position, interactionModes: [], selection: $viewModel.selectedTag) {
                Marker(viewModel.place.address, monogram: Text(viewModel.place.type.getImage()), coordinate: viewModel.place.coordinate)
                    .tint(viewModel.place.type.getColor())
                    .tag(viewModel.place.tag)
                    .annotationTitles(.hidden)
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
            .mapControlVisibility(.hidden)
            .frame(height: size.width)
            .clipShape(RoundedRectangle(cornerRadius: 0))
            .onAppear {
                viewModel.position = .camera(MapCamera(centerCoordinate: viewModel.place.coordinate, distance: 1500))
            }
//            Text(viewModel.place.address)
//                .font(.callout)
//                .foregroundColor(.secondary)
//                .padding()
            Button {
                viewModel.goToMaps()
            } label: {
                HStack {
                    AppImages.iconLocation
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25, alignment: .leading)
                    Text("Open in Maps")
                        .font(.caption)
                        .bold()
                }
            }
            .padding()
            .foregroundColor(.primary)
            .background(AppColors.lightGray6)
            .clipShape(Capsule(style: .continuous))
            .buttonStyle(.borderless)
            .padding(.bottom, 40)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

//#Preview {
//    let decodedPlace = DecodedPlace(id: 0, name: "HardOn", type: .bar, address: "bla bla", latitude: 48.19611791448819, longitude: 16.357055501725107, lastUpdate: "2023-11-19 08:00:45", avatar: nil, mainPhoto: nil, photos: nil, tags: nil, timetable: nil, otherInfo: nil, about: nil, www: nil, facebook: nil, instagram: nil, phone: nil, city: nil, cityId: nil, events: nil)
//    let appSettingsManager = AppSettingsManager()
//    let errorManager = ErrorManager()
//    let networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
//    let placeNetworkManager = PlaceNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//    let eventNetworkManager = EventNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//    let commentsNetworkManager = CommentsNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//    
//    let placeDataManager = PlaceDataManager()
//    let eventDataManager = EventDataManager()
//    let place = Place(decodedPlace: decodedPlace)
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            AppUser.self, Country.self, Region.self, City.self, Event.self, Place.self, User.self
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
//    let authNetworkManager = AuthNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//    let keychainManager = KeychainManager()
//    let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: authNetworkManager, errorManager: errorManager)
//    return PlaceView(viewModel: PlaceView.PlaceViewModel(place: place,
//                                                         modelContext: ModelContext(sharedModelContainer),
//                                                         placeNetworkManager: placeNetworkManager,
//                                                         eventNetworkManager: eventNetworkManager,
//                                                         errorManager: errorManager,
//                                                         placeDataManager: placeDataManager,
//                                                         eventDataManager: eventDataManager, commentsNetworkManager: commentsNetworkManager,
//                                                         showOpenInfo: false))
//    .environmentObject(authenticationManager)
//}

struct TagsView: View {
    
    //MARK: - Properties
    
    //MARK: - Private Properties
    
    let tags: [Tag]
    
    @State private var totalHeight: CGFloat = .zero
    
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits
    
    init(tags: [Tag]) {
        self.tags = tags
    }
    
    //MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                GeometryReader { geometry in
                    self.generateContent(for: tags, color: .secondary, in: geometry, totalHeight: $totalHeight)
                }
            }
            .frame(height: totalHeight)
            .padding(.vertical)
        }
    }
    
    //MARK: - Private functions
    
    private func generateContent(for tags: [Tag], color: Color, in g: GeometryProxy, totalHeight: Binding<CGFloat>) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self) { tag in
                item(tag: tag, color: color)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == tags.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader(totalHeight))
    }
    
    private func item(tag: Tag, color: Color) -> some View {
        Text(tag.getString())
            .font(.caption)
            .bold()
            .foregroundStyle(color)
            .modifier(CapsuleSmall(foreground: .primary))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
