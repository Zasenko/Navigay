//
//  EditRegionView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.11.23.
//

import SwiftUI

struct EditRegionView: View {
    
    //MARK: - Private Properties
    
    @StateObject private var viewModel: EditRegionViewModel
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits

    init(viewModel: EditRegionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy  in
                VStack(spacing: 0) {
                    Divider()
                    ScrollView(showsIndicators: false) {
                        PhotoEditView(canDelete: false, canAddFromUrl: true) {
                            ZStack {
                                if let photo = viewModel.photo {
                                    if let image = photo.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: proxy.size.width, height: (proxy.size.width / 4) * 5)
                                            .clipped()
                                            .opacity(viewModel.isLoadingPhoto ? 0.2 : 1)
                                    } else if let url = photo.url {
                                        ImageLoadingView(url: url, width: proxy.size.width, height: (proxy.size.width / 4) * 5, contentMode: .fill) {
                                            Color.red
                                        }
                                        .clipped()
                                        .opacity(viewModel.isLoadingPhoto ? 0.2 : 1)
                                    }
                                } else {
                                    AppImages.iconCamera
                                        .resizable()
                                        .scaledToFit()
                                        .opacity(viewModel.isLoadingPhoto ? 0 : 1)
                                        .tint(.primary)
                                        .frame(width: 100)
                                        .frame(width: proxy.size.width, height: (proxy.size.width / 4) * 5)
                                        .background(AppColors.lightGray6)
                                }
                                if viewModel.isLoadingPhoto {
                                    ProgressView()
                                        .tint(.blue)
                                }
                            }
                        } onSave: { uiImage in
                            viewModel.loadImage(uiImage: uiImage)
                        } onDelete: {}
                        NamesEditView(nameOrigin: $viewModel.nameOrigin, nameEn: $viewModel.nameEn)
                            .padding()
                        ActivationFieldsView(isActive: $viewModel.isActive, isChecked: $viewModel.isChecked)
                            .padding(.vertical)
                    }
                }
                .navigationBarBackButtonHidden()
                .toolbarBackground(AppColors.background)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(viewModel.nameOrigin)
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
                            Button("Save") {
                                viewModel.isLoading = true
                                Task {
                                    let result = await viewModel.updateInfo()
                                    await MainActor.run {
                                        if result {
                                            self.viewModel.isLoading = false
                                            self.dismiss()
                                        } else {
                                            self.viewModel.isLoading = false
                                        }
                                    }
                                }
                            }
                            .bold()
                        }
                    }
                }
                .disabled(viewModel.isLoadingPhoto)
                .disabled(viewModel.isLoading)
            }
        }
    }
}

//#Preview {
//    let errorManager = ErrorManager()
//    let networkManager = AdminNetworkManager()
//    let region = AdminRegion(id: 0, countryId: 0, nameOrigin: nil, nameEn: nil, nameFr: nil, nameDe: nil, nameRu: nil, nameIt: nil, nameEs: nil, namePt: nil, photo: nil, isActive: false, isChecked: false)
//    return EditRegionView(viewModel: EditRegionViewModel(region: region, errorManager: errorManager, networkManager: networkManager))
//}
