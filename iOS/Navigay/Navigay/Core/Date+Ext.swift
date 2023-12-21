//
//  Date+Ext.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 26.09.23.
//

import Foundation

extension Date {
    
    /// Custom Date Format / example:  "HH:mm"
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
    /// Checking if the date is in weekend
    var isWeekend: Bool {
        return Calendar.current.isDateInWeekend(self)
    }
    
    /// Checking if the date is Past Day form Today
    var isPastDate: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .day) == .orderedAscending
    }
    
    var isFutureDay: Bool {
        return Calendar.current.compare(self, to: Date(), toGranularity: .day) == .orderedDescending
    }
    
    func getAllDatesBetween(finishDate: Date) -> [Date] {
        var startDate = self
        var allDates: [Date] = []
        let oneDay: TimeInterval = 24 * 60 * 60
        while startDate <= finishDate {
            allDates.append(startDate)
            startDate = startDate.addingTimeInterval(oneDay)
        }
        return allDates
    }

    func isSameHour(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.hour], from: self)
        let components2 = calendar.dateComponents([.hour], from: otherDate)
        return components1.hour == components2.hour
    }
    
    func isSameMonth(with otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.month], from: self)
        let components2 = calendar.dateComponents([.month], from: otherDate)
        return components1.month == components2.month
    }
    
    func isPastHour(of otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.hour], from: self)
        let components2 = calendar.dateComponents([.hour], from: otherDate)
        return components1.hour! < components2.hour!//TODO:  components1.hour!
    }
    
    func isFutureHour(of otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.hour], from: self)
        let components2 = calendar.dateComponents([.hour], from: otherDate)
        return components1.hour! > components2.hour!//TODO:  components1.hour!
    }
    
    /// next day from date
    var nextDay: Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
    
    /// Checking if the date is Same Day with other Date
    func isSameDayWithOtherDate(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    var dayOfWeek: DayOfWeek? {
        let dayNumber = Calendar.current.component(.weekday, from: self)
        switch dayNumber {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            return nil
        }
    }
    
    /// for Calendar
    func getAllMonthDates()-> [Date] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        return range.compactMap { day -> Date in
            return calendar.date (byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}
