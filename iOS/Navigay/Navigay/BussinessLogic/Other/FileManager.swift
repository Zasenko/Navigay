//
//  FileManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 24.06.24.
//

import Foundation
import UIKit


extension FileManager {
    
    static var documentDirectoryURL: URL {
        let documentDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documentDirectoryURL
    }
    
    func scanTheDirectory(_ folder: URL) {
        print("----------scanTheDirectory--------")
            let enm = FileManager.default.enumerator(at: folder, includingPropertiesForKeys: nil)
            for url in enm! {
                print(url)
            }
        print("----------scanTheDirectory END--------")
      }

    //Creating a folder
    func checkFolder(url: URL) {
         debugPrint("-------------createAnotherFolder-----------------")
          //  humansURL = newFolderURL
            if !FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                    debugPrint("created at: \(url)")
                }
                catch let err {
                    print(err.localizedDescription)
                }
            } else {
                debugPrint("already created at: \(url)")
            }
        }
    
    
    func loadImgfromDisk(event: Event) -> UIImage? {
        debugPrint("-------------loadImgsfromDisk-----------------")
            do {
                
                guard let url = event.posterDataUrl else {
                    debugPrint("no url")
                    return nil
                }
                let imgData = try Data.init(contentsOf: url)
                
                guard let img = UIImage.init(data: imgData) else {
                    debugPrint("no img")
                    return nil
                }
              //  newimgs.append(retrivedImg)
                debugPrint("loaded")
                return img
            } catch {
                debugPrint(error.localizedDescription)
                return nil
            }
        
    }
}
