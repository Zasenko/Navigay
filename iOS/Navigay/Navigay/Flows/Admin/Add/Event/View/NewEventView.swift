//
//  NewEventView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 11.11.23.
//

import SwiftUI

struct NewEventView: View {
    
    @StateObject private var viewModel: NewEventViewModel
    private var infoTitle: String = "New event"
    private var posterTitle: String = "Event's poster"
    @Environment(\.dismiss) private var dismiss
    
    
    init(viewModel: NewEventViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Divider()
                    switch viewModel.router {
                    case .info:
                        NewEventInfoView(viewModel: viewModel)
                            .disabled(viewModel.isLoading)
                    case .poster:
                        if let id = viewModel.id {
                            EditEventCoverView(viewModel: EditEventCoverViewModel(poster: nil, eventId: id, networkManager: viewModel.networkManager, errorManager: viewModel.errorManager))
                        } else {
                            //TODO
                           EmptyView()
                        }
                    }
                }
                .navigationBarBackButtonHidden()
                .toolbarBackground(AppColors.background)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        switch viewModel.router {
                        case .info:
                            Text(infoTitle)
                                .font(.headline.bold())
                        case .poster:
                            Text(posterTitle)
                                .font(.headline.bold())
                        }
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
                        switch viewModel.router {
                        case .info:
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.blue)
                            } else {
                                Button("Add") {
                                    viewModel.addNewEvent()
                                }
                                .disabled(viewModel.name.isEmpty)
                                .disabled(viewModel.addressOrigin.isEmpty == true)
                                .disabled(viewModel.type == nil)
                                .disabled(viewModel.longitude == nil)
                                .disabled(viewModel.latitude == nil)
                                .disabled(viewModel.startDate == nil)
                            }
                        case .poster:
                            Button("Готово") {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let decodetUser = DecodedAppUser(id: 0, name: "Test", email: "test@test.com", status: .user, bio: nil, photo: nil, instagram: nil, likedPlacesId: nil)
    let user = AppUser(decodedUser: decodetUser)
    let errorManager = ErrorManager()
    let appSettingsManager = AppSettingsManager()
    let networkManager = EventNetworkManager(appSettingsManager: appSettingsManager)
    return NewEventView(viewModel: NewEventViewModel(user: user, place: nil, networkManager: networkManager, errorManager: errorManager))
}
