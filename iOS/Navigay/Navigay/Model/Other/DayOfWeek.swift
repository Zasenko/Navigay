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
        let calendar = Calendar.current
       // let phoneLanguage = NSLocale.preferredLanguages.first
      //  let language = phoneLanguage?.components(separatedBy: "-").first  ?? "en"
      //  calendar.locale = Locale(identifier: language)
        switch self {
        case .sunday:
            return calendar.standaloneWeekdaySymbols[0]
        case .monday:
            return calendar.standaloneWeekdaySymbols[1]
        case .tuesday:
            return calendar.standaloneWeekdaySymbols[2]
        case .wednesday:
            return calendar.standaloneWeekdaySymbols[3]
        case .thursday:
            return calendar.standaloneWeekdaySymbols[4]
        case .friday:
            return calendar.standaloneWeekdaySymbols[5]
        case .saturday:
            return calendar.standaloneWeekdaySymbols[6]
        }
    }
    
    func getShortString() -> String {
        var calendar = Calendar.current
        let phoneLanguage = NSLocale.preferredLanguages.first
        let language = phoneLanguage?.components(separatedBy: "-").first  ?? "en"
        calendar.locale = Locale(identifier: language)
        switch self {
        case .monday:
            return calendar.shortWeekdaySymbols[1]
        case .tuesday:
            return calendar.shortWeekdaySymbols[2]
        case .wednesday:
            return calendar.shortWeekdaySymbols[3]
        case .thursday:
            return calendar.shortWeekdaySymbols[4]
        case .friday:
            return calendar.shortWeekdaySymbols[5]
        case .saturday:
            return calendar.shortWeekdaySymbols[6]
        case .sunday:
            return calendar.shortWeekdaySymbols[0]
        }
    }
}
