//
//  FileManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 24.06.24.
//

import Foundation
import UIKit

extension FileManager {
    
    func scanDirectory(url: URL) -> [URL] {
        let urls = (try? self.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])) ?? []
        return urls
    }
    
    func checkFolder(url: URL) {
        if !self.fileExists(atPath: url.path) {
            do {
                try self.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create folder: \(error.localizedDescription)")
            }
        }
    }
    
    func saveImage(data: Data, directory: URL, identifier: String) -> URL? {
        let fileURL = directory.appendingPathComponent(identifier)
        do {
            try data.write(to: fileURL)
            if let imageData = UIImage(data: data)?.jpegData(compressionQuality: 1.0) {
                let fileName = identifier + ".jpg"
                let imageFileURL = directory.appendingPathComponent(fileName)
                try imageData.write(to: imageFileURL)
                return imageFileURL
            }
        } catch {
            print("Failed to save image data: \(error.localizedDescription)")
        }
        return nil
    }
    
    func removeImageFromDisk(directory: URL, identifier: String) {
        
        let fileURL = directory.appendingPathComponent(identifier)
        
        if self.fileExists(atPath: fileURL.path) {
            do {
                try self.removeItem(at: fileURL)
                print("File \(fileURL.path) deleted successfully.")
            } catch {
                print("Error deleting image: \(error.localizedDescription) /", error)
            }
        } else {
            print("File does not exist at: \(fileURL.path)")
        }
    }
    
//    func loadDataFromDisk(url: URL) -> Data? {
//        if self.fileExists(atPath: url.path) {
//            do {
//                let data = try Data(contentsOf: url)
//                return data
//            } catch {
//                print("Failed to load data from disk: \(error.localizedDescription)")
//            }
//        } else {
//            print("File does not exist at: \(url.path)")
//        }
//        return nil
//    }
}
