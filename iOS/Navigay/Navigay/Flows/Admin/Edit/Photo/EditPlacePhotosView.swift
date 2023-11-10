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
                
                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .bottomLeading) {
                        bigPhoto(width: proxy.size.width)
                        smallPhoto
                    }
                    Text("Add avatar and main photo to the place.\nYou can also add 9 additional photos.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .padding(.bottom)
                    library(width: proxy.size.width)
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
                        Button("Add from camera") {
                            viewModel.libraryPhotoId = UUID()
                        }
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
                            Button("Add from camera") {
                                viewModel.libraryPhotoId = photo.id
                            }
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
        .photosPicker(isPresented: $viewModel.showLibraryPhotoPicker, selection: $viewModel.libraryPickerItem, matching: .any(of: [.images, .screenshots, .livePhotos]))
        .onChange(of: viewModel.libraryPickerItem) { oldValue, newValue in
            Task {
                guard let data = try? await newValue?.loadTransferable(type: Data.self) else { return }
                if let uiImage = UIImage(data: data) {
                    viewModel.loadLibraryPhoto(uiImage: uiImage)
                }
            }
        }
    }
        
    @ViewBuilder
    private func bigPhoto(width: CGFloat) -> some View {
        Menu {
            Button("Select from library") {
                viewModel.showMainPhotoPicker.toggle()
            }
            Button("Add from camera") {
                
            }
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
                        .frame(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.width / 4) * 5)
                        .background(AppColors.lightGray6)
                }
                if viewModel.mainPhotoLoading {
                    ProgressView()
                        .tint(.blue)
                }
            }
        }
        .disabled(viewModel.mainPhotoLoading)
        .photosPicker(isPresented: $viewModel.showMainPhotoPicker, selection: $viewModel.mainPhotoPickerItem, matching: .any(of: [.images, .screenshots, .livePhotos]))
        .onChange(of: viewModel.mainPhotoPickerItem) { oldValue, newValue in
            Task {
                guard let data = try? await viewModel.mainPhotoPickerItem?.loadTransferable(type: Data.self) else { return }
                if let uiImage = UIImage(data: data) {
                    viewModel.loadMainPhoto(uiImage: uiImage)
                }
            }
        }
    }
    
    private var smallPhoto: some View {
        Menu {
            Button("Select from library") {
                viewModel.showAvatarPhotoPicker.toggle()
            }
            Button("Add from camera") {
                
            }
            NavigationLink("Add from url") {
                AddPhotoFromUrlView { uiImage in
                    viewModel.loadAvatar(uiImage: uiImage)
                }
            }
        } label: {
            ZStack {
                Color.clear
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 100)
                    .background(AppColors.background, in: Circle())
                    .padding()
                if let smallImage =  viewModel.avatarPhoto {
                    smallImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
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
                        .frame(width: 50)
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 100)
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
        .photosPicker(isPresented: $viewModel.showAvatarPhotoPicker, selection: $viewModel.avatarPickerItem, matching: .any(of: [.images, .screenshots, .livePhotos]))
        .onChange(of: viewModel.avatarPickerItem) { oldValue, newValue in
            Task {
                guard let data = try? await viewModel.avatarPickerItem?.loadTransferable(type: Data.self) else { return }
                if let uiImage = UIImage(data: data) {
                    viewModel.loadAvatar(uiImage: uiImage)
                }
            }
        }
    }
}

#Preview {
    let errorManager = ErrorManager()
    return EditPlacePhotosView(viewModel: EditPlacePhotosViewModel(bigImage: nil, smallImage: nil, photos: [], placeId: 0, networkManager: PlaceNetworkManager(), errorManager: errorManager))
}
