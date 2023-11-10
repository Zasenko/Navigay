//
//  DecodedEvent.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import Foundation

struct DecodedEvent: Identifiable, Codable {

    let id: Int
    let name: String
    let type: EventType
    let startDate: String
    let startTime: String?
    let finishDate: String?
    let finishTime: String?
    let address: String
    let latitude: Double
    let longitude: Double
    let isHorizontal: Bool
    let cover: String?
    let isFree: Bool
    let tags: [Tag]?
    let isActive: Bool
    let placeName: String?
    
    let about: String?
    let www: String?
    let fb: String?
    let insta: String?
    let tickets: String?
    let ownerPlace: DecodedPlace?
    let ownerUser: DecodedUser?
}
