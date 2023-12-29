//
//  AddCommentView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import SwiftUI

struct AddCommentView: View {
    
    // MARK: - Private Properties
    
    @ObservedObject private var authenticationManager: AuthenticationManager
    @StateObject private var viewModel: AddCommentViewModel
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Inits
    
    init(text: String, characterLimit: Int, placeId: Int, placeNetworkManager: PlaceNetworkManagerProtocol, authenticationManager: AuthenticationManager) {
        _viewModel = StateObject(wrappedValue: AddCommentViewModel(placeId: placeId, placeNetworkManager: placeNetworkManager))
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    if !viewModel.isAdded {
                        Divider()
                        Text("Rate the place")
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
                            .frame(maxHeight: .infinity)
                            .onAppear {
                                focused = true
                            }
                        Divider()
                        Text(String(viewModel.characterLimit - viewModel.text.count))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal)
                        library(width: geometry.size.width)
                            .padding(.horizontal)
                            .padding(.bottom)
                    } else {
                        Text("Your review has been added and is being verified.\n\n Thank you!")
                            .multilineTextAlignment(.center)
                            .font(.title)
                            .padding()
                            .frame(maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .disabled(viewModel.isLoading)
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
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
                    ToolbarItem(placement: .principal) {
                        Text("New review")
                            .font(.headline.bold())
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add") {
                            guard let user = authenticationManager.appUser else {
                                return
                            }
                            viewModel.addComment(user: user)
                        }
                        .bold()
                        .disabled(viewModel.text.isEmpty)
                    }
                }
            }
            .onChange(of: viewModel.isAdded) { _, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private func library(width: CGFloat) -> some View {
        HStack {
            ForEach(viewModel.photos) { photo in
                Menu {
                    Button {
                        viewModel.deletePhoto(photoId: photo.id)
                    } label: {
                        Text("Delete")
                    }
                } label: {
                    photo.image?
                        .resizable()
                        .scaledToFill()
                        .frame(width: width / 4,
                               height: width / 4)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColors.lightGray5, lineWidth: 1))
                }
            }
            if viewModel.photos.count < 3 {
                PhotoEditView(canDelete: false, canAddFromUrl: false) {
                    VStack {
                        AppImages.iconPhotoPlus
                            .font(.title3)
                        Text("Add photo")
                            .font(.callout)
                    }
                    .frame(width: width / 4,
                           height: width / 4)
                    .background(AppColors.lightGray6)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                } onSave: { uiImage in
                    focused = false
                    viewModel.addPhoto(photoId: UUID().uuidString, uiImage: uiImage)
                } onDelete: {}
            }
        }
        .frame(maxWidth: .infinity)
    }
}

//#Preview {
//    AddCommentView(text: "", characterLimit: 1000, placeId: 0, placeNetworkManager: PlaceNetworkManager(appSettingsManager: AppSettingsManager(), errorManager: ErrorManager()), authenticationManager: AuthenticationManager) { comment in
//        print(comment)
//    }
//}
