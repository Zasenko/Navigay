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
    
    var onSave: ((poster: UIImage, smallPoster: UIImage)) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: EditEventCoverViewModel, onSave: @escaping ((poster: UIImage, smallPoster: UIImage)) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSave = onSave
    }
    
    //MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Divider()
                GeometryReader { proxy  in
                    VStack(alignment: .center) {
                        Spacer()
                        PhotoEditView(canDelete: true, canAddFromUrl: true) {
                            ZStack {
                                VStack {
                                    if let poster = viewModel.poster {
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
                            viewModel.createPoster(uiImage: newImage)
                        } onDelete: {
                            viewModel.deletePoster()
                        }
                        Spacer()
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Event's Poster")
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
                        guard let image = viewModel.posterUIImage,
                              let smallImage = viewModel.smallPosterUIImage
                        else { return }
                        onSave((poster: image, smallPoster: smallImage))
                    }
                    .bold()
                }
            }
        }
    }
    
    
        
    //MARK: - Views

 //   @ViewBuilder
//    private func makeCoverView(width: CGFloat) -> some View {
//        Menu {
//            Button("Select from library") {
//                viewModel.showPicker.toggle()
//            }
//            //            Button("Add from camera") {
//            //
//            //            }
//            NavigationLink("Add from url") {
//                AddPhotoFromUrlView { uiImage in
//                    viewModel.loadPosters(posters: <#T##[Int]#>, uiImage: uiImage, addedBy: <#T##Int#>, sessionKey: <#T##String#>)
//                }
//            }
//        } label: {
//            ZStack {
//                VStack {
//                    if let poster = viewModel.poster {
//                        poster
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxWidth: width)
//                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//                            .opacity(viewModel.isLoading ? 0.2 : 1)
//                            .padding()
//                    } else {
//                        AppImages.iconCamera
//                            .resizable()
//                            .scaledToFit()
//                            .opacity(viewModel.isLoading ? 0 : 1)
//                            .tint(.primary)
//                            .frame(width: 40)
//                            .frame(width: 100, height: 100)
//                            .background(AppColors.lightGray6, in: Circle())
//                            .padding()
//                    }
//                }
//                if viewModel.isLoading {
//                    ProgressView()
//                        .tint(.blue)
//                }
//            }
//        }
//    }
}

#Preview {
    let appSettingsManager = AppSettingsManager()
    let errorManager = ErrorManager()
    let networkManager = EventNetworkManager(appSettingsManager: appSettingsManager, errorManager: errorManager)
    /// Image("12")
    /// Image("eventPinImage")
    return EditEventCoverView(viewModel: EditEventCoverViewModel(poster: nil, smallPoster: nil), onSave: { i in })
}
