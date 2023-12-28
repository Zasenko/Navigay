//
//  AddCommentView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import SwiftUI

struct AddCommentView: View {
    
    var onSave: (DecodedComment) -> Void
    
    @StateObject private var viewModel: AddCommentViewModel
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss
    
    init(text: String, characterLimit: Int, user: AppUser, placeId: Int, placeNetworkManager: PlaceNetworkManagerProtocol, onSave: @escaping (DecodedComment) -> Void) {
        _viewModel = StateObject(wrappedValue: AddCommentViewModel(user: user, placeId: placeId, placeNetworkManager: placeNetworkManager))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    Divider()
                    if !viewModel.isAdded {
                        VStack {
                            Text("Add rating to place")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top)
                            RatingView(rating: $viewModel.rating)
                            .foregroundStyle(.secondary)
                            .padding(.bottom)
                            Divider()
                            TextEditor(text: $viewModel.text)
                                .font(.body)
                                .lineSpacing(5)
                                .padding(.horizontal, 10)
                                .focused($focused)
                                .onChange(of: viewModel.text, initial: true) { oldValue, newValue in
                                    viewModel.text = String(newValue.prefix(viewModel.characterLimit))
                                }
                            Divider()
                            Text(String(viewModel.characterLimit - viewModel.text.count))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                    } else {
                        VStack {
                            Text("Add photos to your comment")
                                .font(.title3)
                                .padding()
                            
                            library(width: geometry.size.width)
                            
                            Spacer()
                        }
                    }
                }
                //.frame(height: geometry.size.width)
            }
            .disabled(viewModel.isLoading)
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New comment")
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
                if !viewModel.isAdded {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add") {
                            viewModel.addComment()
                        }
                        .bold()
                    }
                }
            }
            .onAppear {
                focused = true
            }
        }
    }
    
    @ViewBuilder
    private func library(width: CGFloat) -> some View {
        VStack {
            if viewModel.photos.count < 9 {
                Menu {
                    Button("Select from library") {
                        viewModel.libraryPhotoId = UUID()
                        viewModel.showLibraryPhotoPicker.toggle()
                    }
                    //                        Button("Add from camera") {
                    //                            viewModel.libraryPhotoId = UUID()
                    //                        }
//                    NavigationLink("Add from url") {
//                        AddPhotoFromUrlView { uiImage in
//
//                        }
//                    }
                } label: {
                    Text("Add photo")
                        .padding()
                }
            }
            
            switch viewModel.photos.count {
            case 1:
                viewModel.photos[0]
            case 2:
                HStack {
                    viewModel.photos[0]
                    viewModel.photos[1]
                }
            case 3...:
                HStack {
                    viewModel.photos[0]
                    viewModel.photos[1]
                    viewModel.photos[2]
                }
            default:
                EmptyView()
            }
            
            
//            LazyVGrid(columns: viewModel.gridLayout, spacing: 2) {
//                ForEach(viewModel.photos) { photo in
//                    Menu {
//                        Section("Change photo") {
//                            Button("Select from library") {
//                                viewModel.libraryPhotoId = photo.id
//                                viewModel.showLibraryPhotoPicker.toggle()
//                            }
////                            Button("Add from camera") {
////                                viewModel.libraryPhotoId = photo.id
////                            }
//                            NavigationLink("Add from url") {
//                                AddPhotoFromUrlView { uiImage in
//                                    viewModel.libraryPhotoId = photo.id
//                                    viewModel.loadLibraryPhoto(uiImage: uiImage)
//                                }
//                            }
//                        }
//                        Section {
//                            Button("Delete", systemImage: "trash", role: .destructive) {
//                                viewModel.libraryPhotoId = photo.id
//                                viewModel.deleteLibraryPhoto()
//                            }
//                        }
//                    } label: {
//                        ZStack {
//                            photo.image
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: (width - 4) / 3,
//                                       height: (width - 4) / 3)
//                                .clipped()
//                                .opacity(viewModel.libraryPhotoLoading && viewModel.libraryPhotoId == photo.id ? 0.2 : 1)
//                            if viewModel.libraryPhotoLoading && viewModel.libraryPhotoId == photo.id {
//                                ProgressView()
//                                    .tint(.blue)
//                            }
//                        }
//                    }
//                }
//            }
        }
       // .disabled(viewModel.libraryPhotoLoading)
        .sheet(isPresented: $viewModel.showLibraryPhotoPicker) {
            ImagePicker(selectedImage: $viewModel.libraryPickerImage)
        }
    }
}

#Preview {
    AddCommentView(text: "", characterLimit: 1000, user: AppUser(decodedUser: DecodedAppUser(id: 0, name: "Tom Finland", email: "", status: .user, bio: nil, photo: nil)), placeId: 0, placeNetworkManager: PlaceNetworkManager(appSettingsManager: AppSettingsManager(), errorManager: ErrorManager())) { comment in
        print(comment)
    }
}
