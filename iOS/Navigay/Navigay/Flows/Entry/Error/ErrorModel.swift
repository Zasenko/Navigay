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
    let massage: String
    let img: Image
    let color: Color
    
    // MARK: - Init
    
    init(massage: String, img: Image?, color: Color?) {
        self.id = UUID()
        self.massage = massage
        self.img = img ?? Image(systemName: "exclamationmark.triangle")
        self.color = color ?? .red
    }
}
