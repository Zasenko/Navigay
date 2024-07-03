//
//  Image+Ext.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 24.06.24.
//

import SwiftUI

extension Image {
    
    func toUIImage(width: Int, height: Int) -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        let targetSize = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
        }
    }
}
