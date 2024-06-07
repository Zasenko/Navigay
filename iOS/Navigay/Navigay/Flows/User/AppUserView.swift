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
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Namespace private var animation

    
    init(modelContext: ModelContext,
         userNetworkManager: UserNetworkManagerProtocol,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         placeDataManager: PlaceDataManagerProtocol,
         eventDataManager: EventDataManagerProtocol,
         commentsNetworkManager: CommentsNetworkManagerProtocol) {
        let viewModel = AppUserViewModel(modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, userNetworkManager: userNetworkManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, commentsNetworkManager: commentsNetworkManager)
        _viewModel = State(initialValue: viewModel)
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
                    Color.clear
                        .frame(height: 50)
                        .listSectionSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .buttonStyle(.plain)
                .navigationBarBackButtonHidden()
                .toolbarBackground(AppColors.background)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    if let user = authenticationManager.appUser, user.isUserLoggedIn {
                        if viewModel.showTitle {
                            ToolbarItem(placement: .principal) {
                                Text(user.name)
                                    .font(.title2.bold())
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                Button {
                                    Task {
                                        let result = await authenticationManager.resetPassword(email: user.email)
                                        if result {
                                            await MainActor.run {
                                                viewModel.showResetPasswordView.toggle()
                                            }
                                        }
                                    }
                                } label: {
                                    Label(
                                        title: { Text("Change Password") },
                                        icon: { AppImages.iconLock }
                                    )
                                }
                                
                                Button {
                                    likedPlaces.forEach( { $0.isLiked = false } )
                                    likedEvents.forEach( { $0.isLiked = false } )
                                    authenticationManager.logOut(user: user)
                                } label: {
                                    Label(
                                        title: { Text("Log Out") },
                                        icon: { AppImages.iconPersonLogOut }
                                    )
                                }
                                Button(role: .destructive) {
                                    viewModel.showDeleteAccountAlert.toggle()
                                } label: {
                                    Label(
                                        title: { Text("Delete Account") },
                                        icon: { AppImages.iconTrash }
                                    )
                                }
                            } label: {
                                AppImages.iconSettings
                                    .bold()
                                    .tint(.blue)
                            }
                            .alert("Delete Account", isPresented: $viewModel.showDeleteAccountAlert) {
                                Button("Delete", role: .destructive) {
                                    Task {
                                        let result = await authenticationManager.deleteAccount(user: user)
                                        if result {
                                            await MainActor.run {
                                                likedPlaces.forEach( { $0.isLiked = false } )
                                                likedEvents.forEach( { $0.isLiked = false } )
                                                viewModel.deleteAccountButtonTapped(for: user)
                                                authenticationManager.appUser = nil
                                                
                                                //todo: show deleteAccauntSheet true
                                            }
                                        }
                                    }
                                }
                                Button("Cancel", role: .cancel) {
                                    viewModel.showDeleteAccountAlert.toggle()
                                }
                            } message: {
                                Text("Are you shure you want to delete your Account?")
                            }
                            .sheet(isPresented: $viewModel.showResetPasswordView, onDismiss: {
                                likedPlaces.forEach( { $0.isLiked = false } )
                                likedEvents.forEach( { $0.isLiked = false } )
                                user.isUserLoggedIn = false
                                authenticationManager.appUser = nil
                            }, content: {
                                ResetPasswordMessageView(email: user.email)
                                    .background(AppColors.lightGray5)
                                    .presentationDetents([.medium])
                                    .presentationDragIndicator(.hidden)
                                    .presentationCornerRadius(25)
                            })
                        }
                    }
                }
                .fullScreenCover(isPresented: $viewModel.showLoginView) {
                    LoginView(viewModel: LoginViewModel()) {
                        viewModel.showLoginView = false
                    }
                }
                .fullScreenCover(item: $viewModel.selectedEvent) { event in
                    EventView(viewModel: EventView.EventViewModel.init(event: event, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, commentsNetworkManager: viewModel.commentsNetworkManager))
                }
            }
        }
    }
    
    @ViewBuilder private func userView(user: AppUser) -> some View {
        Section {
            HStack(spacing: 20) {
                PhotoEditView(canDelete: user.photo == nil ? false : true, canAddFromUrl: false) {
                    ZStack {
                        if let image = viewModel.userImage {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(.circle)
                                .overlay(Circle().stroke(AppColors.lightGray5, lineWidth: 1))
                                .opacity(viewModel.isLoadingPhoto ? 0.2 : 1)
                        } else {
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
                        }
                        if viewModel.isLoadingPhoto {
                            ProgressView()
                                .tint(.blue)
                        }
                    }
                } onSave: { uiImage in
                    viewModel.updatePhoto(image: uiImage, for: user)
                } onDelete: {
                    viewModel.deletePhoto(for: user)
                }
                VStack(spacing: 10) {
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
                    .padding(.top, 10)
                    Divider()
                }
            }
            .padding(.bottom)
            .navigationDestination(isPresented: $viewModel.showEditNameView) {
                EditTextFieldView(text: user.name, characterLimit: 30, minHaracters: 2, title: "Name", placeholder: "Name") { string in
                    viewModel.updateUserName(name: string, for: user)
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
        .onAppear {
            if viewModel.showTitle {
                viewModel.showTitle = false
            }
        }
        .onDisappear {
            viewModel.showTitle = true
        }
        
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
                    viewModel.updateUserBio(bio: string.isEmpty ? nil : string, for: user)
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
    }

    private var authView: some View {
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
                authButtonsView
            }
        }
        .listRowInsets(EdgeInsets(top: 50, leading: 20, bottom: 50, trailing: 20))
        .listSectionSeparator(.hidden)
    }
    
    private var authButtonsView: some View {
        VStack(spacing: 10) {
            Button {
                viewModel.showLoginView = true
            } label: {
                Text("Log In")
                    .font(.body)
                    .bold()
                    .padding(12)
                    .padding(.horizontal)
                    .background(AppColors.lightGray6)
                    .clipShape(Capsule())
            }
            
            Button {
                viewModel.showRegistrationView = true
            } label: {
                Text("Registration")
                    .font(.body)
                    .bold()
                    .padding(12)
                    .padding(.horizontal)
                    .background(AppColors.lightGray6)
                    .clipShape(Capsule())
            }
            .fullScreenCover(isPresented: $viewModel.showRegistrationView) {
                RegistrationView(viewModel: RegistrationViewModel(), authenticationManager: authenticationManager, errorManager: authenticationManager.errorManager) {
                    viewModel.showRegistrationView = false
                }
            }
            
//            Button {
//            } label: {
//                HStack(spacing: 10) {
//                    AppImages.iconGoogleG
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 20, height: 20)
//                    Text("Log In with Google")
//                        .font(.body)
//                        .bold()
//                }
//                .padding(12)
//                .padding(.horizontal)
//                .background(AppColors.lightGray6)
//                .clipShape(Capsule())
//                
//            }
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
            .padding(.top, 50)
            .padding(.bottom, 10)
            .offset(x: 70)
            ForEach(likedPlaces.sorted(by: { $0.name < $1.name})) { place in
                NavigationLink {
                    PlaceView(viewModel: PlaceView.PlaceViewModel(place: place, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, commentsNetworkManager: viewModel.commentsNetworkManager, showOpenInfo: false))
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
//            LazyVGrid(columns: viewModel.gridLayout, spacing: 20) {
//                ForEach(likedEvents) { event in
//                    EventCell(event: event, showCountryCity: true, showStartDayInfo: true, showStartTimeInfo: false)//, width: (width / 2) - 30)
//                    
//                 //   EventCell(event: event, width: (width / 2) - 30, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, showCountryCity: true, authenticationManager: authenticationManager, showStartDayInfo: true, showStartTimeInfo: false)
//                }
//            }
//            .padding(.horizontal, 20)
            if likedEvents.count == 1 {
                ForEach(likedEvents) { event in
                    Button {
                        viewModel.selectedEvent = event
                    } label: {
                        EventCell(event: event, showCountryCity: true, showStartDayInfo: true, showStartTimeInfo: true, showLike: false)
                            .matchedGeometryEffect(id: "DisplayedEv\(event.id)", in: animation)
                    }
                    .frame(maxWidth: width / 2)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                }
            } else {
                StaggeredGrid(columns: 2, showsIndicators: false, spacing: 10, list: likedEvents) { event in
                    Button {
                        viewModel.selectedEvent = event
                    } label: {
                        EventCell(event: event, showCountryCity: true, showStartDayInfo: true, showStartTimeInfo: true, showLike: false)
                            .matchedGeometryEffect(id: "DisplayedEv\(event.id)", in: animation)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom)
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
    }
}
//
//#Preview {
//    AppUserView(authenticationManager: AuthenticationManager(keychainManager: KeychainManager(), networkManager: AuthNetworkManager(appSettingsManager: AppSettingsManager()), errorManager: ErrorManager()))
//}
