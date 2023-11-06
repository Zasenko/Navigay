//
//  PlaceActivationInfo.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.11.23.
//

import Foundation

struct PlaceActivationInfo: Codable {

    let id: Int
    let isActive: Bool
    let isChecked: Bool
    
    init(id: Int, isActive: Bool, isChecked: Bool) {
        self.id = id
        self.isActive = isActive
        self.isChecked = isChecked
    }
}
