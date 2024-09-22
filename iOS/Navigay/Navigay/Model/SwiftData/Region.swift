//
//  Region.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import Foundation
import SwiftData

@Model
final class Region {
    private(set) var id: Int
    var name: String? = nil
    var country: Country? = nil
    var photo: String?
    var lastUpdateIncomplete: Date? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \City.region) var cities: [City] = []
    
    init(decodedRegion: DecodedRegion) {
        self.id = decodedRegion.id
        updateIncomplete(decodedRegion: decodedRegion)
    }
    
    func updateIncomplete(decodedRegion: DecodedRegion) {
        let lastUpdate = decodedRegion.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        guard lastUpdateIncomplete != lastUpdate else { return }
        name = decodedRegion.name
        lastUpdateIncomplete = lastUpdate
    }
}
