//
//  AddNewPlaceView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI

struct NewPlaceView: View {
    
    //MARK: - Private Properties
    
    @StateObject private var viewModel: AddNewPlaceViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits
    
    init(viewModel: AddNewPlaceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                listView
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New place")
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
                            guard let user = authenticationManager.appUser else { return }
                            viewModel.addNewPlace(from: user)
                        }
                        .disabled(viewModel.name.isEmpty)
                        .disabled(viewModel.addressOrigin.isEmpty == true)
                        .disabled(viewModel.type == nil)
                        .disabled(viewModel.longitude == nil)
                        .disabled(viewModel.latitude == nil)
                    }
                }
            }
            .disabled(viewModel.isLoading)
            .navigationDestination(item: $viewModel.id) { id in
                if let user = authenticationManager.appUser {
                    EditPlaceView(viewModel: EditPlaceViewModel(id: id, place: nil, user: user, networkManager: EditPlaceNetworkManager(networkMonitorManager: authenticationManager.networkMonitorManager), errorManager: viewModel.errorManager))
                }
            }
            

        }
    }
    
    private var listView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                Text("Add required information:")
                    .foregroundStyle(.secondary)
                    .padding()
                PlaceRequiredFieldsView(viewModel: viewModel)
                Text("Add additional information:")
                    .foregroundStyle(.secondary)
                    .padding()
                    .padding(.top)
                PlaceAdditionalFieldsView(isoCountryCode: $viewModel.isoCountryCode, email: $viewModel.email, phone: $viewModel.phone, www: $viewModel.www, facebook: $viewModel.facebook, instagram: $viewModel.instagram, about: $viewModel.about, timetable: $viewModel.timetable, otherInfo: $viewModel.otherInfo, tags: $viewModel.tags)
                
                if authenticationManager.appUser?.status == .admin || authenticationManager.appUser?.status == .moderator {
                    ActivationFieldsView(isActive: $viewModel.isActive, isChecked: $viewModel.isChecked)
                        .padding(.bottom, 40)
                } else {
                    EditToggleField(toggle: $viewModel.isOwned, text: "Are you an owner of this place?")
                        .padding(.bottom, 40)
                }
            }
        }
    }
    
    
    
}

//#Preview {
//    let decodetUser = DecodedAppUser(id: 0, name: "Test", email: "test@test.com", status: .admin, bio: nil, photo: nil, instagram: nil, likedPlacesId: nil)
//    let user = AppUser(decodedUser: decodetUser)
//    let errorManager = ErrorManager()
//    let appSettingsManager = AppSettingsManager()
//
//    return NewPlaceView(viewModel: AddNewPlaceViewModel(user: user, networkManager: PlaceNetworkManager(appSettingsManager: appSettingsManager), errorManager: errorManager))
//}

