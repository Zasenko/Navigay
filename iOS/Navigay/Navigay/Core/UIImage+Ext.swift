//
//  UIImage+Ext.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.10.23.
//

import UIKit

extension UIImage {
    func scaleAndFill(targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = max(widthRatio, heightRatio)
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        let xOffset = (targetSize.width - scaledImageSize.width) / 2
        let yOffset = (targetSize.height - scaledImageSize.height) / 2
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let scaledAndFilledImage = renderer.image { _ in
            self.draw(in: CGRect(
                x: xOffset,
                y: yOffset,
                width: scaledImageSize.width,
                height: scaledImageSize.height
            ))
        }
        return scaledAndFilledImage
    }
}
