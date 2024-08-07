//
//  EventView2.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 07.08.24.
//

import SwiftUI
import SwiftData
import MapKit

struct EventView2: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var authenticationManager: AuthenticationManager

    // MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EventViewModel

    // MARK: - Init
    
    init(viewModel: EventViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack {
                    listView(size: proxy.size)
                    ErrorView(viewModel: ErrorViewModel(errorManager: viewModel.errorManager), moveFrom: .bottom, alignment: .bottom)
                }
                .background {
                    if viewModel.showInfo {
                        AppColors.background
                    } else {
                        ZStack(alignment: .center) {
                            viewModel.image?
                                .resizable()
                                .scaledToFill()
                                .ignoresSafeArea()
                                .scaleEffect(CGSize(width: 2, height: 2))
                                .blur(radius: 100)
                                .saturation(2)
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .ignoresSafeArea()
                        }
                        .ignoresSafeArea(.container, edges: .bottom)
                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    }
                }
                .mask {
                    Rectangle()
                        .ignoresSafeArea(.all)
                }
                .animation(.snappy, value: viewModel.showInfo)
            }
            .toolbarBackground(viewModel.showTitle ? .visible :.hidden, for: .navigationBar)
            .toolbarBackground(AppColors.background)
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
                if viewModel.showTitle {
                    ToolbarItem(placement: .principal) {
                        Text(viewModel.event.name)
                            .font(.headline).bold()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
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
//                        Button {
//                            viewModel.likeButtonTapped()
//                            guard let user = authenticationManager.appUser else { return }
//                            if user.likedEvents.contains(where: {$0 == viewModel.event.id} ) {
//                                user.likedEvents.removeAll(where: {$0 == viewModel.event.id})
//                            } else {
//                                user.likedEvents.append(viewModel.event.id)
//                            }
//                        } label: {
//                            Image(systemName: viewModel.event.isLiked ? "heart.fill" : "heart")
//                                .bold()
//                                .frame(width: 30, height: 30, alignment: .leading)
//                        }
//                        .tint(viewModel.place.isLiked ? .red :  .secondary)
                    
                }
            }
        }
    }
    
    // MARK: - Views
        
    private func listView(size: CGSize) -> some View {
        List {
            Section {
                VStack {
                    if viewModel.event.isFree {
                        Text("free event")
                            .font(.footnote)
                            .bold()
                            .foregroundStyle(AppColors.background)
                            .padding(5)
                            .padding(.horizontal, 5)
                            .background(.green)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.bottom)
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .onAppear {
                    viewModel.showInfo = false
                }
                .onDisappear {
                    viewModel.showInfo = true
                }
                viewModel.image?
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 1))
                    .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                    .onAppear {
                        viewModel.showTitle = false
                    }
                    .onDisappear {
                        viewModel.showTitle = true
                    }

                Text(viewModel.event.name)
                    .font(.title).bold()
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                VStack(spacing: 5) {
                    if let finishDate = viewModel.event.finishDate {
                        if finishDate.isSameDayWithOtherDate(viewModel.event.startDate) {
                            Text(viewModel.event.startDate.formatted(date: .long, time: .omitted))
                                .font(.title3)
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
                                        .font(.title3)
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
                                        .font(.title3)
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
                            .font(.title3)
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
                .frame(maxWidth: .infinity)
                .padding()
             //   HStack(spacing: 20) {
                    Button {
                        viewModel.goToMaps()
                    } label: {
                        HStack(spacing: 10) {
                            AppImages.iconLocation
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.blue)
                                .frame(width: 25, height: 25, alignment: .leading)
                            VStack(alignment: .leading, spacing: 0) {
                                if let locationName = viewModel.event.location {
                                    Text(locationName)
                                        .bold()
                                        .font(.callout)
                                }
                                Text(viewModel.event.address)
                                    .font(.footnote)
                            }
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                        }
                    }
                    .padding()
                    .background(viewModel.showInfo ? .ultraThickMaterial : .ultraThinMaterial)
                    .clipShape(Capsule(style: .continuous))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
                    .padding(.bottom)
                    
                    
//                    Button {
//                        // douplicate button - to do function
//                        viewModel.likeButtonTapped()
//                        guard let user = authenticationManager.appUser else { return }
//                        if user.likedEvents.contains(where: {$0 == viewModel.event.id} ) {
//                            user.likedEvents.removeAll(where: {$0 == viewModel.event.id})
//                        } else {
//                            user.likedEvents.append(viewModel.event.id)
//                        }
//                    } label: {
//                        Image(systemName: viewModel.event.isLiked ? "heart.fill" : "heart")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 25, height: 25, alignment: .leading)
//                            .foregroundStyle(.red)
//                            .symbolEffect(.bounce.up.byLayer, value: viewModel.event.isLiked)
//                            .padding()
//                            .background(viewModel.showInfo ? .ultraThickMaterial : .ultraThinMaterial)
//                            .clipShape(.circle)
//                    }
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.horizontal)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            Section {
                if let about = viewModel.event.about {
                    Text(about)
                        .font(.callout)
                        .foregroundStyle(.primary)
                        .lineSpacing(9)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .padding(.vertical, 40)
                }
                if !viewModel.event.tags.isEmpty {
                    TagsView(tags: viewModel.event.tags)
                        .padding()
                }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            Section {
                VStack {
                    if let phone = viewModel.event.phone {
                        Button {
                            viewModel.call(phone: phone)
                        } label: {
                            HStack {
                                AppImages.iconPhoneFill
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25, alignment: .leading)
                                Text(phone)
                                    .font(.title2)
                                    .bold()
                            }
                        }
                        .padding()
                        .foregroundStyle(.primary)
                        .background(viewModel.showInfo ? .ultraThickMaterial : .ultraThinMaterial)
                        .clipShape(Capsule(style: .continuous))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                    }
                    
                    HStack(spacing: 10) {
                        if let tickets = viewModel.event.tickets {
                            Button {
                                viewModel.goToWebSite(url: tickets)
                            } label: {
                                HStack {
                                    AppImages.iconWallet
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25, alignment: .leading)
                                    Text("Tickets")
                                        .font(.caption)
                                        .bold()
                                }
                            }
                            .padding()
                            .foregroundStyle(.primary)
                            .background(viewModel.showInfo ? .ultraThickMaterial : .ultraThinMaterial)
                            .clipShape(Capsule(style: .continuous))
                        }
                        
                        if let www = viewModel.event.www {
                            Button {
                                viewModel.goToWebSite(url: www)
                            } label: {
                                HStack {
                                    AppImages.iconGlobe
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25, alignment: .leading)
                                    Text("Web")
                                        .font(.caption)
                                        .bold()
                                }
                            }
                            .padding()
                            .foregroundStyle(.primary)
                            .background(viewModel.showInfo ? .ultraThickMaterial : .ultraThinMaterial)
                            .clipShape(Capsule(style: .continuous))
                        }
                        
                        
                        if let facebook = viewModel.event.facebook {
                            Button {
                                viewModel.goToWebSite(url: facebook)
                            } label: {
                                AppImages.iconFacebook
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25, alignment: .leading)
                                    .foregroundStyle(.primary)
                                    .padding()
                                    .background(viewModel.showInfo ? .ultraThickMaterial : .ultraThinMaterial)
                                    .clipShape(.circle)
                            }
                        }
                        
                        if let instagram = viewModel.event.instagram {
                            Button {
                                viewModel.goToWebSite(url: instagram)
                            } label: {
                                AppImages.iconInstagram
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25, alignment: .leading)
                                    .foregroundStyle(.primary)
                                    .padding()
                                    .background(viewModel.showInfo ? .ultraThickMaterial : .ultraThinMaterial)
                                    .clipShape(.circle)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom)
                    
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                map(size: size)
                    .padding(.top)
                    .padding(.top)
                
                if (viewModel.event.owner != nil || viewModel.event.place != nil) {
                    Text(viewModel.event.owner != nil && viewModel.event.place != nil ? "Organizers" : "Organizer")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        if let owner = viewModel.event.owner {
                            HStack(spacing: 20) {
                                if let url = owner.photoUrl {
                                    ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                                        AppColors.lightGray6
                                    }
                                    .background(.regularMaterial)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(.ultraThinMaterial, lineWidth: 1))
                                } else {
                                    if viewModel.event.place != nil {
                                        Color.clear
                                            .frame(width: 50, height: 50)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(owner.name)
                                        .multilineTextAlignment(.leading)
                                        .font(.body)
                                        .bold()
                                        .foregroundStyle(.primary)
                                    if let bio = owner.bio {
                                        Text(bio)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                            }
                        }
                        if let place = viewModel.event.place {
                            NavigationLink {
                                PlaceView(viewModel: PlaceView.PlaceViewModel(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, commentsNetworkManager: viewModel.commentsNetworkManager, notificationsManager: viewModel.notificationsManager, showOpenInfo: false))
                            } label: {
                                HStack(spacing: 20) {
                                    if let url = place.avatarUrl {
                                        ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                                            AppColors.lightGray6
                                        }
                                        .background(.regularMaterial)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(.ultraThinMaterial, lineWidth: 1))
                                    } else {
                                        if viewModel.event.owner != nil {
                                            Color.clear
                                                .frame(width: 50, height: 50)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 10) {
                                            Text(place.name)
                                                .multilineTextAlignment(.leading)
                                                .font(.body)
                                                .bold()
                                                .foregroundColor(.primary)
                                            AppImages.iconHeartFill
                                                .font(.body)
                                                .foregroundColor(.red)
                                        }
                                        Text(place.type.getName())
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
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
                
                Color.clear
                    .frame(height: 50)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .listSectionSeparator(.hidden)
        .scrollIndicators(.hidden)
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
    
    @ViewBuilder
    private func map(size: CGSize) -> some View {
        VStack {
            Text("Location")
                .font(.title2)
                .bold()
                .foregroundStyle(.primary)
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
}

 
extension EventView2 {
    
    @Observable
    final class EventViewModel {
        
        // MARK: - Properties
        
        var modelContext: ModelContext
        let event: Event
        var image: Image?
        var showInfo: Bool = false
        var showTitle: Bool = false
        var position: MapCameraPosition = .automatic
        var selectedTag: UUID? = nil /// for Map (big Pin)
        let placeNetworkManager: PlaceNetworkManagerProtocol //?????????
        let eventNetworkManager: EventNetworkManagerProtocol
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let errorManager: ErrorManagerProtocol
        let commentsNetworkManager: CommentsNetworkManagerProtocol
        
        let notificationsManager: NotificationsManagerProtocol
        
        //MARK: - Inits
        
        init(event: Event, modelContext: ModelContext, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, placeDataManager: PlaceDataManagerProtocol, eventDataManager: EventDataManagerProtocol, commentsNetworkManager: CommentsNetworkManagerProtocol, notificationsManager: NotificationsManagerProtocol) {
            self.event = event
            self.modelContext = modelContext
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
            self.commentsNetworkManager = commentsNetworkManager
            self.notificationsManager = notificationsManager
            self.selectedTag = event.tag
            centerMapPin()
            loadEvent()
        }
        
        //MARK: - Functions
        
        func centerMapPin() {
            position = .camera(MapCamera(centerCoordinate: event.coordinate, distance: 1500))
        }
        
        func likeButtonTapped() {
            event.isLiked.toggle()
            if event.isLiked {
                notificationsManager.addEventNotification(event: event)
            } else {
                notificationsManager.removeEventNotification(event: event)
            }
        }
        
        func loadEvent() {
            debugPrint("loadEvent()")
            loadPoster()
            Task {
                guard !eventNetworkManager.loadedEvents.contains(where: { $0 == event.id}) else {
                    return
                }
                do {
                    let decodedEvent = try await eventNetworkManager.fetchEvent(id: event.id)
                    await MainActor.run {
                        updateEvent(decodedEvent: decodedEvent)
                    }
                } catch NetworkErrors.noConnection {
                } catch NetworkErrors.apiError(let apiError) {
                    errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
                } catch {
                    errorManager.showError(model: ErrorModel(error: error, message: errorManager.updateMessage))
                }
            }
        }
        
        func call(phone: String) {
            let api = "tel://"
            let stringUrl = api + phone
            guard let url = URL(string: stringUrl) else { return }
            UIApplication.shared.open(url)
        }
        
        func goToWebSite(url: String) {
            guard let url = URL(string: url) else { return }
            UIApplication.shared.open(url)
        }
        
        func goToMaps() {
            let coordinate = event.coordinate
            let stringUrl = "maps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)"
            guard let url = URL(string: stringUrl) else { return }
            UIApplication.shared.open(url)
        }
        
        //MARK: - Private Functions
        
        private func loadPoster() {
            if let img = event.posterImg {
                self.image = img
            } else {
                self.image = event.smallPosterImg
                Task(priority: .high) {
                    if let url = event.poster {
                        if let image = await ImageLoader.shared.loadImage(urlString: url) {
                            await MainActor.run {
                                self.image = image
                                event.posterImg = image
                            }
                        }
                    }
                }
            }
        }

        private func updateEvent(decodedEvent: DecodedEvent) {
            event.updateEventComplete(decodedEvent: decodedEvent)
            Task(priority: .high) {
                if let url = event.poster {
                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
                        await MainActor.run {
                            self.image = image
                            event.posterImg = image
                        }
                    }
                }
            }
            if let decodedPlace = decodedEvent.place {
                updatePlace(decodedPlace: decodedPlace)
            }
            if let owner = decodedEvent.owner {
                updateOwner(decodedUser: owner)
            }
        }
        private func updatePlace(decodedPlace: DecodedPlace) {
                do {
                    let descriptor = FetchDescriptor<Place>()
                    let allPlaces = try modelContext.fetch(descriptor)
                    var eventPlace: Place?
                    if let place = allPlaces.first(where: { $0.id == decodedPlace.id} ) {
                        place.updatePlaceIncomplete(decodedPlace: decodedPlace)
                        updateTimeTable(timetable: decodedPlace.timetable, for: place)
                        eventPlace = place
                    } else {
                        let place = Place(decodedPlace: decodedPlace)
                        updateTimeTable(timetable: decodedPlace.timetable, for: place)
                        eventPlace = place
                    }
                    event.place = eventPlace
                } catch {
                    debugPrint("ERROR - EventViewModel updatePlace id \(decodedPlace.id): ", error)
                }
        }
        
        private func updateOwner(decodedUser: DecodedUser) {
            do {
                let descriptor = FetchDescriptor<User>()
                let allUsers = try modelContext.fetch(descriptor)
                var eventOwner: User?
                if let owner = allUsers.first(where: { $0.id == decodedUser.id} ) {
                    owner.updateUser(decodedUser: decodedUser)
                    eventOwner = owner
                } else {
                    let owner = User(decodedUser: decodedUser)
                    eventOwner = owner
                }
                event.owner = eventOwner
            } catch {
                debugPrint("ERROR - EventViewModel updateOwner id \(decodedUser.id): ", error)
            }
        }
        
        //TODO double есть в PlaceDataManager
        private func updateTimeTable(timetable: [PlaceWorkDay]?, for place: Place) {
            let oldTimetable = place.timetable
            place.timetable.removeAll()
            oldTimetable.forEach( { modelContext.delete($0) })
            if let timetable {
                for day in timetable {
                    let workingDay = WorkDay(workDay: day)
                    place.timetable.append(workingDay)
                }
            }
        }
    }
}
