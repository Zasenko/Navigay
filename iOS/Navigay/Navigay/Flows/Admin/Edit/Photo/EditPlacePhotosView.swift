//
//  EditPlacePhotosView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 31.10.23.
//

import SwiftUI
import PhotosUI

struct Photo: Identifiable {
    let id: UUID = UUID()
    let image: Image
    
    init(image: Image) {
        self.image = image
    }
}

final class EditPlacePhotosViewModel: ObservableObject {
    
    
    @Published var showSmallPhotoPicker: Bool = false
    @Published var showBigPhotoPicker: Bool = false
    
    @Published var bigPickerItem: PhotosPickerItem? = nil
    @Published var smallPickerItem: PhotosPickerItem? = nil
    
    @Published var croppedImageBig: Image?
    @Published var croppedImageSmall: Image?
    @Published var photos: [Photo]
    
//        private var uiImageBig: UIImage?
//        private var uiImageSmall: UIImage?
    
    private var placeId: Int
    
    init(bigImage: Image?, smallImage: Image?, images: [Image], placeId: Int) {
        self.croppedImageBig = bigImage
        self.croppedImageSmall = smallImage
        self.photos = images.map( { Photo(image: $0) })
        self.placeId = placeId
    }
}

extension EditPlacePhotosViewModel {
    
    func cropSmallImage(uiImage: UIImage) {
        Task {
            let targetSizeSmall = CGSize(width: 100, height: 100)
            let scaledImageSmall = uiImage.scaleAndFill(targetSize: targetSizeSmall)
            await MainActor.run {
                croppedImageSmall = Image(uiImage: scaledImageSmall)
                //uiImageSmall = scaledImageSmall
                //отправить в сеть
            }
        }
    }
    
    func cropBigImage(uiImage: UIImage) {
        Task {
            let targetSizeBig = CGSize(width: 600, height: 750)
            let scaledImageBig = uiImage.scaleAndFill(targetSize: targetSizeBig)
            await MainActor.run {
                croppedImageBig = Image(uiImage: scaledImageBig)
                //uiImageBig = scaledImageBig
                //отправить в сеть
            }
        }
    }
}

struct EditPlacePhotosView: View {
    
    @ObservedObject var viewModel: EditPlacePhotosViewModel
    
    @State private var showSmallPhotoPicker: Bool = false
    @State private var showBigPhotoPicker: Bool = false
    
    @State private var bigPickerItem: PhotosPickerItem?
    @State private var smallPickerItem: PhotosPickerItem?
    
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
                showBigPhotoPicker.toggle()
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
        .photosPicker(isPresented: $showBigPhotoPicker, selection: $bigPickerItem, matching: .any(of: [.images, .screenshots, .livePhotos]))
        .onChange(of: bigPickerItem) { oldValue, newValue in
            Task {
                guard let data = try? await bigPickerItem?.loadTransferable(type: Data.self) else { return }
                if let uiImage = UIImage(data: data) {
                    viewModel.cropBigImage(uiImage: uiImage)
                }
            }
        }
    }
    
    private var smallPhoto: some View {
        Menu {
            Button("Select from library") {
                showSmallPhotoPicker.toggle()
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
        .photosPicker(isPresented: $showSmallPhotoPicker, selection: $smallPickerItem, matching: .any(of: [.images, .screenshots, .livePhotos]))
        .onChange(of: smallPickerItem) { oldValue, newValue in
            Task {
                guard let data = try? await smallPickerItem?.loadTransferable(type: Data.self) else { return }
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
    EditPlacePhotosView(viewModel: EditPlacePhotosViewModel(bigImage: nil, smallImage: nil, images: [Image("5x7"), Image("7x5"), Image("test200x200"), Image("test200x200"), Image("5x7")], placeId: 0))
}
