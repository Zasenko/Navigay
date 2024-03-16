//
//  AdminPhoto.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.03.24.
//

import SwiftUI

struct AdminPhoto: Identifiable, Equatable {
    
    let id: String
    var image: Image?
    let url: String?
    
        
    init?(id: String, image: Image?, url: String?) {
        if image == nil && url == nil {
            return nil
        }
        self.id = id
        self.image = image
        self.url = url
    }
    
    mutating func updateImage(image: Image) {
        self.image = image
    }
    
    static func ==(lhs: AdminPhoto, rhs: AdminPhoto) -> Bool {
        return lhs.id == rhs.id
    }
}
