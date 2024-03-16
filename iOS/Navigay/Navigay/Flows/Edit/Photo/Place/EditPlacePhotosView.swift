//
//  EditPlacePhotosView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 31.10.23.
//

import SwiftUI

struct EditPlacePhotosView: View {
    
    //MARK: - Properties
    
    @StateObject var viewModel: EditPlacePhotosViewModel
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy  in
                ScrollViewReader { scrollProxy in
                    ScrollView(showsIndicators: false) {
                        ZStack(alignment: .bottomLeading) {
                            bigPhoto(width: proxy.size.width)
                            smallPhoto
                        }
                        Text("Add avatar and main photo to the place. You can also add 9 additional photos.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .padding(.bottom)
                        library(width: proxy.size.width)
                            .id(1)
                    }
                    .onChange(of: viewModel.photos, initial: false) { oldValue, newValue in
                        scrollProxy.scrollTo(1, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    //MARK: - Views
    
    @ViewBuilder
    private func library(width: CGFloat) -> some View {
        VStack {
            HStack {
                Text("Other photos")
                    .font(.title3).bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if viewModel.photos.count < 9 {
                    Menu {
                        Button("Select from library") {
                            viewModel.libraryPhotoId = UUID()
                            viewModel.showLibraryPhotoPicker.toggle()
                        }
//                        Button("Add from camera") {
//                            viewModel.libraryPhotoId = UUID()
//                        }
                        NavigationLink("Add from url") {
                            AddPhotoFromUrlView { uiImage in
                                viewModel.libraryPhotoId = UUID()
                                viewModel.loadLibraryPhoto(uiImage: uiImage)
                            }
                        }
                    } label: {
                        Text("Add photo")
                    }
                }
            }
            .padding()
            LazyVGrid(columns: viewModel.gridLayout, spacing: 2) {
                ForEach(viewModel.photos) { photo in
                    Menu {
                        Section("Change photo") {
                            Button("Select from library") {
                                viewModel.libraryPhotoId = photo.id
                                viewModel.showLibraryPhotoPicker.toggle()
                            }
//                            Button("Add from camera") {
//                                viewModel.libraryPhotoId = photo.id
//                            }
                            NavigationLink("Add from url") {
                                AddPhotoFromUrlView { uiImage in
                                    viewModel.libraryPhotoId = photo.id
                                    viewModel.loadLibraryPhoto(uiImage: uiImage)
                                }
                            }
                        }
                        Section {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                viewModel.libraryPhotoId = photo.id
                                viewModel.deleteLibraryPhoto()
                            }
                        }
                    } label: {
                        ZStack {
                            photo.image
                                .resizable()
                                .scaledToFill()
                                .frame(width: (width - 4) / 3,
                                       height: (width - 4) / 3)
                                .clipped()
                                .opacity(viewModel.libraryPhotoLoading && viewModel.libraryPhotoId == photo.id ? 0.2 : 1)
                            if viewModel.libraryPhotoLoading && viewModel.libraryPhotoId == photo.id {
                                ProgressView()
                                    .tint(.blue)
                            }
                        }
                    }
                }
            }
        }
        .disabled(viewModel.libraryPhotoLoading)
        .sheet(isPresented: $viewModel.showLibraryPhotoPicker) {
            ImagePicker(selectedImage: $viewModel.libraryPickerImage)
        }
    }
        
    @ViewBuilder
    private func bigPhoto(width: CGFloat) -> some View {
        Menu {
            Button("Select from library") {
                viewModel.showMainPhotoPicker.toggle()
            }
//            Button("Add from camera") {
//                
//            }
            NavigationLink("Add from url") {
                AddPhotoFromUrlView { uiImage in
                    viewModel.loadMainPhoto(uiImage: uiImage)
                }
            }
        } label: {
            ZStack {
                if let bigImage =  viewModel.mainPhoto {
                    bigImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: (width / 4) * 5)
                        .clipped()
                        .opacity(viewModel.mainPhotoLoading ? 0.2 : 1)
                } else {
                    AppImages.iconCamera
                        .resizable()
                        .scaledToFit()
                        .opacity(viewModel.mainPhotoLoading ? 0 : 1)
                        .tint(.primary)
                        .frame(width: 100)
                        .frame(width: width, height: (width / 4) * 5)
                        .background(AppColors.lightGray6)
                }
                if viewModel.mainPhotoLoading {
                    ProgressView()
                        .tint(.blue)
                }
            }
        }
        .disabled(viewModel.mainPhotoLoading)
        .sheet(isPresented: $viewModel.showMainPhotoPicker) {
            ImagePicker(selectedImage: $viewModel.mainPhotoPickerImage)
        }
    }
    
    private var smallPhoto: some View {
        Menu {
            Button("Select from library") {
                viewModel.showAvatarPhotoPicker.toggle()
            }
//            Button("Add from camera") {
//                
//            }
            NavigationLink("Add from url") {
                AddPhotoFromUrlView { uiImage in
                    viewModel.loadAvatar(uiImage: uiImage)
                }
            }
        } label: {
            ZStack {
                Color.clear
                    .frame(width: 80, height: 80)
                    .background(AppColors.background, in: Circle())
                    .padding()
                if let smallImage =  viewModel.avatarPhoto {
                    smallImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .opacity(viewModel.avatarLoading ? 0.3 : 1)
                        .overlay(Circle().stroke(Color.white, lineWidth: 5))
                        .padding()
                } else {
                    AppImages.iconCamera
                        .resizable()
                        .scaledToFit()
                        .opacity(viewModel.avatarLoading ? 0 : 1)
                        .tint(.primary)
                        .frame(width: 40)
                        .frame(width: 80, height: 80)
                        .background(AppColors.background, in: Circle())
                        .padding()
                }
                if viewModel.avatarLoading {
                    ProgressView()
                        .tint(.blue)
                }
            }
        }
        .disabled(viewModel.avatarLoading)
        .sheet(isPresented: $viewModel.showAvatarPhotoPicker) {
            ImagePicker(selectedImage: $viewModel.avatarPickerImage)
        }
    }
}

//#Preview {
//    let errorManager = ErrorManager()
//    let appSettingsManager = AppSettingsManager()
//    return EditPlacePhotosView(viewModel: EditPlacePhotosViewModel(bigImage: nil, smallImage: nil, photos: [], placeId: 0, networkManager: PlaceNetworkManager(appSettingsManager: appSettingsManager, errorManager: errorManager), errorManager: errorManager))
//}
