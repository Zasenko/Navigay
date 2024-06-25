//
//  ImageLoader.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI

enum ImageLoaderError: Error {
    case invalidUrl
    case invalidData
    case invalidCacheData
}

final class ImageLoader {
    
    //MARK: - Properties
    
    static let shared = ImageLoader()
    
    //MARK: - Private Properties
    
    private let cache: ImageCacher = .shared
    
    //MARK: - Initialization
    
    private init() {}
}

extension ImageLoader {
    
    //MARK: - Functions
    
    func loadImage(urlString: String) async -> Image? {
        do {
            if let imageData = cache.object(forKey: urlString) {
              //  debugPrint("image from cache \(urlString)")
                let image = try await makeImageFromData(data: imageData)
                return image
            }
            let data = try await fetch(stringUrl: urlString)
            cache.set(object: data, forKey: urlString)
           // debugPrint("loaded image \(urlString)")
            return try await makeImageFromData(data: data)
        } catch {
            // TODO
            debugPrint("ImageLoader error: ", error)
            return nil
        }
    }
    
    func loadData(urlString: String) async -> Data? {
        do {
            if let imageData = cache.object(forKey: urlString) {
                return imageData
            }
            let data = try await fetch(stringUrl: urlString)
            cache.set(object: data, forKey: urlString)
            return data
        } catch {
            // TODO
            debugPrint("ImageLoader error: ", error)
            return nil
        }
    }
    
    //MARK: - Private functions
    
    private func makeImageFromData(data: Data) async throws -> Image {
        guard let uiImage = UIImage(data: data) else {
            throw ImageLoaderError.invalidData
        }
        return Image(uiImage: uiImage)
    }
    
    private func fetch(stringUrl: String) async throws -> Data {
        guard let url = URL(string: stringUrl) else {
            throw ImageLoaderError.invalidUrl
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        debugPrint("fetch img stringUrl: ", stringUrl)
        return data
    }
    
    private func loadDataFromCache(for key: String) async throws -> Data {
        guard let imageData = cache.object(forKey: key) else {
            throw ImageLoaderError.invalidCacheData
        }
        return imageData
    }
}
