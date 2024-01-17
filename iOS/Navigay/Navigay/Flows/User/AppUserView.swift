//
//  AppUserView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 05.10.23.
//

import SwiftUI
import SwiftData

struct AppUserView: View {
    
    @Query(filter: #Predicate<Place>{ $0.isLiked == true }, sort: \Place.name, order: .forward, animation: .snappy)
    private var likedPlaces: [Place]
    
    @ObservedObject var authenticationManager: AuthenticationManager
    private let userNetworkManager = UserNetworkManager()
    
    @State private var userImage: Image? = nil

    var body: some View {
        if let user = authenticationManager.appUser, user.isUserLoggedIn {
            userView(user: user)
        } else {
            authView
        }
    }
    
    @ViewBuilder func userView(user: AppUser) -> some View {
        ScrollView {
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
                            userNetworkManager.setUserImage()
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
                        userNetworkManager.setUserImage()
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
                
                if !likedPlaces.isEmpty {
                    Text("Liked places")
                        .bold()
                        .font(.title)
//                    ForEach(likedPlaces) { place in
//                        PlaceCell(place: place, locationManager: locationManager, showOpenInfo: false, showDistance: false)
//                    }
                }
                
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
            Spacer()
            Button{
            } label: {
                Text("Log in")
            }
            .buttonStyle(.bordered)
            Spacer()
        }
    }
}

#Preview {
    AppUserView(authenticationManager: AuthenticationManager(keychainManager: KeychainManager(), networkManager: AuthNetworkManager(appSettingsManager: AppSettingsManager()), errorManager: ErrorManager()))
}
