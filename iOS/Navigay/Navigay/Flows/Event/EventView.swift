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
    
 //   @Binding var isEventViewPresented: Bool
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EventViewModel
    @ObservedObject var authenticationManager: AuthenticationManager
    
    // MARK: - Init
    
    init(
        //isEventViewPresented: Binding<Bool>,
         event: Event,
         modelContext: ModelContext,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         authenticationManager: AuthenticationManager) {
        debugPrint("init EventView, event id: ", event.id)
        let viewModel = EventViewModel(event: event, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager)
        _viewModel = State(wrappedValue: viewModel)
       // _isEventViewPresented = isEventViewPresented
        self.authenticationManager = authenticationManager
        viewModel.loadEvent()
    }
  
    // MARK: - Body
    
    var body: some View {
        
        ZStack {
            GeometryReader { geometry in
//                let size = geometry.size
//                let width = geometry.size.width
                
                ZStack(alignment: .top) {
                    listView
                    
                    if !viewModel.showHeader {
                        Capsule()
                            .fill(.thinMaterial)
                            .frame(width: 40, height: 5)
                            .padding(.top, 20)
                    }
                    
                    if viewModel.showHeader {
                        HStack(spacing: 10) {
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
                                    EditEventView(viewModel: EditEventViewModel(event: viewModel.event, networkManager: AdminNetworkManager(errorManager: viewModel.errorManager)))
                                }
                                .fullScreenCover(isPresented: $viewModel.showNewEvetnView) {
                                    viewModel.showNewEvetnView = false
                                } content: {
                                    NewEventView(viewModel: NewEventViewModel(place: nil, copy: viewModel.event, networkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager), authenticationManager: authenticationManager)
                                }
                            }
                            
                            Button {
                                dismiss()
                                //isEventViewPresented.toggle()
                            } label: {
                                AppImages.iconX
                                    .bold()
                                    .foregroundStyle(.secondary)
                                    .padding(5)
                                    .background(.ultraThinMaterial)
                                    .clipShape(.circle)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                    }
                }
                
            }
        }
        .background {
            ZStack(alignment: .center) {
                if let image = viewModel.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .scaleEffect(CGSize(width: 1.2, height: 1.2))
                        .blur(radius: 100)
                } else {
                    if let image = viewModel.event.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            .scaleEffect(CGSize(width: 1.2, height: 1.2))
                            .blur(radius: 100)
                    }
                }
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
            }

        }
    }
    
    // MARK: - Views
    
    private var listView: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let size = geometry.size
            List {
                Color.clear
                    .frame(width: 40, height: 5)
                    .listRowBackground(Color.clear)
                ZStack() {
                    if viewModel.event.poster != nil {
                        if !viewModel.isPosterLoaded {
                            if let image = viewModel.event.image  {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 1))
                                    .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
                                    .padding()
                                    .padding(.horizontal)
                                    .frame(width: width)
                            }  else {
                                Color.red
                                    .frame(width: width, height: (width / 4) * 3)
                            }
                        } else {
                            if let image = viewModel.image  {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 1))
                                    .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
                                    .padding()
                                    .padding(.horizontal)
                                    .frame(width: width)
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
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
                    Text(viewModel.event.name)
                        .font(.title).bold()
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onAppear {
                            viewModel.showHeader = false
                        }
                        .onDisappear {
                            viewModel.showHeader = true
                        }
                }
                .padding()
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                
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
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                
                Section {
                    HStack(alignment: .lastTextBaseline) {
                        AppImages.iconLocation
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25, alignment: .leading)
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 0) {
                            if let locationName = viewModel.event.location {
                                Text(locationName)
                                    .bold()
                                    .font(.callout)
                            }
                            Text(viewModel.event.address)
                                .font(.footnote)
                        }
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                
                
                TagsView(tags: viewModel.event.tags)
                    .padding(.bottom)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                if let about = viewModel.event.about {
                    Text(about)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding()
                        .padding(.bottom, 40)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                    //    .listRowSeparator(.hidden)
                }
                
                if viewModel.event.isFree {
                    //todo
                    Text("Free event")
                        .padding()
                        .listRowBackground(Color.clear)
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
                    .listRowBackground(Color.clear)
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
                        .background(.ultraThickMaterial)
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
                            .background(.ultraThickMaterial)
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
                            .background(.ultraThickMaterial)
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
                            .background(.ultraThickMaterial)
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
                            .background(.ultraThickMaterial)
                            .clipShape(.circle)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .listRowBackground(Color.clear)
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
                    //.frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    //                .onTapGesture {
                    //                    self.place = place
                    //                }
                    
                }
                map(size: size)
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
          //  .scrollContentBackground(.hidden)
           // .background(AppColors.background)
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
                .foregroundColor(.primary)
                .background(.ultraThinMaterial)
                .clipShape(Capsule(style: .continuous))
                .buttonStyle(.borderless)
            }
            .padding(.horizontal)
            .padding(.bottom)
            
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

//#Preview {
//        let errorManager = ErrorManager()
//        let appSettingsManager = AppSettingsManager()
//        let networkManager = EventNetworkManager(appSettingsManager: appSettingsManager)
//    
//    let decodedEvent = DecodedEvent(id: <#T##Int#>, name: <#T##String#>, type: <#T##EventType#>, startDate: <#T##String#>, address: <#T##String#>, latitude: <#T##Double#>, longitude: <#T##Double#>, isFree: <#T##Bool#>, lastUpdate: <#T##String#>)
//    let event = Event(decodedEvent: decodedEvent)
//    EventView(event: Event, modelContext: <#T##ModelContext#>, placeNetworkManager: <#T##PlaceNetworkManagerProtocol#>, eventNetworkManager: <#T##EventNetworkManagerProtocol#>, errorManager: errorManager, authenticationManager: <#T##AuthenticationManager#>)
//}

 
