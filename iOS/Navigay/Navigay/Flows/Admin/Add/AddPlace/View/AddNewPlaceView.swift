//
//  AddNewPlaceView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI

struct AddNewPlaceView: View {
    
    //MARK: - Private Properties
    
    @StateObject private var viewModel: AddNewPlaceViewModel = AddNewPlaceViewModel(networkManager: AddNetworkManager())
    private var infoTitle: String = "New place"
    private var photoTitle: String = "Add photos"
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                switch viewModel.router {
                case .info:
                    NewPlaceInfoView(viewModel: viewModel)
                case .photos:
                    EditPlacePhotosView(viewModel: EditPlacePhotosViewModel(bigImage: nil, smallImage: nil, images: [], placeId: 0))
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
    }
}

#Preview {
    AddNewPlaceView()
}

