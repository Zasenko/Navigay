//
//  AppUserView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 05.10.23.
//

import SwiftUI
import SwiftData

extension AppUserView {
    
    @Observable
    class AppUserViewModel {
        
        var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
        var modelContext: ModelContext
        let eventNetworkManager: EventNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let userNetworkManager: UserNetworkManagerProtocol
        
        let errorManager: ErrorManagerProtocol
        
        init(modelContext: ModelContext, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, userNetworkManager: UserNetworkManagerProtocol) {
            self.modelContext = modelContext
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.userNetworkManager = userNetworkManager
            self.errorManager = errorManager
        }
    }
}

struct AppUserView: View {
    
    @Query(filter: #Predicate<Place>{ $0.isLiked == true }, sort: \Place.name, order: .forward, animation: .snappy)
    private var likedPlaces: [Place]
    
    @Query(filter: #Predicate<Event>{ $0.isLiked == true }, sort: \Event.startDate, order: .forward, animation: .snappy)
    private var likedEvents: [Event]
    
    @State private var viewModel: AppUserViewModel
    @ObservedObject var authenticationManager: AuthenticationManager
    
    @State private var userImage: Image? = nil
    
    init(modelContext: ModelContext,
         userNetworkManager: UserNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         authenticationManager: AuthenticationManager) {
        _viewModel = State(initialValue: AppUserViewModel(modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, userNetworkManager: userNetworkManager))
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                
                List {
                    Section {
                        if let user = authenticationManager.appUser, user.isUserLoggedIn {
                            userView(user: user)
                        } else {
                            authView
                        }
                    }
                    if !likedEvents.isEmpty {
                        eventsView(width: proxy.size.width)
                    }
                    if !likedPlaces.isEmpty {
                        placesView
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
            }
        }
    }
    
    @ViewBuilder func userView(user: AppUser) -> some View {
        LazyVStack(spacing: 10) {
            if let img = userImage {
                img
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200, alignment: .center)
                    .clipShape(.circle)
                HStack {
                    Button{
                    } label: {
                        Text("Delete photo")
                    }
                    .buttonStyle(.bordered)
                    Button{
                        viewModel.userNetworkManager.setUserImage()
                    } label: {
                        Text("Change photo")
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                VStack {
                    AppImages.iconPerson
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.black.gradient)
                        .frame(width: 50, height: 50)
                    Text("Add photo")
                }
                .frame(width: 200, height: 200)
                .background(AppColors.lightGray6.gradient)
                .clipShape(.circle)
                Button{
                    viewModel.userNetworkManager.setUserImage()
                } label: {
                    Text("Add photo")
                }
                .buttonStyle(.bordered)
            }
            
            
            Divider()
            Button{
            } label: {
                Text("Change info")
            }
            .buttonStyle(.bordered)
            Text(user.name)
                .bold()
                .font(.title)
            
            Text(user.bio ?? "bio")
                .multilineTextAlignment(.leading)
            
            
            Divider()
            Button {
                authenticationManager.appUser?.isUserLoggedIn = false
                likedPlaces.forEach( { $0.isLiked = false } )
            } label: {
                Text("Log out")
            }
            .buttonStyle(.bordered)
            Button {
                //                    authenticationManager.appUser?.isUserLoggedIn = false
                //                    likedPlaces.forEach( { $0.isLiked = false } )
            } label: {
                Text("Delete accounte")
            }
            .buttonStyle(.bordered)
            
        }
        .onChange(of: user, initial: true) { oldValue, newValue in
            if let url = user.photo {
                Task {
                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
                        await MainActor.run {
                            self.userImage = image
                        }
                    }
                }
            }
        }
    }
    
    var authView: some View {
        VStack {
            Button{
            } label: {
                Text("Log in")
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var placesView: some View {
        Section {
            HStack {
                AppImages.iconHeartFill
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.red)
                Text("Liked Places")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .font(.title)
            .padding(.top, 30)
            .padding(.bottom, 10)
            .offset(x: 70)
            ForEach(likedPlaces.sorted(by: { $0.name < $1.name})) { place in
                NavigationLink {
                    PlaceView(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager)
                } label: {
                    PlaceCell(place: place, showOpenInfo: false, showDistance: false, showCountryCity: true, showLike: false)
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder
    private func eventsView(width: CGFloat) -> some View {
        Section {
            HStack {
                AppImages.iconHeartFill
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.red)
                Text("Liked Events")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .font(.title)
            .padding(.top, 30)
            .padding(.bottom, 10)
            .offset(x: 90)
            LazyVGrid(columns: viewModel.gridLayout, spacing: 20) {
                ForEach(likedEvents) { event in
                    EventCell(event: event, width: (width / 2) - 30, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, showCountryCity: true, authenticationManager: authenticationManager)
                }
            }
            .padding(.horizontal, 20)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
    }
}

//#Preview {
//    AppUserView(authenticationManager: AuthenticationManager(keychainManager: KeychainManager(), networkManager: AuthNetworkManager(appSettingsManager: AppSettingsManager()), errorManager: ErrorManager()))
//}
