//
//  Tag.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI

enum Tag: Int, Codable, CaseIterable {
    case pool = 1,
         darkroom = 2,
         dragShow = 3,
         terrace = 4,
         heteroFriendly = 5,
         gayFriendly = 6,
         menOnly = 7,
         naked = 8,
         lesbian = 9,
         bar = 10,
         restaurant = 11,
         dj = 12,
         shop = 13,
         adultsOnly = 14,
         fetish = 15,
         cruise = 16,
         goGoShow = 17,
         music = 18,
         massage = 19,
         gym = 20,
         karaoke = 21,
         liveMusic = 22,
         freeWiFi = 23,
         drag = 24,
         garden = 25,
         beach = 26,
         cabins = 27,
         gay = 28,
         allGenders = 29,
         cinema = 30
    
    func getString() -> String {
        switch self {
        case .pool:
            return "pool"
        case .darkroom:
            return "darkroom"
        case .dragShow:
            return "drag show"
        case .terrace:
            return "terrace"
        case .heteroFriendly:
            return "hetero friendly"
        case .gayFriendly:
            return "gay friendly"
        case .menOnly:
            return "men only"
        case .naked:
            return "naked"
        case .lesbian:
            return "lesbian"
        case .bar:
            return "bar"
        case .restaurant:
            return "restaurant"
        case .dj:
            return "dj"
        case .shop:
            return "shop"
        case .adultsOnly:
            return "adults only"
        case .fetish:
            return "fetish"
        case .cruise:
            return "cruise"
        case .goGoShow:
            return "go-go dancing"
        case .music:
            return "music"
        case .massage:
            return "massage"
        case .gym:
            return "gym"
        case .karaoke:
            return "karaoke"
        case .liveMusic:
            return "live music"
        case .freeWiFi:
            return "free Wi-Fi"
        case .drag:
            return "drag"
        case .garden:
            return "garden"
        case .beach:
            return "beach"
        case .cabins:
            return "cabins"
        case .gay:
            return "gay"
        case .allGenders:
            return "all genders"
        case .cinema:
            return "cinema"
        }
    }
    
    func getColor() -> Color {
        switch self {
        case .pool:
            return .green
        case .darkroom:
            return .red
        case .dragShow:
            return .orange
        case .terrace:
            return .green
        case .heteroFriendly:
            return .blue
        case .gayFriendly:
            return .blue
        case .menOnly:
            return .red
        case .naked:
            return .red
        case .lesbian:
            return .blue
        case .bar:
            return .green
        case .restaurant:
            return .green
        case .dj:
            return .orange
        case .shop:
            return .green
        case .adultsOnly:
            return .red
        case .fetish:
            return .red
        case .cruise:
            return .red
        case .goGoShow:
            return .orange
        case .music:
            return .orange
        case .massage:
            return .red
        case .gym:
            return .green
        case .karaoke:
            return .orange
        case .liveMusic:
            return .orange
        case .freeWiFi:
            return .green
        case .drag:
            return .blue
        case .garden:
            return .green
        case .beach:
            return .green
        case .cabins:
            return .red
        case .gay:
            return .blue
        case .allGenders:
            return .blue
        case .cinema:
            return .green
        }
    }
}
