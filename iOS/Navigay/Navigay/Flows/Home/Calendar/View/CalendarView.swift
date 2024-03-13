//
//  CalendarView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 18.12.23.
//

import SwiftUI

struct CalendarView: View {
    
    @Binding var selectedDate: Date?
    @Binding var eventsDates: [Date]
    
    @State private var maxEventDate: Date = Date()
    
    @State private var currentDate: Date = Date()
    @State private var currentMonth: Int = 0
    
    private let days: [String] = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"] //TODO!!!!!!!!!!!!!!!!!!!!!!
    
    init(selectedDate: Binding<Date?>, eventsDates: Binding<[Date]>) {
        _selectedDate = selectedDate
        _eventsDates = eventsDates
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Text(extraDate())
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                    //Spacer()
                    Button {
                        withAnimation {
                            currentMonth -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.bold())
                            .frame(width: 40, height: 40, alignment: .center)
                    }
                    .disabled(currentDate.isSameMonth(with: Date()))
                    Button {
                        withAnimation {
                            currentMonth += 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.headline.bold())
                            .frame(width: 40, height: 40, alignment: .center)
                    }
                    .disabled(currentDate.isSameMonth(with: maxEventDate))
                }
                .padding()
                Divider()
                VStack{
                    HStack {
                        ForEach(days, id: \.self) { day in
                            Text(day)
                                .font(.callout.bold())
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 5)
                    
                    let columns = Array(repeating: GridItem(.flexible()), count: 7)
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(getMonthDates()) { value in
                            CardView(value: value)
                        }
                    }
                }
                .padding()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            Button{
                selectedDate = nil
            } label: {
                Text("Show upcoming events")
            }
        }
        .background(.ultraThinMaterial)
        .onChange(of: eventsDates, initial: true) { _, newValue in
            if let maxDate = newValue.max() {
                maxEventDate = maxDate
            }
        }
        .onChange(of: currentMonth) { oldValue, newValue in
            currentDate = getCurrentMonth()
        }
    }
    
    @ViewBuilder
    func CardView(value: CalendarDay) -> some View {
        VStack{
            if value.day != -1 {
                Button {
                    selectedDate = value.date
                } label: {
                    Text("\(value.day)")
                        .font(.body)
                        .foregroundStyle(value.date.isToday ? .red : eventsDates.contains(where: { $0.isSameDayWithOtherDate(value.date)}) ? .blue : .secondary)
                        .fontWeight(value.date.isToday || eventsDates.contains(where: { $0.isSameDayWithOtherDate(value.date)}) ? .bold : .regular)
                        .frame(width: 35, height: 35, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(value.date.isToday ? .clear : eventsDates.contains(where: { $0.isSameDayWithOtherDate(value.date)}) ? .blue.opacity(0.2) : .clear)
                        .clipShape(Circle())
                }
                .disabled(!eventsDates.contains(where: { $0.isSameDayWithOtherDate(value.date)}) )
                .disabled(value.date.isToday)
            }
        }
    }
    
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return Date()
        }
        return currentMonth
    }
    
    func getMonthDates() -> [CalendarDay] {
        let calendar = Calendar.current
        let currentMonth = getCurrentMonth()
        var days = currentMonth.getAllMonthDates().compactMap { date -> CalendarDay in
            let day = calendar.component(.day, from: date)
            return CalendarDay(day: day, date: date)
        }
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        for _ in 0..<firstWeekday - 1 {
            days.insert(CalendarDay(day: -1, date: Date()), at: 0)
        }
        return days
    }
    
    //TODO переименовать и поправить
    func extraDate() -> String {
        let formatter = DateFormatter()
        let phoneLanguage = NSLocale.preferredLanguages.first
        let language = phoneLanguage ?? "en"
        formatter.locale = Locale(identifier: language)
        // formatter.dateFormat = "MM yyyy"
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: language)
        let components = calendar.dateComponents([.month, .year], from: currentDate)
        guard let month = components.month, let year = components.year else {
            return ""
        }
        
        // Получаем название месяца из standaloneMonthSymbols
        let monthName = calendar.standaloneMonthSymbols[month - 1]
        
        // Формируем строку с названием месяца и годом
        let result = "\(monthName) \(year)"
        
        return result
        // let date = formatter.string(from: currentDate)
        // let stringDate = date.components(separatedBy: " ")
        
        //        let stringMonth = stringDate[0]
        //
        //
        //        let test = Calendar.current.standaloneMonthSymbols[Int(stringMonth) ?? 0]
        //        print(test)
        
        // return formatter.string(from: currentDate)
    }
}

//#Preview {
//    let dateStrings = [
//        "2023-12-21 23:00:00 +0000",
//        "2023-12-22 23:00:00 +0000",
//
//        "2023-12-29 23:00:00 +0000",
//        "2023-12-30 23:00:00 +0000",
//        "2023-12-31 23:00:00 +0000",
//        "2024-01-04 23:00:00 +0000",
//        "2024-01-05 23:00:00 +0000",
//        "2024-01-06 23:00:00 +0000",
//        "2024-02-02 23:00:00 +0000"
//    ]
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
//
//    let dates: [Date] = dateStrings.compactMap { dateString in
//        dateFormatter.date(from: dateString)
//    }
//
//    return CalendarView(selectedDate: .constant(Date()), activeDates: .constant(dates))
//}
