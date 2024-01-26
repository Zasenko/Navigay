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
                                        ImageLoadingView(url: url, width: proxy.size.width, height: (proxy.size.width / 4) * 5, contentMode: .fit) {
                                            AppColors.lightGray6
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
                        
                        NavigationLink {
                            EditTextEditorView(title: "Edit description", text: viewModel.about, characterLimit: 3000) { string in
                                viewModel.about = string
                            }
                        } label: {
                            EditField(title: "Description", text: $viewModel.about, emptyFieldColor: .secondary)
                        }
                        .padding()
                        
                        EditLibraryView(photos: $viewModel.photos, isLoading: $viewModel.isLoadingLibraryPhoto, width: proxy.size.width) { result in
                            viewModel.loadLibraryPhoto(photoId: result.id, uiImage: result.uiImage)
                        } onDelete: { id in
                            if let id {
                                viewModel.deleteLibraryPhoto(photoId: id)
                            }
                        }
                        .padding(.vertical)
                        
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
                                Task {
                                    let result = await viewModel.updateInfo()
                                    if result {
                                        await MainActor.run {
                                            dismiss()
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
                .onAppear {
                    Task {
                        let result = await viewModel.fetchCity()
                        if !result {
                            await MainActor.run {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}

//#Preview {
//    let errorManager = ErrorManager()
//    let networkManager = AdminNetworkManager()
//    let city = AdminCity(id: 0, countryId: 0, regionId: 0, nameOrigin: nil, nameEn: nil, nameFr: nil, nameDe: nil, nameRu: nil, nameIt: nil, nameEs: nil, namePt: nil, about: nil, photo: nil, photos: nil, isActive: false, isChecked: false)
//    return EditCityView(viewModel: EditCityViewModel(city: city, errorManager: errorManager, networkManager: networkManager))
//}


struct ImageLoadingView<Content: View>: View {
    
    //MARK: - Properties
    
    let loadView: () -> Content  //загрузка
    
    
    @State private var image: Image?
    let url: String
    let width: CGFloat
    let height: CGFloat
    let contentMode: ContentMode
    
    init(url: String, width: CGFloat, height: CGFloat, contentMode: ContentMode, @ViewBuilder content: @escaping () -> Content) {
        self.loadView = content
        self.url = url
        self.width = width
        self.height = height
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            if let image = image  {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                loadView()
                    .onAppear() {
                        Task(priority: .high) {
                            if let image = await ImageLoader.shared.loadImage(urlString: url) {
                                self.image = image
                            }
                        }
                    }
            }
        }
        .frame(width: width, height: height)
    }
}
