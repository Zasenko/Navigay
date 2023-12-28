//
//  UIImage+Ext.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.10.23.
//

import UIKit
import AVFoundation

extension UIImage {
    func cropImage(width: Int, height: Int) -> UIImage {
        let maxSize = CGSize(width: width, height: height)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: maxSize, format: format)
        let resized = renderer.image { (context) in
            let widthRatio = maxSize.width / self.size.width
            let heightRatio = maxSize.height / self.size.height
            let scaleFactor = max(widthRatio, heightRatio)
            let scaledSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)
            let xOffset = (maxSize.width - scaledSize.width) / 2.0
            let yOffset = (maxSize.height - scaledSize.height) / 2.0
            self.draw(in: CGRect(x: xOffset, y: yOffset, width: scaledSize.width, height: scaledSize.height))
        }
        return resized
    }
    
    func cropImage(maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
        let widthRatio = maxWidth / self.size.width
        let heightRatio = maxHeight / self.size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let scaledImageSize = CGSize(width: self.size.width * scaleFactor,
                                     height: self.size.height * scaleFactor)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize,
                                               format: format)
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        return scaledImage
    }
    
    func toData() -> Data? {
        guard let data = self.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        return data
    }
}
