//
//  Region.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftData

@Model
final class Region {
    let id: Int
    var name: String? = nil
    var country: Country? = nil
    var isActive: Bool = true
    @Relationship(deleteRule: .cascade, inverse: \City.region) var cities: [City] = []
    
    init(decodedRegion: DecodedRegion) {
        self.id = decodedRegion.id
        updateRegion(decodedRegion: decodedRegion)
    }
    
    func updateRegion(decodedRegion: DecodedRegion) {
        name = decodedRegion.name
        isActive = decodedRegion.isActive
    }
}
