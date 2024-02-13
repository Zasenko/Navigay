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
    
    @Query(filter: #Predicate<Event>{ $0.isLiked == true }, sort: \Event.startDate, order: .forward, animation: .snappy)
    private var likedEvents: [Event]
    
    @State private var viewModel: AppUserViewModel
    @ObservedObject var authenticationManager: AuthenticationManager
    
    
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
                    if let user = authenticationManager.appUser, user.isUserLoggedIn {
                        userView(user: user)
                    } else {
                        authView
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
                .buttonStyle(.plain)
                .navigationBarBackButtonHidden()
                .toolbarBackground(AppColors.background)
                // .toolbarBackground(viewModel.showHeaderTitle ? .visible : .hidden, for: .navigationBar)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    if let user = authenticationManager.appUser, user.isUserLoggedIn {
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                Button {
                                    viewModel.changePassword()
                                } label: {
                                    Label(
                                        title: { Text("Change Password") },
                                        icon: { AppImages.iconLock }
                                    )
                                }
                                
                                Button {
                                    authenticationManager.appUser?.isUserLoggedIn = false
                                    likedPlaces.forEach( { $0.isLiked = false } )
                                    viewModel.logoutButtonTapped()
                                } label: {
                                    Text("Log Out")
                                }
                                
                                Button(role: .destructive) {
                                    viewModel.deleteAccountButtonTapped()
                                } label: {
                                    Label(
                                        title: { Text("Delete Account") },
                                        icon: { AppImages.iconTrash }
                                    )
                                }
                            } label: {
                                AppImages.iconSettings
                                    .bold()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    
                }

            }
        }
    }
    
    @ViewBuilder func userView(user: AppUser) -> some View {
   
        
        Section {
            HStack(spacing: 20) {
                
                PhotoEditView(canDelete: user.photo == nil ? false : true, canAddFromUrl: false) {
                    ZStack {
                        if let url = user.photo {
                            ImageLoadingView(url: url, width: 100, height: 100, contentMode: .fill) {
                                Color.red
                            }
                            .clipShape(.circle)
                            .overlay(Circle().stroke(AppColors.lightGray5, lineWidth: 1))
                            .opacity(viewModel.isLoadingPhoto ? 0.2 : 1)
                        } else {
                            AppImages.iconCamera
                                .resizable()
                                .scaledToFit()
                                .opacity(viewModel.isLoadingPhoto ? 0 : 1)
                                .tint(.primary)
                                .frame(width: 40)
                                .frame(width: 100, height: 100)
                                .background(AppColors.lightGray6)
                                .clipShape(.circle)
                        }
                        if viewModel.isLoadingPhoto {
                            ProgressView()
                                .tint(.blue)
                        }
                    }
                } onSave: { uiImage in
                    // viewModel.loadImage(uiImage: uiImage)
                } onDelete: {
                    //TODO
                }
                VStack {
                    Button {
                        viewModel.showEditNameView = true
                    } label: {
                        HStack(spacing: 10) {
                            Text(user.name)
                                .bold()
                                .font(.title2)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            AppImages.iconRight
                                .foregroundStyle(.quaternary)
                        }
                        .padding(.trailing, 20)
                        .background(AppColors.background)
                    }
                    Divider()
                }
            }
            .padding(.bottom)
            .navigationDestination(isPresented: $viewModel.showEditNameView) {
                EditTextFieldView(text: user.name, characterLimit: 30, minHaracters: 2, title: "Name", placeholder: "Name") { string in
                    
                    //после обновления в интернете
                    user.name = string
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
        
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Button {
                    viewModel.showEditBioView = true
                } label: {
                    HStack(spacing: 10) {
                        Text(user.bio ?? "Add information here...")
                            .multilineTextAlignment(.leading)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        AppImages.iconRight
                            .foregroundStyle(.quaternary)
                    }
                    .padding(.trailing, 20)
                    .background(AppColors.background)
                }
                Divider()
            }
            .navigationDestination(isPresented: $viewModel.showEditBioView) {
                EditTextEditorView(title: "About", text: user.bio ?? "", characterLimit: 1000) { string in
                    //после обновления в интернете
                    
                    user.bio = string
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
    }
//        LazyVStack(spacing: 10) {
//            if let img = userImage {
//                img
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 100, height: 100, alignment: .center)
//                    .clipShape(.circle)
//                HStack {
//                    Button{
//                    } label: {
//                        Text("Delete photo")
//                    }
//                    .buttonStyle(.bordered)
//                    Button{
//                        viewModel.userNetworkManager.setUserImage()
//                    } label: {
//                        Text("Change photo")
//                    }
//                    .buttonStyle(.bordered)
//                }
//            } else {
//                VStack {
//                    AppImages.iconPerson
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundStyle(.black.gradient)
//                        .frame(width: 50, height: 50)
//                    Text("Add photo")
//                }
//                .frame(width: 200, height: 200)
//                .background(AppColors.lightGray6.gradient)
//                .clipShape(.circle)
//                Button{
//                    viewModel.userNetworkManager.setUserImage()
//                } label: {
//                    Text("Add photo")
//                }
//                .buttonStyle(.bordered)
//            }
//            
//            
//            Divider()

//            
//        }
//        .onChange(of: user, initial: true) { _, newValue in
//            if let url = newValue.photo {
//                Task {
//                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
//                        await MainActor.run {
//                            self.userImage = image
//                        }
//                    }
//                }
//            }
//        }
    
    
    var authView: some View {
        Section {
            VStack(alignment: .center, spacing: 10) {
                AppImages.iconPerson
                    .font(.largeTitle)
                Text("Log in or register\nto unlock all the features of the app.")
                    .font(.title2)
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                
                AuthButtonsView(authenticationManager: authenticationManager) {
                    //onFinish()
                }
//                VStack(spacing: 10) {
//                    Button {
//                        viewModel.showLoginView = true
//                    } label: {
//                        Text("Log In")
//                            .font(.body)
//                            .bold()
//                            .padding(12)
//                            .padding(.horizontal)
//                            .background(AppColors.lightGray6)
//                            .clipShape(Capsule())
//                    }
//                    .fullScreenCover(isPresented: $viewModel.showLoginView) {
//                        LoginView(viewModel: LoginViewModel(), authenticationManager: authenticationManager) {
//                            self.viewModel.showLoginView = false
//                        }
//                    }
//                    
//                    Button{
//                    } label: {
//                        Text("Registration")
//                            .font(.body)
//                            .bold()
//                            .padding(12)
//                            .padding(.horizontal)
//                            .background(AppColors.lightGray6)
//                            .clipShape(Capsule())
//                    }
//                    
//                    Button{
//                    } label: {
//                        HStack(spacing: 10) {
//                            AppImages.iconGoogleG
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 20, height: 20)
//                            Text("Log In with Google")
//                                .font(.body)
//                                .bold()
//                        }
//                        .padding(12)
//                        .padding(.horizontal)
//                        .background(AppColors.lightGray6)
//                        .clipShape(Capsule())
//                        
//                    }
//                }
            }
        }
        .listRowInsets(EdgeInsets(top: 50, leading: 20, bottom: 50, trailing: 20))
        .listSectionSeparator(.hidden)
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
            .padding(.top, 50)
            .padding(.bottom, 10)
            .offset(x: 70)
            ForEach(likedPlaces.sorted(by: { $0.name < $1.name})) { place in
                NavigationLink {
                    PlaceView(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, authenticationManager: authenticationManager, showOpenInfo: false)
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
            .padding(.top, 50)
            .padding(.bottom, 10)
            .offset(x: 90)
            LazyVGrid(columns: viewModel.gridLayout, spacing: 20) {
                ForEach(likedEvents) { event in
                    EventCell(event: event, width: (width / 2) - 30, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, showCountryCity: true, authenticationManager: authenticationManager, showStartDayInfo: true, showStartTimeInfo: false)
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
