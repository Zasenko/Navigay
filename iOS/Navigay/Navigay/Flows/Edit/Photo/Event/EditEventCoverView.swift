//
//  EditEventCoverView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import SwiftUI

struct EditEventCoverView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: NewEventViewModel
    
    // MARK: - Private Properties
    
    @State private var poster: Image?
    @State private var posterUIImage: UIImage?
    @State private var smallPosterUIImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                coverEditorView
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Poster")
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
                    Button("Save") {
                        guard let posterUIImage, let smallPosterUIImage else { return }
                        viewModel.addPoster(poster: posterUIImage, smallPoster: smallPosterUIImage)
                    }
                    .bold()
                    .disabled(posterUIImage == nil)
                    .disabled(smallPosterUIImage == nil)
                    .disabled(viewModel.isLoading)
                }
            }
            .sheet(isPresented: $viewModel.isPosterAdded) {
                dismiss()
            } content: {
                posterAddedMessageView
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(25)
            }
        }
    }
    
    // MARK: - Views
    
    private var posterAddedMessageView: some View {
        VStack {
            Capsule()
                .fill(.ultraThinMaterial)
                .frame(width: 40, height: 5)
                .padding()
            VStack {
                AppImages.iconCheckmark
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
                    .padding()
                Text("The Poster has been successfully saved. Thank you for your contribution!")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding()
                    .textSelection(.enabled)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(AppColors.lightGray3)
    }
        
    var coverEditorView: some View {
        GeometryReader { proxy  in
            VStack(alignment: .center) {
                Spacer()
                PhotoEditView(canDelete: true, canAddFromUrl: true) {
                    ZStack {
                        VStack {
                            if let poster {
                                poster
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                                    .frame(maxWidth: proxy.size.width)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .opacity(viewModel.isLoading ? 0.2 : 1)
                                
                            } else {
                                AppImages.iconCamera
                                    .resizable()
                                    .scaledToFit()
                                    .opacity(viewModel.isLoading ? 0 : 1)
                                    .tint(.primary)
                                    .frame(width: 40)
                                    .frame(width: 100, height: 100)
                                    .background(AppColors.lightGray6, in: Circle())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.blue)
                        }
                    }
                } onSave: { newImage in
                    createPoster(uiImage: newImage)
                } onDelete: {
                    deletePoster()
                }
                Spacer()
            }
            .disabled(viewModel.isLoading)
        }
    }
    
    private func createPoster(uiImage: UIImage) {
        Task {
            let scaledImage = uiImage.cropImage(maxWidth: 750, maxHeight: 750)
            let scaledSmallImage = uiImage.cropImage(maxWidth: 350, maxHeight: 350)
                await MainActor.run {
                    poster = Image(uiImage: scaledImage)
                    posterUIImage = scaledImage
                    smallPosterUIImage = scaledSmallImage
                }
        }
    }
    
    private func deletePoster() {
        poster = nil
        posterUIImage = nil
        smallPosterUIImage = nil
    }
}

//#Preview {
//    let appSettingsManager = AppSettingsManager()
//    let errorManager = ErrorManager()
//    let networkManager = EventNetworkManager(appSettingsManager: appSettingsManager, errorManager: errorManager)
//    /// Image("12")
//    /// Image("eventPinImage")
//    return EditEventCoverView(viewModel: EditEventCoverViewModel(poster: nil, smallPoster: nil), onSave: { i in })
//}
