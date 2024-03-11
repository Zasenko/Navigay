//
//  EventView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData
import MapKit

struct EventView: View {
    
    // MARK: - Properties
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EventViewModel
    @ObservedObject var authenticationManager: AuthenticationManager
    @Namespace private var animation
    
    @State private var downOffset = CGSize.zero
    @State private var upOffset = CGSize.zero
    
    private var formattedDate: AttributedString {
        let formattedDate: AttributedString = viewModel.event.startDate.formatted(Date.FormatStyle().month(.abbreviated).day().attributed)
        return formattedDate
    }
    private var formattedDate2: AttributedString? {
        let formattedDate: AttributedString? = viewModel.event.finishDate?.formatted(Date.FormatStyle().month(.abbreviated).day().attributed)
        return formattedDate
    }
    
    // MARK: - Init
    
    init(event: Event,
         modelContext: ModelContext,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         authenticationManager: AuthenticationManager) {
        debugPrint("init EventView, event id: ", event.id)
        let viewModel = EventViewModel(event: event, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager)
        _viewModel = State(wrappedValue: viewModel)
        self.authenticationManager = authenticationManager
        viewModel.loadEvent()
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader{ geometry in
            VStack(spacing: 0) {
                if !viewModel.showInfo {
                    coverView
                } else {
                    infoView
                }
            }
            .background {
                ZStack(alignment: .center) {
                    AppColors.background
                        .ignoresSafeArea()
                    viewModel.image?
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .scaleEffect(CGSize(width: 2, height: 2))
                        .blur(radius: 100)
                    AppColors.background
                        .opacity(viewModel.showInfo ? 0.8 : 0)
                        .ignoresSafeArea()
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                }
              //  .frame(width: geometry.size.width, height: geometry.size.height)
                .ignoresSafeArea(.container, edges: .bottom)
            }
            .mask {
                Rectangle()
                    .cornerRadius(50 , corners: [.topLeft, .topRight])
                    .ignoresSafeArea(.all)//, edges: .bottom)
            }
            .offset(x: 0, y: downOffset.height)
            .animation(.easeInOut, value: downOffset.height)
            .animation(.easeInOut, value: upOffset.height)
            .animation(.interactiveSpring, value: viewModel.showInfo)
            .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                .onChanged { value in
                    if !viewModel.showInfo {
                        if value.translation.height > 0 {
                            downOffset = value.translation
                        }
                        if value.translation.height < 0 {
                            upOffset = value.translation
                        }
                    }
                }
                .onEnded { value in
                    if !viewModel.showInfo {
                        if value.translation.height > 150 {
                            dismiss()
                        } else if value.translation.height < -30 {
                            if !viewModel.showInfo {
                                viewModel.showInfo.toggle()
                            }
                            upOffset = .zero
                            downOffset = .zero
                        } else {
                            upOffset = .zero
                            downOffset = .zero
                        }
                    }
                }
            )
        }
    }
    
    var coverView: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(viewModel.showInfo ? .ultraThickMaterial : .ultraThinMaterial)
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            if viewModel.event.isFree {
                Text("free event")
                    .font(.footnote)
                    .bold()
                    .foregroundStyle((AppColors.background))
                    .padding(5)
                    .padding(.horizontal, 5)
                    .background(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            VStack(spacing: 0) {
                Spacer()
                viewModel.image?
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 1))
                    .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 10)
                    .matchedGeometryEffect(id: "image", in: animation)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .onTapGesture {
                        viewModel.showInfo.toggle()
                    }
                Spacer()
                Text(viewModel.event.name)
                    .font(.title).bold()
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    .padding(.top)
                Spacer()
                if let finishDate = viewModel.event.finishDate {
                    if finishDate.isSameDayWithOtherDate(viewModel.event.startDate) {
                        VStack(spacing: 0) {
                            Text(viewModel.event.startDate.formatted(date: .long, time: .omitted))
                                .font(.body)
                                .bold()
                            HStack {
                                if let startTime = viewModel.event.startTime {
                                    HStack(spacing: 0) {
                                        AppImages.iconClock
                                            .font(.callout)
                                        Text(startTime.formatted(date: .omitted, time: .shortened))
                                            .font(.callout)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                                if let finishTime = viewModel.event.finishTime {
                                    Text("—")
                                        .frame(width: 20, alignment: .center)
                                    HStack(spacing: 0) {
                                        AppImages.iconClock
                                            .font(.callout)
                                        Text(finishTime.formatted(date: .omitted, time: .shortened))
                                            .font(.callout)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                    } else {
                        HStack(alignment: .top) {
                            VStack(spacing: 0) {
                                Text(viewModel.event.startDate.formatted(date: .long, time: .omitted))
                                    .font(.body)
                                    .bold()
                                if let startTime = viewModel.event.startTime {
                                    HStack(spacing: 0) {
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
                            VStack(spacing: 0) {
                                Text(finishDate.formatted(date: .long, time: .omitted))
                                    .font(.body)
                                    .bold()
                                if let finishTime = viewModel.event.finishTime {
                                    HStack(spacing: 0) {
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
                    VStack(spacing: 0) {
                        Text(viewModel.event.startDate.formatted(date: .long, time: .omitted))
                            .font(.body)
                            .bold()
                        if let startTime = viewModel.event.startTime {
                            HStack(spacing: 0) {
                                AppImages.iconClock
                                    .font(.callout)
                                Text(startTime.formatted(date: .omitted, time: .shortened))
                                    .font(.callout)
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                
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
                .padding(.top)
                Spacer()
            }
            .offset(x: 0, y: upOffset.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var infoView: some View {
        VStack(spacing: 0) {
            HStack {
                viewModel.image?
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 1))
                    .matchedGeometryEffect(id: "image", in: animation)
                    .frame(maxHeight: 80)
                    .onTapGesture {
                        viewModel.showInfo.toggle()
                    }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 6)
            .overlay {
                HStack {
                    if let user = authenticationManager.appUser, user.status == .admin {
                        Menu {
                            Button("Edit") {
                                viewModel.showEditView = true
                            }
                            Button("Clone Event") {
                                viewModel.showNewEvetnView = true
                            }
                        } label: {
                            AppImages.iconSettings
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.primary)
                               // .frame(width: 30, height: 30)
                        }
                        .fullScreenCover(isPresented: $viewModel.showEditView) {
                            viewModel.showEditView = false
                        } content: {
                            EditEventView(viewModel: EditEventViewModel(eventID: viewModel.event.id, event: viewModel.event, networkManager: AdminNetworkManager(errorManager: viewModel.errorManager)))
                        }
                        .fullScreenCover(isPresented: $viewModel.showNewEvetnView) {
                            viewModel.showNewEvetnView = false
                        } content: {
                            NewEventView(viewModel: NewEventViewModel(place: nil, copy: viewModel.event, networkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager), authenticationManager: authenticationManager)
                        }
                    }
                    Spacer()
                    VStack(spacing: 10) {
                        Button {
                            dismiss()
                        } label: {
                            AppImages.iconX
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.primary)
                        }
                        Button {
                            viewModel.event.isLiked.toggle()
                            guard let user = authenticationManager.appUser else { return }
                            if user.likedEvents.contains(where: {$0 == viewModel.event.id} ) {
                                user.likedEvents.removeAll(where: {$0 == viewModel.event.id})
                            } else {
                                user.likedEvents.append(viewModel.event.id)
                            }
                        } label: {
                            Image(systemName: viewModel.event.isLiked ? "heart.fill" : "heart")
                                .font(.title2)
                                .bold()
                                .symbolEffect(.bounce.up.byLayer, value: viewModel.event.isLiked)
                                .foregroundStyle(.red)
                        }
                    }
                    .transition(.opacity)
                }
                .padding(.horizontal)
                .frame(maxHeight: .infinity)
            }
                Divider()
                listView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

    }
    
    // MARK: - Views
    
    @State private var showFirstTime: Bool = true
    
    private var listView: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0) {
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
                    
                    map(size: geometry.size)
                        .padding(.top)
                        .padding(.top)
                    
                    
                    if (viewModel.event.owner != nil || viewModel.event.place != nil) {
                        Text(viewModel.event.owner != nil && viewModel.event.place != nil ? "Organizers:" : "Organizer:")
                            .bold()
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            if let owner = viewModel.event.owner {
                                HStack(spacing: 20) {
                                    if let url = owner.photo {
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
                                HStack(spacing: 20) {
                                    if let url = place.avatar {
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
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        //TODO: - upcoming events from organizers
                    }
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
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
        }
    }
    
    @ViewBuilder
    private func map(size: CGSize) -> some View {
            Map(position: $viewModel.position, interactionModes: []) {
                Marker("", monogram: Text("🎉"), coordinate: viewModel.event.coordinate)
                    .tint(.red)
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
            .mapControlVisibility(.hidden)
            .frame(height: size.height / 2)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 1))
            .padding()
            .onAppear {
                viewModel.position = .camera(MapCamera(centerCoordinate: viewModel.event.coordinate, distance: 2000))
            }
            
            HStack {
                Text(viewModel.event.address)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .bold()
                    .multilineTextAlignment(.leading)
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
                .foregroundStyle(.primary)
                .background(.ultraThickMaterial)
                .clipShape(Capsule(style: .continuous))
            }
            .padding(.horizontal)
            .padding(.bottom)

    }
}

//#Preview {
//    let errorManager = ErrorManager()
//    let appSettingsManager = AppSettingsManager()
//    let eventNetworkManager = EventNetworkManager(appSettingsManager: appSettingsManager, errorManager: errorManager)
//    let placeNetworkManager = PlaceNetworkManager(appSettingsManager: appSettingsManager, errorManager: errorManager)
//    let keychainManager = KeychainManager()
//    let networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
//    let authNetworkManager = AuthNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//    let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: authNetworkManager, errorManager: errorManager)
//    
//    let decodedEvent = DecodedEvent(id: 207, name: "P*rno", type: .party, startDate: "2024-03-23", startTime: "10:00:00", finishDate: "2024-03-23", finishTime: "23:23:00", address: "Ломоносова 43", latitude: 47.8086381, longitude: 13.0476341, poster: "https://i.pinimg.com/originals/dc/1e/f7/dc1ef756fb28855c5ecc23f5aa824733.jpg", smallPoster: "https://catherineasquithgallery.com/uploads/posts/2023-02/1676619417_catherineasquithgallery-com-p-zelenaya-kartinka-fon-bez-nichego-196.jpg", isFree: true, tags: [.adultsOnly, .bar, .cruise], location: nil, lastUpdate: "2024-01-19 07:07:10", about: nil, fee: nil, tickets: nil, www: nil, facebook: nil, instagram: nil, phone: nil, place: nil, owner: nil, city: nil, cityId: nil)
//
//    let event = Event(decodedEvent: decodedEvent)
//    event.image = Image("14")
//   
// //   let user = User(decodedUser: DecodedUser(id: 1, name: "Dima", bio: "NO BIO", photo: "https://ez-frag.ru/files/avatars/1622268427.jpg"))
//    let schema = Schema([
//        AppUser.self, Country.self, Region.self, City.self, Event.self, Place.self, User.self
//    ])
//    
//    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
//    do {
//        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
//        return EventView(event: event, modelContext: container.mainContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, authenticationManager: authenticationManager)
//    } catch {
//        debugPrint(error)
//        return EmptyView()
//    }
//    return EmptyView()
//}

 
