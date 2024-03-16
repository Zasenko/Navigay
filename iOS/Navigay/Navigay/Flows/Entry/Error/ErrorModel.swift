//
//  ErrorModel.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import SwiftUI

struct ErrorModel: Identifiable {
    
    // MARK: - Properties
    
    let id: UUID
    let message: String
    let img: Image
    let color: Color
    let error: Error
    
    // MARK: - Init
    
    init(error: Error, massage: String, img: Image? = nil, color: Color? = nil) {
        self.id = UUID()
        self.message = massage
        self.img = img ?? AppImages.iconExclamationmarkTriangle
        self.color = color ?? .red
        self.error = error
    }
}
