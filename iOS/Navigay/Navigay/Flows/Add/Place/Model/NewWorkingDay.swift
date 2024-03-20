//
//  NewWorkingDay.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 24.10.23.
//

import Foundation

struct NewWorkingDay: Identifiable, Hashable {
    
    //MARK: - Properties
    
    let id: UUID = UUID()
    let day: DayOfWeek
    var opening: Date
    var closing: Date
    
    //MARK: - Inits
    
    init(day: DayOfWeek, opening: Date? = nil, closing: Date? = nil) {
        self.day = day
        let zeroTime = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()
        self.opening = opening ?? zeroTime
        self.closing = closing ?? zeroTime
    }
}
