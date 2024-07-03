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
        do {
            let urls = try self.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])  
            return urls
        } catch {
            debugPrint("Failed to scan folder \(url): \(error.localizedDescription)")
            return []
        }
    }
    
    func checkFolder(url: URL) -> Bool {
        if self.fileExists(atPath: url.path) {
            return true
        } else {
            do {
                try self.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch {
                debugPrint("Failed to create folder: \(error.localizedDescription)")
                return false
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
            debugPrint("Failed to save image data: \(error.localizedDescription)")
        }
        return nil
    }
    
    func removeImageFromDisk(directory: URL, identifier: String) {
        let fileURL = directory.appendingPathComponent(identifier)
        if self.fileExists(atPath: fileURL.path) {
            do {
                try self.removeItem(at: fileURL)
                debugPrint("File \(fileURL.path) deleted successfully.")
            } catch {
                debugPrint("Error deleting image: \(error.localizedDescription) /", error)
            }
        } else {
            debugPrint("File does not exist at: \(fileURL.path)")
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
