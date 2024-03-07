//
//  NewEventView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 11.11.23.
//

import SwiftUI

struct NewEventView: View {
    
    @ObservedObject private var authenticationManager: AuthenticationManager
    @StateObject private var viewModel: NewEventViewModel
    @Environment(\.dismiss) private var dismiss
    
    
    init(viewModel: NewEventViewModel, authenticationManager: AuthenticationManager) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.authenticationManager = authenticationManager
    }
    
    //MARK: - Body
    
    var body: some View {
        
        if let user = authenticationManager.appUser, user.status == .admin {
            editView
        } else {
            //TODO: - вью ошибки и переход назад
            Color.red
        }
    }
    
    var editView: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Divider()
                    
                    if !viewModel.isEventAdded {
                        NewEventInfoView(viewModel: viewModel, authenticationManager: authenticationManager)
                            .disabled(viewModel.isLoading)
                    } else {
                        //youe event Added
                        Color.green
                            .ignoresSafeArea()
                    }
                }
                .navigationDestination(isPresented: $viewModel.showAddPosterView) {
                    EditEventCoverView(viewModel: EditEventCoverViewModel(poster: nil, smallPoster: nil)) { poster, smallPoster in
                            guard let user = authenticationManager.appUser,
                              let sessionKey = user.sessionKey,
                              let ids = viewModel.ids,
                              !ids.isEmpty else {
                            return
                        }
                        Task {
                            let result = await viewModel.addPoster(to: ids, poster: poster, smallPoster: smallPoster, addedBy: user.id, sessionKey: sessionKey)
                            if result {
                                dismiss()
                            } else {
                                viewModel.showAddPosterView = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    viewModel.showAddPosterView = true
                                }
                            }
                        }
                    }
                }
                .navigationBarBackButtonHidden()
                .toolbarBackground(AppColors.background)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                            Text("New Event")
                                .font(.headline.bold())
                    }
                    
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
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.blue)
                        } else {
                            Button("Add") {
                                guard let user = authenticationManager.appUser, user.status == .admin else {
                                    return
                                }
                                viewModel.addNewEvent(user: user)
                            }
                            .bold()
                            .disabled(viewModel.name.isEmpty)
                            .disabled(viewModel.addressOrigin.isEmpty == true)
                            .disabled(viewModel.type == nil)
                            .disabled(viewModel.longitude == nil)
                            .disabled(viewModel.latitude == nil)
                            .disabled(viewModel.startDate == nil)
                        }
//                        switch viewModel.router {
//                        case .info:
//                            if viewModel.isLoading {
//                                ProgressView()
//                                    .tint(.blue)
//                            } else {
//                                Button("Add") {
//                                    guard let user = authenticationManager.appUser, user.status == .admin else {
//                                        return
//                                    }
//                                    viewModel.addNewEvent(user: user)
//                                }
//                                .bold()
//                                .disabled(viewModel.name.isEmpty)
//                                .disabled(viewModel.addressOrigin.isEmpty == true)
//                                .disabled(viewModel.type == nil)
//                                .disabled(viewModel.longitude == nil)
//                                .disabled(viewModel.latitude == nil)
//                                .disabled(viewModel.startDate == nil)
//                            }
//                        case .poster:
//                            Button("Done") {
//                                dismiss()
//                            }
//                        }
                    }
                }
                
            }
        }
    }
}

//#Preview {
//    let decodetUser = DecodedAppUser(id: 0, name: "Test", email: "test@test.com", status: .user, bio: nil, photo: nil, instagram: nil, likedPlacesId: nil)
//    let user = AppUser(decodedUser: decodetUser)
//    let errorManager = ErrorManager()
//    let appSettingsManager = AppSettingsManager()
//    let networkManager = EventNetworkManager(appSettingsManager: appSettingsManager)
//    return NewEventView(viewModel: NewEventViewModel(user: user, place: nil, networkManager: networkManager, errorManager: errorManager))
//}


struct NewEventPosterView: View {
    
    var body: some View {
        VStack {
            
        }
    }
    
}
