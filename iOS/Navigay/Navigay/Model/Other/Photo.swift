//
//  Photo.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import SwiftUI

struct Photo: Identifiable {
    let id: UUID
    var image: Image
        
    init(id: UUID, image: Image) {
        self.id = id
        self.image = image
    }
    
    mutating func updateImage(image: Image) {
        self.image = image
    }
}
