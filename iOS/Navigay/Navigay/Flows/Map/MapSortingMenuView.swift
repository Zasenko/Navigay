//
//  MapSortingMenuView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.12.23.
//

import SwiftUI

enum SortingCategory {
    case events
    case bar
    case cafe
    case restaurant
    case club
    case sauna
    case cruiseBar
    case cruiseClub
    case shop
    case hotel
    case hostel
    case beach
    case gym
    case culture
    case community
    case medicine
    case rights
    case other
    
    case all
    
    init?(placeType: PlaceType) {
        switch placeType {
        case .other:
            self = .other
        case .bar:
            self = .bar
        case .cafe:
            self = .cafe
        case .restaurant:
            self = .restaurant
        case .club:
            self = .club
        case .hotel:
            self = .hotel
        case .sauna:
            self = .sauna
        case .cruiseBar:
            self = .cruiseBar
        case .beach:
            self = .beach
        case .shop:
            self = .shop
        case .gym:
            self = .gym
        case .culture:
            self = .culture
        case .community:
            self = .community
        case .hostel:
            self = .hostel
        case .medicine:
            self = .medicine
        case .cruiseClub:
            self = .cruiseClub
        case .rights:
            self = .rights
        }
    }
    
    func getName() -> String {
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
            return "Cruise Clubs"
        case .events:
            return "Today's Events"
        case .all:
            return "All locations"
        case .rights:
            return "Rights"
        }
    }
    
    func getSortPreority() -> Int {
        switch self {
        case .events:
            1
        case .bar:
            2
        case .club:
            3
        case .cafe:
            4
        case .restaurant:
            5
        case .sauna:
            6
        case .cruiseBar:
            7
        case .cruiseClub:
            8
        case .shop:
            9
        case .hotel:
            10
        case .hostel:
            11
        case .beach:
            12
        case .gym:
            13
        case .culture:
            14
        case .community:
            15
        case .medicine:
            16
        case .rights:
            17
        case .other:
            18
        case .all:
            19
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
            return "🔥"
        case .rights:
            return "🏛️"
        case .events:
            return ""
        case .all:
            return ""
        }
    }
}

struct MapSortingMenuView: View {
        
    //MARK: - Properties
    
    let categories: [SortingCategory]
    @Binding var selectedCategory: SortingCategory

    //MARK: - Body
    
    var body: some View {
        VStack {
            Menu {
                ForEach(categories, id: \.self) { category in
                    if category != selectedCategory {
                        Button {
                            selectedCategory = category
                        } label: {
                            Text(category.getName())
                        }
                    }
                }
            } label: {
                HStack(alignment: .lastTextBaseline) {
                    Text(selectedCategory.getName())
                        .font(.title).bold()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(.blue)
                }
                .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    MapSortingMenuView(categories: [.all, .bar, .cafe], selectedCategory: .constant(.all))
}
