//
//  MapSortingMenuView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.12.23.
//

import SwiftUI

enum SortingMapCategory {
    case bar
    case cafe
    case restaurant
    case club
    case hotel
    case sauna
    case cruiseBar
    case beach
    case shop
    case gym
    case culture
    case community
    case hostel
    case medicine
    case other
    
    case events
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
            return "Gyms"
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
        case .events:
            return "Events"
        case .all:
            return "All locations"
        }
    }
}

struct MapSortingMenuView: View {
        
    //MARK: - Properties
    
    @Binding var categories: [SortingMapCategory]
    @Binding var selectedCategory: SortingMapCategory
    
    init(categories: Binding<[SortingMapCategory]>, selectedCategory: Binding<SortingMapCategory>) {
        _categories = categories
        _selectedCategory = selectedCategory
    }

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
                        .bold()
                }
                .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    MapSortingMenuView(categories: .constant([.all, .bar, .cafe]), selectedCategory: .constant(.all))
}
