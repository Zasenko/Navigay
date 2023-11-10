//
//  AddNewPlaceView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI

struct AddNewPlaceView: View {
    
    //MARK: - Private Properties
    
    @StateObject private var viewModel: AddNewPlaceViewModel
    private var infoTitle: String = "New place"
    private var photoTitle: String = "Add photos"
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: AddNewPlaceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                switch viewModel.router {
                case .info:
                    NewPlaceInfoView(viewModel: viewModel)
                        .disabled(viewModel.isLoading)
                case .photos:
                    if let id = viewModel.placeId {
                        EditPlacePhotosView(viewModel: EditPlacePhotosViewModel(bigImage: nil, smallImage: nil, photos: [], placeId: id, networkManager: viewModel.networkManager, errorManager: viewModel.errorManager))
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
                    case .photos:
                        Text(photoTitle)
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
                
                if viewModel.router == .info {
                    ToolbarItem(placement: .topBarTrailing) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.blue)
                        } else {
                            Button("Add") {
                                viewModel.addNewPlace()
                            }
                            .disabled(viewModel.name.isEmpty)
                            .disabled(viewModel.addressOrigin.isEmpty == true)
                            .disabled(viewModel.type == nil)
                            .disabled(viewModel.longitude == nil)
                            .disabled(viewModel.latitude == nil)
                        }
                    }
                }
            }
            .onChange(of: viewModel.placeId) { oldValue, newValue in
                if newValue != nil {
                    viewModel.router = .photos
                }
            }
            
        }
    }
}

#Preview {
    let decodetUser = DecodedAppUser(id: 0, name: "Test", email: "test@test.com", status: .admin, bio: nil, photo: nil, instagram: nil, likedPlacesId: nil)
    let user = AppUser(decodedUser: decodetUser)
    let errorManager = ErrorManager()
    return AddNewPlaceView(viewModel: AddNewPlaceViewModel(user: user, networkManager: PlaceNetworkManager(), errorManager: errorManager))
}

