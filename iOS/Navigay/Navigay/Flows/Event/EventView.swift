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
    
    @Binding var isEventViewPresented: Bool
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EventViewModel
    @ObservedObject var authenticationManager: AuthenticationManager
    
    // MARK: - Init
    
    init(isEventViewPresented: Binding<Bool>, event: Event, modelContext: ModelContext, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, authenticationManager: AuthenticationManager) {
        debugPrint("init EventView, event id: ", event.id)
        let viewModel = EventViewModel(event: event, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager)
        _viewModel = State(wrappedValue: viewModel)
        _isEventViewPresented = isEventViewPresented
        self.authenticationManager = authenticationManager
        viewModel.loadEvent()
    }
  
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                listView
                    .toolbar(.hidden, for: .navigationBar)
               
                HStack {
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
                            .bold()
                            .frame(width: 30, height: 30, alignment: .leading)
                    }
                    .tint(viewModel.event.isLiked ? .red :  .secondary)
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
                                .frame(width: 30, height: 30, alignment: .leading)
                        }
                    }
                    
                    Button {
                        isEventViewPresented.toggle()
                    } label: {
                        AppImages.iconX
                            .bold()
                            .foregroundStyle(.secondary)
                            .padding(5)
                            .background(.ultraThinMaterial)
                            .clipShape(.circle)
                    }
                    .padding()
                }
                .fullScreenCover(isPresented: $viewModel.showEditView) {
                    viewModel.showEditView = false
                } content: {
                    EditEventView(viewModel: EditEventViewModel(event: viewModel.event, networkManager: AdminNetworkManager(errorManager: viewModel.errorManager)))
                }
                .fullScreenCover(isPresented: $viewModel.showNewEvetnView) {
                    viewModel.showNewEvetnView = false
                } content: {
                    NewEventView(viewModel: NewEventViewModel(place: nil, copy: viewModel.event, networkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager), authenticationManager: authenticationManager)
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var listView: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            List {
                ZStack() {
                    if viewModel.event.poster != nil {
                        if !viewModel.isPosterLoaded {
                            if let image = viewModel.event.image  {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: width)
                                    .clipped()
                            }  else {
                                Color.red
                                    .frame(width: width, height: (width / 4) * 3)
                            }
                        } else {
                            if let image = viewModel.image  {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: width)
                                    .clipped()
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .ignoresSafeArea(.all, edges: .top)
                .listRowSeparator(.hidden)
                .onAppear() {
                    
                    // TODO!!!!!!!!!!!!!!!!!
                    // убрать во вью модель
                    Task {
                        if let url = viewModel.event.poster {
                            if let image = await ImageLoader.shared.loadImage(urlString: url) {
                                await MainActor.run {
                                    viewModel.image = image
                                    viewModel.event.image = image
                                    viewModel.isPosterLoaded = true
                                }
                            }
                        }
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.event.name)
                            .font(.title2).bold()
                            .foregroundColor(.primary)
                        Text(viewModel.event.address)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
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
                            Text(viewModel.event.startDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.callout)
                        }
                        if let startTime = viewModel.event.startTime {
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
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    if let finishDate = viewModel.event.finishDate {
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
                            if let finishTime = viewModel.event.finishTime {
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
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding()
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                TagsView(tags: viewModel.event.tags)
                    .padding(.bottom)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                if let about = viewModel.event.about {
                    Text(about)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding()
                        .padding(.bottom, 40)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    //    .listRowSeparator(.hidden)
                }
                
                if viewModel.event.isFree {
                    //todo
                    Text("Free event")
                        .padding()
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                } else {
                    Section {
                        if let fee = viewModel.event.fee {
                            Text(fee)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                }
                
                VStack(spacing: 10) {
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
                        .foregroundColor(.black)
                        .background(AppColors.lightGray6)
                        .clipShape(Capsule(style: .continuous))
                        .buttonStyle(.borderless)
                    }
                    HStack {
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
                            .foregroundColor(.primary)
                            .background(AppColors.lightGray6)
                            .clipShape(Capsule(style: .continuous))
                            .buttonStyle(.borderless)
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
                            .buttonStyle(.borderless)
                            .foregroundColor(.primary)
                            .padding()
                            .background(AppColors.lightGray6)
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
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(.primary)
                            .padding()
                            .background(AppColors.lightGray6)
                            .clipShape(.circle)
                        }
                        
                        if let instagram = viewModel.event.instagram {
                            Button {
                                viewModel.goToWebSite(url: instagram)
                            } label: {
                                AppImages.iconInstagram
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25, alignment: .leading)
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(.primary)
                            .padding()
                            .background(AppColors.lightGray6)
                            .clipShape(.circle)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listSectionSeparator(.hidden)
                .listRowBackground(AppColors.background)
                
                if let place = viewModel.event.place {
                    VStack( alignment: .leading, spacing: 0) {
                        Text("Location:")
                            .bold()
                            .foregroundStyle(.secondary)
                            .offset(x: 70)
                        HStack(spacing: 20) {
                            if let url = place.avatar {
                                ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                                    Color.orange
                                }
                                .background(.regularMaterial)
                                .mask(Circle())
                            } else {
                                Text(place.type.getImage())
                                    .frame(width: 50, height: 50)
                                    .background(.regularMaterial)
                                    .mask(Circle())
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    if place.isLiked {
                                        AppImages.iconHeartFill
                                            .font(.body)
                                            .foregroundColor(.red)
                                    }
                                    Text(place.name)
                                        .multilineTextAlignment(.leading)
                                        .font(.body)
                                        .bold()
                                        .foregroundColor(.primary)
                                    
                                    
                                }
                                Text(place.type.getName())
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    //                .onTapGesture {
                    //                    self.place = place
                    //                }
                    
                }
                
                map
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
        }
    }
    
    private var map: some View {
        VStack {
            Map(position: $viewModel.position, interactionModes: []) {
                Marker("", monogram: Text("🎉"), coordinate: viewModel.event.coordinate)
                    .tint(.red)
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
            .mapControlVisibility(.hidden)
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 0))
            .onAppear {
                viewModel.position = .camera(MapCamera(centerCoordinate: viewModel.event.coordinate, distance: 500))
            }
            Text(viewModel.event.address)
                .font(.callout)
                .foregroundColor(.secondary)
                .padding()
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
//    EventView()
//}
