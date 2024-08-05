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
                    ZStack(alignment: .center) {
                        viewModel.image?
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            .scaleEffect(CGSize(width: 2, height: 2))
                            .blur(radius: 100)
                            .saturation(2)
                        AppColors.background
                            .opacity(viewModel.showInfo ? 0.8 : 0)
                            .ignoresSafeArea()
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea()
                    }
                    .ignoresSafeArea(.container, edges: .bottom)
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
                .mask {
                    Rectangle()
                        .ignoresSafeArea(.all)
                }
                .animation(.snappy, value: viewModel.showInfo)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    headerView
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var headerView: some View {
        HStack {
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
    
   // @State private var img: Image? = nil
    
    private func listView(size: CGSize) -> some View {
        List {
            Section {
                VStack {
//                    img
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
                    .padding(.bottom)
                    .padding(.bottom)
                    .padding(.bottom)
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
                
                HStack(spacing: 10) {
                    Button {
                        // douplicate button - to do function
                        viewModel.likeButtonTapped()
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
                            .frame(width: 25, height: 25, alignment: .leading)
                            .foregroundStyle(.red)
                            .symbolEffect(.bounce.up.byLayer, value: viewModel.event.isLiked)
                            .padding()
                            .background(viewModel.showInfo ? .ultraThickMaterial : .ultraThinMaterial)
                            .clipShape(.circle)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
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
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .listSectionSeparator(.hidden)
        .scrollIndicators(.hidden)
        
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

 
