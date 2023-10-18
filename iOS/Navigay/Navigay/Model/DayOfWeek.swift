//
//  DayOfWeek.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import Foundation

enum DayOfWeek: Int, Codable, CaseIterable {
    case monday = 1,
         tuesday = 2,
         wednesday = 3,
         thursday = 4,
         friday = 5,
         saturday = 6,
         sunday = 7
    
    func getString() -> String {
        switch self {
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        case .sunday:
            return "Sunday"
        }
    }
}

struct NewWorkDay: Codable, Identifiable {
    
    let id: Int
    let day: DayOfWeek
    var opening: Date = .now
    var closing: Date = .now
    var isChecked: Bool = false
    
    init(id: Int, day: DayOfWeek, opening: Date? = nil, closing: Date? = nil) {
        self.id = id
        self.day = day
        let calendar = Calendar.current
        var components = calendar.dateComponents([.day, .hour, .minute], from: Date())
        components.hour = 0
        components.minute = 0
        let minimumDate = calendar.date(from: components)!
        let maximumDate = calendar.date(byAdding: .day, value: 1, to: minimumDate)!
        self.opening = opening ?? minimumDate
        self.closing = closing ?? maximumDate
    }
}
