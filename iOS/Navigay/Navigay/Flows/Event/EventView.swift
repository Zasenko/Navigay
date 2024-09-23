//
//  EventView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData
import MapKit
import AudioToolbox

struct EventView: View {
    
    // MARK: - Private Properties

    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @State private var viewModel: EventViewModel
    @State private var show: Bool = false
    @Namespace private var namespace
    @State private var coverOffset = CGSize.zero
    private let smallCoverSize: CGFloat = 60
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Init
    
    init(viewModel: EventViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        if show {
                            coverSmall(size: proxy.size)
                        } else {
                            cover(geometryProxy: proxy)
                                .frame(height: proxy.size.height + proxy.safeAreaInsets.bottom + (coverOffset.height * 0.5))
                                .gesture(dragGesture)
                        }
                        Group {
                            Divider()
                            listView(size: proxy.size)
                        }
                    }
                    ErrorView(viewModel: ErrorViewModel(errorManager: viewModel.errorManager), moveFrom: .bottom, alignment: .bottom)
                }
                .background {
                    EventBackgroundView(show: $show, image: $viewModel.image)
                        .onTapGesture {
                            show.toggle()
                            AudioServicesPlaySystemSound(1104)
                        }
                        .gesture(dragGesture)
                }
                .animation(.interactiveSpring, value: show)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        AppImages.iconLeft
                            .bold()
                            .frame(width: 30, height: 30, alignment: .leading)
                    }
                    .tint(.primary)
                }
                if show {
                    ToolbarItem(placement: .principal) {
                        Text(viewModel.event.name)
                            .font(.headline).bold()
                    }
                } else {
                    if viewModel.event.isFree {
                        ToolbarItem(placement: .principal) {
                            Text("free event")
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
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            viewModel.likeButtonTapped()
                            guard let user = authenticationManager.appUser else { return }
                            if user.likedEvents.contains(where: {$0 == viewModel.event.id} ) {
                                user.likedEvents.removeAll(where: {$0 == viewModel.event.id})
                            } else {
                                user.likedEvents.append(viewModel.event.id)
                            }
                        } label: {
                            Image(systemName: viewModel.event.isLiked ? "heart.fill" : "heart")
                                .bold()
                                .frame(width: 30, height: 30, alignment: .leading)
                        }
                        .tint(.red)
                        if let user = authenticationManager.appUser, user.status == .admin {
                            Menu {
                                NavigationLink("Edit Event") {
                                    EditEventView(viewModel: EditEventViewModel(eventID: viewModel.event.id, user: user, event: viewModel.event, networkManager: EditEventNetworkManager(networkManager: authenticationManager.networkManager), errorManager: viewModel.errorManager))
                                }
                                NavigationLink("Clone Event") {
                                    NewEventView(viewModel: NewEventViewModel(user: user, place: nil, copy: viewModel.event, networkManager: EditEventNetworkManager(networkManager: authenticationManager.networkManager), errorManager: viewModel.errorManager))
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
            .onChange(of: viewModel.event.poster) { _, newValue in
                Task {
                    guard let url = newValue,
                          let image = await ImageLoader.shared.loadImage(urlString: url)
                    else { return }
                    await MainActor.run {
                        viewModel.image = image
                    }
                }
            }
        }
    }
    
    // MARK: - Views
        
    private func listView(size: CGSize) -> some View {
        List {
            if viewModel.event.about != nil || !viewModel.event.tags.isEmpty {
                Section {
                    Text("Information")
                        .font(.title2).bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                    VStack {
                        if viewModel.event.about != nil {
                            Text(viewModel.event.about ?? "")
                                .font(.callout)
                                .foregroundStyle(.primary)
                                .lineSpacing(9)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                        if !viewModel.event.tags.isEmpty {
                            TagsView(tags: viewModel.event.tags)
                                .padding()
                        }
                        if !viewModel.event.isFree {
                            FeeView(fee: $viewModel.event.fee, tickets: $viewModel.event.tickets)
                        }
                    }
                    .padding(.bottom, 50)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
            }
            Section {
                map(size: size)
                    .padding(.bottom, 50)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            if viewModel.event.phone != nil || viewModel.event.www != nil || viewModel.event.facebook != nil || viewModel.event.instagram != nil || viewModel.event.tickets != nil {
                Section {
                    Text("Event details")
                        .font(.title2).bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                    ContactInfoView(phone: $viewModel.event.phone, www: $viewModel.event.www, facebook: $viewModel.event.facebook, instagram: $viewModel.event.instagram)
                        .padding(.bottom, 50)
                        .padding(.top, 20)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
            }
            if (viewModel.event.organizer != nil || viewModel.event.place != nil) {
                Section {
                    Text(viewModel.event.organizer != nil && viewModel.event.place != nil ? "Organizers" : "Organizer")
                        .font(.title2).bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                  //  VStack(alignment: .leading, spacing: 10) {
                        if let organizer = viewModel.event.organizer {
                            NavigationLink {
                                EmptyView()
                            } label: {
                                OrganizerCell(organizer: organizer, showCountryCity: false)
                            }
                        }
                        if let place = viewModel.event.place {
                            NavigationLink {
                                PlaceView(viewModel: PlaceView.PlaceViewModel(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, commentsNetworkManager: viewModel.commentsNetworkManager, notificationsManager: viewModel.notificationsManager, showOpenInfo: false))
                            } label: {
                                PlaceCell(place: place, showOpenInfo: false, showDistance: false, showCountryCity: false, showLike: true, showType: true, showAddress: false)
                            }
                        }
                //    }
//                    .padding()
//                    .padding(.bottom, 50)
//                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowSeparator(.hidden)
            }
            //TODO: - upcoming events from organizers
            // TODO:
            //                Section {
            //                    Button {
            //                        EventNetworkManager.sendComplaint(eventId: Int, user: AppUser, reason: String) async throws
            //                    } label: {
            //                        Text("Пожаловаться")
            //                    }
            //
            //                }
            //
            //
            //            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            //            .listRowSeparator(.hidden)
            
            Color.clear
                .frame(height: 50)
                .listSectionSeparator(.hidden)
        }
        .listStyle(.plain)
        .listSectionSeparator(.hidden)
        .scrollIndicators(.hidden)
    }
    
    private func map(size: CGSize) -> some View {
        VStack {
            Text("Location")
                .font(.title2)
                .bold()
                .foregroundStyle(.primary)
                .padding(.top)
            Map(position: $viewModel.position, interactionModes: [.zoom], selection: $viewModel.selectedTag) {
                Marker(viewModel.event.location ?? viewModel.event.address, coordinate: viewModel.event.coordinate)
                    .tint(.primary)
                    .tag(viewModel.event.tag)
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
            .mapControlVisibility(.hidden)
            .frame(maxWidth: .infinity)
            .frame(height: (size.width / 4) * 5)
            .onChange(of: viewModel.selectedTag) { _, newValue in
                if newValue != nil {
                    withAnimation {
                        viewModel.centerMapPin()
                    }
                }
            }

            HStack(spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    AppImages.iconLocationFill
                    VStack(alignment: .leading, spacing: 0) {
                        Text(viewModel.event.address).bold().foregroundStyle(.primary)
                        Text("\(viewModel.event.city?.name ?? "") • \(viewModel.event.city?.region?.country?.name ?? "")")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .baselineOffset(0)
                .frame(maxWidth: .infinity)
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
            }
            .padding(.top)
            .padding(.horizontal)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    private func coverSmall(size: CGSize) -> some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.bottom, 10)
            HStack(spacing: 20) {
                viewModel.image?
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 1))
                    .shadow(color: .black.opacity(0.2), radius: 0, x: 0, y: 0)
                    .matchedGeometryEffect(id: "img", in: namespace)
                    .frame(maxHeight: smallCoverSize)
                compactTimeView
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .onTapGesture {
                show.toggle()
                AudioServicesPlaySystemSound(1104)
            }
            
        }
        .padding(.bottom, 10)
    }
    
    private func cover(geometryProxy: GeometryProxy) -> some View {
        VStack {
            Spacer()
            viewModel.image?
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 1))
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 10)
                .matchedGeometryEffect(id: "img", in: namespace)
                .frame(maxWidth: geometryProxy.size.width + (coverOffset.height * 0.5))
                .padding()
            Spacer()
           
            VStack(spacing: 0) {
                Text(viewModel.event.name)
                    .font(.title).bold()
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .layoutPriority(1)
                if let finishDate = viewModel.event.finishDate {
                    if finishDate.isSameDayWithOtherDate(viewModel.event.startDate) {
                        Text(viewModel.event.startDate.formatted(date: .long, time: .omitted))
                            .font(.subheadline)
                            .bold()
                        HStack {
                            if let startTime = viewModel.event.startTime {
                                HStack(spacing: 5) {
                                    AppImages.iconClock
                                        .font(.callout)
                                    Text(startTime.formatted(date: .omitted, time: .shortened))
                                        .font(.callout)
                                }
                                .foregroundStyle(.secondary)
                            }
                            if let finishTime = viewModel.event.finishTime {
                                Text("—")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20, alignment: .center)
                                HStack(spacing: 5) {
                                    AppImages.iconClock
                                        .font(.callout)
                                    Text(finishTime.formatted(date: .omitted, time: .shortened))
                                        .font(.callout)
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        HStack(alignment: .top) {
                            VStack(spacing: 5) {
                                Text(viewModel.event.startDate.formatted(date: .long, time: .omitted))
                                    .font(.subheadline)
                                    .bold()
                                if let startTime = viewModel.event.startTime {
                                    HStack(spacing: 5) {
                                        AppImages.iconClock
                                            .font(.callout)
                                        Text(startTime.formatted(date: .omitted, time: .shortened))
                                            .font(.callout)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            }
                            Text("—")
                                .frame(width: 20, alignment: .center)
                            VStack(spacing: 5) {
                                Text(finishDate.formatted(date: .long, time: .omitted))
                                    .font(.subheadline)
                                    .bold()
                                if let finishTime = viewModel.event.finishTime {
                                    HStack(spacing: 5) {
                                        AppImages.iconClock
                                            .font(.callout)
                                        Text(finishTime.formatted(date: .omitted, time: .shortened))
                                            .font(.callout)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } else {
                    Text(viewModel.event.startDate.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                        .bold()
                    if let startTime = viewModel.event.startTime {
                        HStack(spacing: 5) {
                            AppImages.iconClock
                                .font(.callout)
                            Text(startTime.formatted(date: .omitted, time: .shortened))
                                .font(.callout)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
            Image(systemName: "chevron.compact.up")
                .font(.largeTitle)
                .foregroundStyle(.ultraThinMaterial)
                .bold()
                .padding()
                .padding(.bottom, geometryProxy.safeAreaInsets.bottom)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
                show.toggle()
            AudioServicesPlaySystemSound(1104)
        }
    }
        
    private var compactTimeView: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .top, spacing: 10) {
                VStack(spacing: 0) {
                    AppImages.iconCalendar
                        .frame(height: smallCoverSize / 3)
                    if viewModel.event.startTime != nil {
                        AppImages.iconClock
                            .frame(height: smallCoverSize / 3)
                    }
                }
                HStack(alignment: .top, spacing: 20) {
                    if viewModel.event.finishDate == nil || viewModel.event.startDate.isSameDayWithOtherDate(viewModel.event.finishDate) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(viewModel.event.startDate.formatted(.dateTime.day().month(.wide)))
                                .foregroundStyle(.primary)
                                .bold()
                                .frame(height: smallCoverSize / 3)
                            if viewModel.event.startTime != nil || viewModel.event.finishTime != nil {
                                HStack(spacing: 5) {
                                    Text(viewModel.event.startTime?.formatted(date: .omitted, time: .shortened) ?? "...")
                                    if viewModel.event.finishTime != nil {
                                        Text("—")
                                        Text(viewModel.event.finishTime?.formatted(date: .omitted, time: .shortened) ?? "")
                                    }
                                }
                                .frame(height: smallCoverSize / 3)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(viewModel.event.startDate.formatted(.dateTime.day().month(.wide)))
                                .foregroundStyle(.primary)
                                .bold()
                                .frame(height: smallCoverSize / 3)
                            
                            if viewModel.event.startTime != nil {
                                Text(viewModel.event.startTime?.formatted(date: .omitted, time: .shortened) ?? "")
                                    .foregroundStyle(.primary).bold()
                                    .frame(height: smallCoverSize / 3)
                            }
                        }
                        Divider()
                            .frame(height: (viewModel.event.startTime != nil || viewModel.event.finishTime != nil) ? (smallCoverSize / 3) * 2 : smallCoverSize / 3)
                        HStack(alignment: .top, spacing: 10) {
                            VStack(spacing: 0) {
                                AppImages.iconCalendar
                                    .frame(height: smallCoverSize / 3)
                                if viewModel.event.finishTime != nil {
                                    AppImages.iconClock
                                        .frame(height: smallCoverSize / 3)
                                }
                            }
                            VStack(alignment: .leading, spacing: 0) {
                                Text(viewModel.event.finishDate?.formatted(.dateTime.day().month(.wide)) ?? "")
                                    .frame(height: smallCoverSize / 3)
                                if viewModel.event.finishTime != nil {
                                    Text(viewModel.event.finishTime?.formatted(date: .omitted, time: .shortened) ?? "")
                                        .frame(height: smallCoverSize / 3)
                                }
                            }
                        }
                    }
                }
            }
            .foregroundStyle(.secondary)
            .font(.caption)
            if viewModel.event.location != nil {
                HStack(spacing: 10) {
                    AppImages.iconLocationFill
                    Text(viewModel.event.location ?? "")
                        .lineLimit(1)
                }
                .frame(height: smallCoverSize / 3)
            }
        }
        .foregroundStyle(.secondary)
        .font(.caption)
    }
    
    // MARK: - Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if !show {
                    coverOffset.height = gesture.translation.height
                }
            }
            .onEnded { gesture in
                if !show && gesture.translation.height < -100 {
                    show.toggle()
                    coverOffset.height = .zero
                    AudioServicesPlaySystemSound(1104)
                } else {
                    coverOffset.height = .zero
                }
            }
    }
}

#Preview {
    let errorManager: ErrorManagerProtocol = ErrorManager()
    let keychainManager: KeychainManagerProtocol = KeychainManager()
    let appSettingsManager: AppSettingsManagerProtocol = AppSettingsManager()
    let networkMonitorManager: NetworkMonitorManagerProtocol = NetworkMonitorManager(errorManager: errorManager)
    let notificationsManager = NotificationsManager()
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AppUser.self, Country.self, Region.self, City.self, Event.self, Place.self, User.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    let networkManager = NetworkManager(session: URLSession.shared, networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager, keychainManager: keychainManager)
    
    let aroundNetworkManager = AroundNetworkManager(networkManager: networkManager)
    let placeNetworkManager = PlaceNetworkManager(networkManager: networkManager)
    let eventNetworkManager = EventNetworkManager(networkManager: networkManager)
    let commentsNetworkManager = CommentsNetworkManager(networkManager: networkManager)
    let authNetworkManager = AuthNetworkManager(networkManager: networkManager)
    
    let placeDataManager = PlaceDataManager()
    let eventDataManager = EventDataManager()
    let catalogDataManager = CatalogDataManager()

    let decodedEvent = DecodedEvent(id: 0,
                                    name: "HARD ON party this Saturday",
                                    type: .party,
                                    startDate: "2024-04-23",
                                    startTime: "13:34:00",
                                    finishDate: "2024-04-24",
                                    finishTime: "19:20:00",
                                    address: "Kaertner Strasse, 47",
                                    latitude: 48.6,
                                    longitude: 16.8,
                                    poster: "https://i.pinimg.com/originals/39/1e/a9/391ea9e2bb4de87e578d10cb2dd8c347.jpg",
                                    smallPoster: "https://i.pinimg.com/originals/39/1e/a9/391ea9e2bb4de87e578d10cb2dd8c347.jpg",
                                    isFree: false,
                                    tags: nil,
                                    location: "Cafe Savoy",
                                    lastUpdate: "2023-11-16 17:26:12",
                                    about: nil,
                                    fee: nil,
                                    tickets: nil,
                                    www: nil,
                                    facebook: nil,
                                    instagram: nil,
                                    phone: nil,
                                    place: nil,
                                    organizer: nil,
                                    city: nil,
                                    cityId: nil)
    let event = Event(decodedEvent: decodedEvent)
    event.isLiked = true
    event.poster = "https://papik.pro/grafic/uploads/posts/2023-03/1680269471_papik-pro-p-tarantino-poster-1.jpg"//https://i.pinimg.com/originals/39/1e/a9/391ea9e2bb4de87e578d10cb2dd8c347.jpg"
    event.about = "It hides successfully, but I cannot get it to re-enable it when the user navigates back to the parent. I think this is because when the user goes backwards in the navigation the parent view does not get refreshed. How did you solve this issue?"
    event.tags = [.bar, .pool, .dj, .dragShow, .adultsOnly, .gayFriendly]
    event.www = "www.google.com"
    event.fee = "fee information"
    event.tickets = "fee information"
    event.www = "fee information"
    event.facebook = "fee information"
    event.instagram = "fee information"
    event.phone = "+4565566898"
    let decodedOrganizer = DecodedOrganizer(id: 0, name: "LMC Vienna", lastUpdate: "2023-12-02 12:00:00", avatar: "https://i.pinimg.com/originals/39/1e/a9/391ea9e2bb4de87e578d10cb2dd8c347.jpg", mainPhoto: nil, photos: nil, otherInfo: nil, about: nil, www: nil, facebook: nil, instagram: nil, phone: nil, city: nil, cityId: nil, events: nil)
    event.organizer = Organizer(decodedOrganizer: decodedOrganizer)
    let decodedPlace = DecodedPlace(id: 0, name: "HardOn", type: .bar, address: "Seyringer Strasse, 13", latitude: 48.19611791448819, longitude: 16.357055501725107, lastUpdate: "2023-11-19 08:00:45", avatar: "https://esx.bigo.sg/eu_live/2u4/1D4hHo.jpg", mainPhoto: nil, photos: nil, tags: nil, timetable: nil, otherInfo: nil, about: nil, www: nil, facebook: nil, instagram: nil, phone: nil, city: nil, cityId: nil, events: nil)
    event.place = Place(decodedPlace: decodedPlace)
    var authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: networkManager, authNetworkManager: authNetworkManager, errorManager: errorManager)
    return EventView(viewModel: EventView.EventViewModel.init(event: event, modelContext: sharedModelContainer.mainContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, commentsNetworkManager: commentsNetworkManager, notificationsManager: notificationsManager))
        .environmentObject(authenticationManager)
}
