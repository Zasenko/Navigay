//
//  EditPlacePhotosViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 07.11.23.
//

import SwiftUI
import PhotosUI

final class EditPlacePhotosViewModel: ObservableObject {
    
    //MARK: - Properties
    
    @Published var showSmallPhotoPicker: Bool = false
    @Published var showBigPhotoPicker: Bool = false
    
    @Published var bigPickerItem: PhotosPickerItem? = nil
    @Published var smallPickerItem: PhotosPickerItem? = nil
    
    @Published var croppedImageBig: Image?
    @Published var croppedImageSmall: Image?
    @Published var photos: [Photo]

    //MARK: - Private Properties
    
    private let networkManager: PlaceNetworkManagerProtocol
    private var placeId: Int
    
    //MARK: - Inits
    
    init(bigImage: Image?, smallImage: Image?, images: [Image], placeId: Int, networkManager: PlaceNetworkManagerProtocol) {
        self.croppedImageBig = bigImage
        self.croppedImageSmall = smallImage
        self.photos = images.map( { Photo(image: $0) })
        self.placeId = placeId
        self.networkManager = networkManager
    }
}

extension EditPlacePhotosViewModel {
    
    func cropSmallImage(uiImage: UIImage) {
        Task {
            let targetSizeSmall = CGSize(width: 100, height: 100)
            let scaledImageSmall = uiImage.scaleAndFill(targetSize: targetSizeSmall)
            
            
            print("Original image size: \(uiImage.size)")
            print("Scaled image size: \(scaledImageSmall.size)")
            
            await MainActor.run {
                croppedImageSmall = Image(uiImage: scaledImageSmall)
                //uiImageSmall = scaledImageSmall
                //отправить в сеть
            }
            await addAvatar(uiImage: scaledImageSmall)
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
    
    private func addAvatar(uiImage: UIImage) async {
        do {
            let result = try await networkManager.updateAvatar(placeId: placeId, uiImage: uiImage)
            guard result.result,
                  let url = result.url
            else {
                if let massage = result.error?.message {
                    debugPrint("ERROR addAvatar(): ", massage)
                }
                return
            }
            print("url: ", url)
            
        } catch {
            //TODO
            print("Что-то пошло не так... Место не добавилось.")
            print(error)
        }
        
    }
}
