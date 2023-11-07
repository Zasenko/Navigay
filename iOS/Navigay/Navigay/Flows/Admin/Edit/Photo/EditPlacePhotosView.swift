//
//  EditPlacePhotosView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 31.10.23.
//

import SwiftUI

struct Photo: Identifiable {
    let id: UUID = UUID()
    let image: Image
    
    init(image: Image) {
        self.image = image
    }
}

struct EditPlacePhotosView: View {
    
    @ObservedObject var viewModel: EditPlacePhotosViewModel
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy  in
                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .bottomLeading) {
                        bigPhoto
                        smallPhoto
                    }
                    Text("Add avatar and main photo to new Place. You can also add 6 more photos to the library.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding()
                    library
//                    LazyVGrid(columns: [GridItem(spacing: 3),GridItem(spacing: 3), GridItem(spacing: 3)], spacing: 3) {
//                        ForEach(viewModel.photos) { photo in
//                            photo.image
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: (proxy.size.width / 3) - 3, (proxy.size.width / 3) - 3, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//                                .clipped()
//                        }
//                    }
                }
            }
            
        }
    }
    
    private var bigPhoto: some View {
        Menu {
            Button("Select from library") {
                viewModel.showBigPhotoPicker.toggle()
            }
            Button("Add from camera") {
                
            }
            NavigationLink("Add from url") {
                AddPhotoFromUrlView { uiImage in
                    viewModel.cropBigImage(uiImage: uiImage)
                }
            }
        } label: {
            if let bigImage =  viewModel.croppedImageBig {
                bigImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.width / 4) * 5)
                    .clipped()
            } else {
                AppImages.iconCamera
                    .resizable()
                    .scaledToFit()
                    .tint(.primary)
                    .frame(width: 100)
                    .frame(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.width / 4) * 5)
                    .background(AppColors.lightGray6)
            }
        }
        .photosPicker(isPresented: $viewModel.showBigPhotoPicker, selection: $viewModel.bigPickerItem, matching: .any(of: [.images, .screenshots, .livePhotos]))
        .onChange(of: viewModel.bigPickerItem) { oldValue, newValue in
            Task {
                guard let data = try? await viewModel.bigPickerItem?.loadTransferable(type: Data.self) else { return }
                if let uiImage = UIImage(data: data) {
                    viewModel.cropBigImage(uiImage: uiImage)
                }
            }
        }
    }
    
    private var smallPhoto: some View {
        Menu {
            Button("Select from library") {
                viewModel.showSmallPhotoPicker.toggle()
            }
            
            Button("Add from camera") {
                
            }
            NavigationLink("Add from url") {
                AddPhotoFromUrlView { uiImage in
                    viewModel.cropSmallImage(uiImage: uiImage)
                }
            }
        } label: {
            VStack {
                if let smallImage =  viewModel.croppedImageSmall {
                    smallImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 5))
                        .padding()
                } else {
                    AppImages.iconCamera
                        .resizable()
                        .scaledToFit()
                        .tint(.primary)
                        .frame(width: 50)
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 100)
                        .background(AppColors.background, in: Circle())
                        .padding()
                }
            }
        }
        .photosPicker(isPresented: $viewModel.showSmallPhotoPicker, selection: $viewModel.smallPickerItem, matching: .any(of: [.images, .screenshots, .livePhotos]))
        .onChange(of: viewModel.smallPickerItem) { oldValue, newValue in
            Task {
                guard let data = try? await viewModel.smallPickerItem?.loadTransferable(type: Data.self) else { return }
                if let uiImage = UIImage(data: data) {
                    viewModel.cropSmallImage(uiImage: uiImage)
                }
            }
        }
    }
    
    private var library: some View {
        HStack {
            Text("Photo library")
                .font(.title3).bold()
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Add photo") {
            }
        }
        .padding()
    }
}

#Preview {
    EditPlacePhotosView(viewModel: EditPlacePhotosViewModel(bigImage: nil, smallImage: nil, images: [Image("5x7"), Image("7x5"), Image("test200x200"), Image("test200x200"), Image("5x7")], placeId: 0, networkManager: PlaceNetworkManager()))
}
