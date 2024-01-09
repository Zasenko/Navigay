//
//  PlaceType.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import SwiftUI

enum PlaceType: Int, Codable, CaseIterable, Comparable {
    case other = 0,
         bar = 1,
         cafe = 2,
         restaurant = 3,
         club = 4,
         hotel = 5,
         sauna = 6,
         cruiseBar = 7,
         beach = 8,
         shop = 9,
         gym = 10,
         culture = 11,
         community = 12,
         hostel = 13,
         medicine = 14,
         cruiseClub = 15
    
    func getName() -> String {
        switch self {
        case .bar:
            return "Bar"
        case .cafe:
            return "Cafe"
        case .restaurant:
            return "Restaurant"
        case .club:
            return "Club"
        case .hotel:
            return "Hotel"
        case .sauna:
            return "Sauna"
        case .cruiseBar:
            return "Cruise bar"
        case .beach:
            return "Beach"
        case .shop:
            return "Shop"
        case .gym:
            return "Sport"
        case .culture:
            return "Cultur"
        case .community:
            return "Community"
        case .other:
            return "Other"
        case .hostel:
            return "Hostel"
        case .medicine:
            return "Medicine"
        case .cruiseClub:
            return "Cruise Club"
        }
    }
    
    func getPluralName() -> String {
        switch self {
        case .bar:
            return "Bars"
        case .cafe:
            return "Cafes"
        case .restaurant:
            return "Restaurants"
        case .club:
            return "Clubs"
        case .hotel:
            return "Hotels"
        case .sauna:
            return "Saunas"
        case .cruiseBar:
            return "Cruise bars"
        case .beach:
            return "Beaches"
        case .shop:
            return "Shops"
        case .gym:
            return "Sport"
        case .culture:
            return "Cultur"
        case .community:
            return "Communities"
        case .other:
            return "Other"
        case .hostel:
            return "Hostels"
        case .medicine:
            return "Medicine"
        case .cruiseClub:
            return "Cruise clubs"
        }
    }
    
    func getColor() -> Color {
        switch self {
        case .bar:
            return Color.teal
        case .cafe:
            return Color.yellow
        case .restaurant:
            return Color.green
        case .club:
            return Color.mint
        case .hotel:
            return Color.gray
        case .sauna:
            return Color.blue
        case .cruiseBar:
            return Color.red
        case .beach:
            return Color.yellow
        case .shop:
            return Color.blue
        case .gym:
            return Color.blue
        case .culture:
            return Color.blue
        case .community:
            return Color.pink
        case .other:
            return Color.blue
        case .hostel:
            return Color.gray
        case .medicine:
            return Color.green
        case .cruiseClub:
            return Color.red
        }
    }
    
    func getImage() -> String {
        switch self {
        case .bar:
            return "🍷"
        case .cafe:
            return "☕️"
        case .restaurant:
            return "🍴"
        case .club:
            return "💃"
        case .hotel:
            return "🛏️"
        case .sauna:
            return "🧖‍♂️"
        case .cruiseBar:
            return "😈"
        case .beach:
            return "⛱️"
        case .shop:
            return "🛍️"
        case .gym:
            return "💪"
        case .culture:
            return "🎭"
        case .community:
            return "👥"
        case .other:
            return "🏳️‍🌈"
        case .hostel:
            return "🛏️"
        case .medicine:
            return "😷"
        case .cruiseClub:
            return "😈"
        }
    }
    
    static func < (lhs: PlaceType, rhs: PlaceType) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
}
