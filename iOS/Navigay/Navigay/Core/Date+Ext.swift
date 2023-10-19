//
//  Date+Ext.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 26.09.23.
//

import Foundation

extension Date {
    
    /// Custom Date Format
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// Checking if the date is Today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// Checking if the date is Tomorrow
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    /// Checking if the date is Yesterday
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    var isWeekend: Bool {
        return Calendar.current.isDateInWeekend(self)
    }
    
    /// Checking if the date is Today Same Day
    var isSameDay: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .day) == .orderedSame
    }
    
    /// Checking if the date is Today Same Hour
    var isSameHour: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedSame
    }
    
    /// Checking if the date is Past Day form Today
    var isPastDate: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .day) == .orderedAscending
    }
    
    /// Checking if the date is Past Hour  form Today
    var isPastHour: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedAscending
    }
    
    /// Checking if the date is Same Day with other Date
    func isSameDayWithOtherDate(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
//    /// Fetching week based on given date
//    func fetchWeek(_ date: Date = .init()) -> [CalendarWeekDay] {
//        let calendar = Calendar.current
//        let startDate = calendar.startOfDay(for: date)
//        
//        var week: [CalendarWeekDay] = []
//        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startDate)
//        guard let startOfWeek = weekForDate?.start else {
//            return []
//        }
//        (0..<7).forEach { index in
//            if let weekDay = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
//                week.append(.init(date: weekDay))
//            }
//        }
//        return week
//    }
//    
//    /// Creating Next Week, based on the Last Current Week's Date
//    func createNextWeek() -> [CalendarWeekDay] {
//        let calendar = Calendar.current
//        let startOfLastDate = calendar.startOfDay(for: self)
//        guard let nextDate = calendar.date (byAdding: .day, value: 1, to: startOfLastDate) else {
//            return []
//        }
//        return fetchWeek(nextDate)
//    }
//    
//    /// Creating Previous Week, based on the First Current Week's Date
//    func createPreviousWeek() -> [CalendarWeekDay] {
//        let calendar = Calendar.current
//        let startOfFirstDate = calendar.startOfDay(for: self)
//        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: startOfFirstDate) else {
//            return []
//        }
//        return fetchWeek(previousDate)
//    }
}
