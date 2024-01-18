//
//  EditEventView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 18.01.24.
//

import SwiftUI

struct EditEventView: View {
    
    //MARK: - Private Properties
    
    @StateObject private var viewModel: EditEventViewModel
    @Environment(\.dismiss) private var dismiss
    //MARK: - Inits
    
    init(viewModel: EditEventViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy  in
                VStack(spacing: 0) {
                    Divider()
                    ScrollView(showsIndicators: false) {

                        NavigationLink {
                            EditEventAboutView(text: viewModel.about, eventId: viewModel.id, networkManager: viewModel.networkManager) { string in
                                    //TODO: обновить модель Place
                                viewModel.about = string
                            }
                        } label: {
                            EditField(title: "about", text: $viewModel.about, emptyFieldColor: .secondary)
                        }
                        
                        
//                        PhotoEditView(canDelete: false, canAddFromUrl: true) {
//                            ZStack {
//                                if let photo = viewModel.photo {
//                                    if let image = photo.image {
//                                        image
//                                            .resizable()
//                                            .scaledToFill()
//                                            .frame(width: proxy.size.width, height: (proxy.size.width / 4) * 5)
//                                            .clipped()
//                                            .opacity(viewModel.isLoadingPhoto ? 0.2 : 1)
//                                    } else if let url = photo.url {
//                                        ImageLoadingView(url: url, width: proxy.size.width, height: (proxy.size.width / 4) * 5, contentMode: .fit) {
//                                            Color.red
//                                        }
//                                        .clipped()
//                                        .opacity(viewModel.isLoadingPhoto ? 0.2 : 1)
//                                    }
//                                } else {
//                                    AppImages.iconCamera
//                                        .resizable()
//                                        .scaledToFit()
//                                        .opacity(viewModel.isLoadingPhoto ? 0 : 1)
//                                        .tint(.primary)
//                                        .frame(width: 100)
//                                        .frame(width: proxy.size.width, height: (proxy.size.width / 4) * 5)
//                                        .background(AppColors.lightGray6)
//                                }
//                                if viewModel.isLoadingPhoto {
//                                    ProgressView()
//                                        .tint(.blue)
//                                }
//                            }
//                        } onSave: { uiImage in
//                            viewModel.loadImage(uiImage: uiImage)
//                        } onDelete: {}
//                        EditLibraryView(photos: $viewModel.photos, isLoading: $viewModel.isLoadingLibraryPhoto, width: proxy.size.width) { result in
//                            viewModel.loadLibraryPhoto(photoId: result.id, uiImage: result.uiImage)
//                        } onDelete: { id in
//                            if let id {
//                                viewModel.deleteLibraryPhoto(photoId: id)
//                            }
//                        }
//                        .padding(.vertical)
//                        NamesEditView(nameOrigin: $viewModel.nameOrigin, nameEn: $viewModel.nameEn, nameFr: $viewModel.nameFr, nameDe: $viewModel.nameDe, nameRu: $viewModel.nameRu, nameIt: $viewModel.nameIt, nameEs: $viewModel.nameEs, namePt: $viewModel.namePt)
//                            .padding()
//                        AboutEditView(languages: $viewModel.languages, about: $viewModel.about)
//                            .padding()
//                        ActivationFieldsView(isActive: $viewModel.isActive, isChecked: $viewModel.isChecked)
//                            .padding(.vertical)
//                            .padding(.bottom, 50)
                    }
                }
                .navigationBarBackButtonHidden()
                .toolbarBackground(AppColors.background)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Edit place")
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
//                    ToolbarItem(placement: .topBarTrailing) {
//                        if viewModel.isLoading {
//                            ProgressView()
//                                .tint(.blue)
//                        } else {
//                            Button("Save") {
//                                viewModel.isLoading = true
//                                Task {
//                                    let result = await viewModel.updateInfo()
//                                    await MainActor.run {
//                                        if result {
//                                            self.viewModel.isLoading = false
//                                            self.dismiss()
//                                        } else {
//                                            self.viewModel.isLoading = false
//                                        }
//                                    }
//                                }
//                            }
//                            .bold()
//                        }
//                    }
                }
//                .disabled(viewModel.isLoadingPhoto)
//                .disabled(viewModel.isLoading)
//                .disabled(viewModel.isLoadingLibraryPhoto)
                .onAppear() {
                 //   viewModel.fetchPlace()
                }
            }
        }
    }
}

//#Preview {
//    EditEventView()
//}
