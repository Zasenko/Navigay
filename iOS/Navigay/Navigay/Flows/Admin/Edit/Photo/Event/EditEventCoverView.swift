//
//  EditEventCoverView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import SwiftUI

struct EditEventCoverView: View {
    
    //MARK: - Properties
    
    @StateObject var viewModel: EditEventCoverViewModel
    
    //MARK: - Body

    var body: some View {
        NavigationStack {
            GeometryReader { proxy  in
                VStack(alignment: .center) {
                    Spacer()
                    makeCoverView(width: proxy.size.width)
                        .frame(maxWidth: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Spacer()
                }
                .disabled(viewModel.isLoading)
            }
        }
    }
        
    //MARK: - Views
    
    @ViewBuilder
    private func makeCoverView(width: CGFloat) -> some View {
        Menu {
            Button("Select from library") {
                viewModel.showPosterPhotoPicker.toggle()
            }
            //            Button("Add from camera") {
            //
            //            }
            NavigationLink("Add from url") {
                AddPhotoFromUrlView { uiImage in
                    viewModel.loadPoster(uiImage: uiImage)
                }
            }
        } label: {
            ZStack {
                if let cover =  viewModel.poster {
                    cover
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: width)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .opacity(viewModel.isLoading ? 0.2 : 1)
                        .padding()
                } else {
                    AppImages.iconCamera
                        .resizable()
                        .scaledToFit()
                        .opacity(viewModel.isLoading ? 0 : 1)
                        .tint(.primary)
                        .frame(width: 40)
                        .frame(width: 100, height: 100)
                        .background(AppColors.lightGray6, in: Circle())
                        .padding()
                }
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.blue)
                }
            }
        }
        .photosPicker(isPresented: $viewModel.showPosterPhotoPicker, selection: $viewModel.posterPickerItem, matching: .any(of: [.images, .screenshots, .livePhotos]))
        .onChange(of: viewModel.posterPickerItem) { oldValue, newValue in
            Task {
                guard let data = try? await viewModel.posterPickerItem?.loadTransferable(type: Data.self) else { return }
                if let uiImage = UIImage(data: data) {
                    viewModel.loadPoster(uiImage: uiImage)
                }
            }
        }
    }
}

#Preview {
    let appSettingsManager = AppSettingsManager()
    let networkManager = EventNetworkManager(appSettingsManager: appSettingsManager)
    let errorManager = ErrorManager()
    return EditEventCoverView(viewModel: EditEventCoverViewModel(poster: nil, eventId: 1, networkManager: networkManager, errorManager: errorManager))
}