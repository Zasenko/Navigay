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
    
    @State private var scrollDisabled = false
    
    private var formattedDate: AttributedString {
        let formattedDate: AttributedString = viewModel.event.startDate.formatted(Date.FormatStyle().month(.abbreviated).day().attributed)
        return formattedDate
    }
    
    private var formattedDate2: AttributedString? {
        let formattedDate: AttributedString? = viewModel.event.finishDate?.formatted(Date.FormatStyle().month(.abbreviated).day().attributed)
        return formattedDate
    }
    
    // MARK: - Init
    
    init(
        event: Event,
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
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Capsule()
                    .fill(viewModel.showHeader ? .ultraThickMaterial : .ultraThinMaterial)
                    .frame(width: 40, height: 5)
                    .padding(.bottom, viewModel.showHeader ? 0 : 20)
                    .padding(.top, 20)
                if !viewModel.showHeader {
                    viewModel.image?
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 1))
                        .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 10)
                        .matchedGeometryEffect(id: "img", in: animation)
                        .padding(.horizontal)
                        .frame(width: geometry.size.width)
                        .layoutPriority(1)
                } else {
                    HStack(alignment: .center, spacing: 10) {
                        viewModel.image?
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 1))
                            .matchedGeometryEffect(id: "img", in: animation)
                            .frame(maxHeight: 100)
                        VStack(alignment: .leading, spacing: 10) {
                            Text(viewModel.event.name)
                                .font(.headline).bold()
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 0) {
                                    //     Text(viewModel.event.startDate.formatted(date: .numeric, time: .omitted))
                                    Text(formattedDate)
                                        .font(.caption)
                                        .bold()
                                    if let startTime = viewModel.event.startTime {
                                        //                                        HStack(spacing: 4) {
                                        //                                            AppImages.iconClock
                                        //                                                .resizable()
                                        //                                                .scaledToFit()
                                        //                                                .frame(width: 12, height: 12)
                                        Text(startTime.formatted(date: .omitted, time: .shortened))
                                            .font(.caption2)
                                        //   }
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                if let formattedDate2 {
                                    Text("—")
                                        .frame(width: 10, alignment: .center)
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(formattedDate2)
                                            .font(.caption)
                                            .bold()
                                        if let finishTime = viewModel.event.finishTime {
                                            //                                            HStack(spacing: 4) {
                                            //                                                AppImages.iconClock
                                            //                                                    .resizable()
                                            //                                                    .scaledToFit()
                                            //                                                    .frame(width: 12, height: 12)
                                            Text(finishTime.formatted(date: .omitted, time: .shortened))
                                                .font(.caption2)
                                            //                       }
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        VStack(spacing: 10) {
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
                                    .resizable()
                                    .scaledToFit()
                                    .bold()
                                    .symbolEffect(.bounce.up.byLayer, value: viewModel.event.isLiked)
                                    .frame(width: 24, height: 24, alignment: .center)
                                    .foregroundStyle(.red)
                            }
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
                                        .bold()
                                        .frame(width: 30, height: 30)
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
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    Divider()
                }
                
                listView(size: geometry.size)
                    .scrollDisabled(scrollDisabled)
            }
            .animation(.interactiveSpring, value: viewModel.showHeader)
            .background {
                ZStack(alignment: .center) {
                    AppColors.background
                        .ignoresSafeArea()
                    viewModel.image?
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .scaleEffect(CGSize(width: 2, height: 2))
                        .blur(radius: 150)
                    if viewModel.showHeader {
                        AppColors.lightGray5.opacity(0.8)
                            .ignoresSafeArea()
                    }
                }
            }
            //            .onChange(of: viewModel.event.poster) { oldValue, newValue in
            //                Task {
            //                    guard let url = newValue else { return }
            //                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
            //                        await MainActor.run {
            //                            self.viewModel.image = image
            //                            self.viewModel.event.image = image
            //                        }
            //                    }
            //                }
            //            }
        }
    }
    
    // MARK: - Views
    
    private func listView(size: CGSize) -> some View {
        ScrollViewReader { scrollProxy in
            List {
                Color.clear
                    .frame(width: 1, height: 1)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .onAppear {
                        if viewModel.showHeader {
                            viewModel.showHeader = false
                        }
                    }
                    .onDisappear {
                        viewModel.showHeader = true
                    }
                Section {
                    Text(viewModel.event.name)
                        .font(.title).bold()
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal)
                        .padding(.top)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                Section {
                    VStack(spacing: 0) {
                        if viewModel.event.isFree {
                            Text("free event")
                                .font(.footnote)
                                .bold()
                                .foregroundStyle((AppColors.background))
                                .padding(5)
                                .padding(.horizontal, 5)
                                .background(.green)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(viewModel.event.startDate.formatted(date: .long, time: .omitted))
                                    .font(.callout)
                                    .bold()
                                if let startTime = viewModel.event.startTime {
                                    HStack(spacing: 10) {
                                        AppImages.iconClock
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20, alignment: .leading)
                                        Text(startTime.formatted(date: .omitted, time: .shortened))
                                            .font(.callout)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            if let finishDate = viewModel.event.finishDate {
                                Text("—")
                                    .frame(width: 10, alignment: .center)
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(finishDate.formatted(date: .long, time: .omitted))
                                        .font(.callout)
                                        .bold()
                                    if let finishTime = viewModel.event.finishTime {
                                        HStack(spacing: 10) {
                                            AppImages.iconClock
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20, alignment: .leading)
                                            Text(finishTime.formatted(date: .omitted, time: .shortened))
                                                .font(.callout)
                                        }
                                        .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .padding(.top)
                    }
                    .padding(.bottom)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                Section {
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
                    .background(viewModel.showHeader ? .ultraThickMaterial : .ultraThinMaterial)
                    .clipShape(Capsule(style: .continuous))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .id("header")
                
                if let about = viewModel.event.about {
                    Text(about)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineSpacing(9)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .padding(.vertical, 40)
                    
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listSectionSeparator(.hidden)
                }
                
                TagsView(tags: viewModel.event.tags)
                    .padding()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))

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
                            .background(viewModel.showHeader ? .ultraThickMaterial : .ultraThinMaterial)
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
                                .background(viewModel.showHeader ? .ultraThickMaterial : .ultraThinMaterial)
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
                                .background(viewModel.showHeader ? .ultraThickMaterial : .ultraThinMaterial)
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
                                        .background(viewModel.showHeader ? .ultraThickMaterial : .ultraThinMaterial)
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
                                        .background(viewModel.showHeader ? .ultraThickMaterial : .ultraThinMaterial)
                                        .clipShape(.circle)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listSectionSeparator(.hidden)
                
                Section {
                    map(size: size)
                        .padding(.top)
                        .padding(.top)
                    if (viewModel.event.owner != nil || viewModel.event.place != nil) {
                        Text(viewModel.event.owner != nil && viewModel.event.place != nil ? "Organizers:" : "Organizer:")
                            .bold()
                            .foregroundStyle(.secondary)
                        //.offset(x: 70)
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
                                //.frame(maxWidth: .infinity, alignment: .center)
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
                    
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
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
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .listSectionSeparator(.hidden)
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .onChange(of: viewModel.showHeader, initial: false) { oldValue, newValue in
                if newValue {
                    withAnimation(.interactiveSpring) {
                        scrollProxy.scrollTo("header", anchor: .top)
                    }
                    scrollDisabled = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        scrollDisabled = false
                    }
                }
            }
        }
        
    }
    
    @ViewBuilder
    private func map(size: CGSize) -> some View {
        Section {
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
                .background(viewModel.showHeader ? .ultraThickMaterial : .ultraThinMaterial)
                .clipShape(Capsule(style: .continuous))
            }
            .padding(.horizontal)
            .padding(.bottom)
            
        }
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

 
