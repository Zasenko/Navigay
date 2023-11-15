//
//  EditCityView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.11.23.
//

import SwiftUI

struct EditCityView: View {
    
    //MARK: - Private Properties
    
    @StateObject private var viewModel: EditCityViewModel
    @Environment(\.dismiss) private var dismiss
    //MARK: - Inits
    
    init(viewModel: EditCityViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy  in
                VStack(spacing: 0) {
                    Divider()
                    ScrollView(showsIndicators: false) {
                        PhotoEditView(canDelete: false) {
                            ZStack {
                                if let photo = viewModel.photo {
                                    photo
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: proxy.size.width, height: (proxy.size.width / 4) * 5)
                                        .clipped()
                                        .opacity(viewModel.isLoadingPhoto ? 0.2 : 1)
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
                        EditLibraryView(photos: $viewModel.photos, isLoading: $viewModel.isLoadingLibraryPhoto, width: proxy.size.width) { result in
                            viewModel.loadLibraryPhoto(photoId: result.id, uiImage: result.uiImage)
                        } onDelete: { id in
                            if let id {
                                viewModel.deleteLibraryPhoto(photoId: id)
                            }
                        }
                        .padding(.vertical)
                        NamesEditView(nameOrigin: $viewModel.nameOrigin, nameEn: $viewModel.nameEn, nameFr: $viewModel.nameFr, nameDe: $viewModel.nameDe, nameRu: $viewModel.nameRu, nameIt: $viewModel.nameIt, nameEs: $viewModel.nameEs, namePt: $viewModel.namePt)
                            .padding()
                        AboutEditView(languages: $viewModel.languages, about: $viewModel.about)
                            .padding()
                        ActivationFieldsView(isActive: $viewModel.isActive, isChecked: $viewModel.isChecked)
                            .padding(.vertical)
                            .padding(.bottom, 50)
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
                .disabled(viewModel.isLoadingLibraryPhoto)
            }
        }
    }
}

#Preview {
    let errorManager = ErrorManager()
    let networkManager = AdminNetworkManager()
    let city = AdminCity(id: 0, countryId: 0, regionId: 0, nameOrigin: nil, nameEn: nil, nameFr: nil, nameDe: nil, nameRu: nil, nameIt: nil, nameEs: nil, namePt: nil, about: nil, photo: nil, photos: nil, isActive: false, isChecked: false)
    return EditCityView(viewModel: EditCityViewModel(city: city, errorManager: errorManager, networkManager: networkManager))
}

struct EditLibraryView: View {
    
    //MARK: - Properties
    
    var onSave: ((id: UUID, uiImage: UIImage)) -> Void
    var onDelete: (UUID?) -> Void
    
    @Binding var photos: [Photo]
    @Binding var isLoading: Bool
    let width: CGFloat
    
    //MARK: - Private Properties

    @State private var photoId: UUID = UUID()
    @State private var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    
       //MARK: - Inits
    
    init(photos: Binding<[Photo]>, isLoading: Binding<Bool>, width: CGFloat, onSave: @escaping ((id: UUID, uiImage: UIImage)) -> Void, onDelete: @escaping (UUID?) -> Void) {
        _photos = photos
        _isLoading = isLoading
        self.width = width
        self.onSave = onSave
        self.onDelete = onDelete
    }

    //MARK: - Body
    
    var body: some View {
        VStack {
            HStack {
                Text("Other photos")
                    .font(.title3).bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if photos.count < 9 {
                    PhotoEditView(canDelete: false) {
                        Text("Add photo")
                    } onSave: { uiImage in
                        photoId = UUID()
                        onSave((id: photoId, uiImage: uiImage))
                    } onDelete: {}
                }
            }
            .padding()
            LazyVGrid(columns: gridLayout, spacing: 2) {
                ForEach(photos) { photo in
                    PhotoEditView(canDelete: true) {
                        ZStack {
                            photo.image
                                .resizable()
                                .scaledToFill()
                                .frame(width: (width - 4) / 3,
                                       height: (width - 4) / 3)
                                .clipped()
                                .opacity(isLoading && photoId == photo.id ? 0.2 : 1)
                            if isLoading && photoId == photo.id {
                                ProgressView()
                                    .tint(.blue)
                            }
                        }
                    } onSave: { uiImage in
                        onSave((id: photo.id, uiImage: uiImage))
                    } onDelete: {
                        onDelete(photo.id)
                    }
                }
            }
        }
    }
}
