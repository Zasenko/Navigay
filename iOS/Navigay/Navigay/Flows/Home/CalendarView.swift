//
//  CalendarView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 18.12.23.
//

import SwiftUI

//struct CalendarWeekDay: Identifiable {
//    var id: UUID = .init()
//    var date: Date
//}

struct CalendarView: View {
    
    @Binding var selectedDate: Date?
    @Binding var activeDates: [Date]
    
    @State private var maxEventDate: Date = Date()
    @State private var currentDate: Date = Date()

    init(selectedDate: Binding<Date?>, activeDates: Binding<[Date]>) {
        _selectedDate = selectedDate
        _activeDates = activeDates
    }

    var body: some View {
        
        CustomDatePicker(selectedDate: $selectedDate, activeDates: $activeDates, maxEventDate: $maxEventDate, currentDate: $currentDate)

        .onChange(of: activeDates, initial: true) { _, newValue in
            if let maxDate = newValue.max() {
                maxEventDate = maxDate
            }
        }
    }
}

#Preview {
    let dateStrings = [
        "2023-12-21 23:00:00 +0000",
        "2023-12-22 23:00:00 +0000",

        "2023-12-29 23:00:00 +0000",
        "2023-12-30 23:00:00 +0000",
        "2023-12-31 23:00:00 +0000",
        "2024-01-04 23:00:00 +0000",
        "2024-01-05 23:00:00 +0000",
        "2024-01-06 23:00:00 +0000",
        "2024-02-02 23:00:00 +0000"
    ]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

    let dates: [Date] = dateStrings.compactMap { dateString in
        dateFormatter.date(from: dateString)
    }
    
    return CalendarView(selectedDate: .constant(Date()), activeDates: .constant(dates))
}


struct CustomDatePicker: View {
    
    @Binding var selectedDate: Date?
    @Binding var activeDates: [Date]
    
    @Binding var maxEventDate: Date
    
    @Binding var currentDate: Date
    @State private var currentMonth: Int = 0
    
    private let days: [String] = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                HStack {
                //    VStack(alignment: .leading, spacing: 0) {
                        Text(extraDate()[0])
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Text(extraDate()[1])
                            .font(.title3.bold())
                 //   }
                    .frame(maxWidth: .infinity)
                  //  .background(.yellow)
                    Spacer()
                    Button {
                        withAnimation {
                            currentMonth -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .frame(width: 40, height: 40, alignment: .center)
                    }
                    .disabled(currentDate.isSameMonth(with: Date()))
                  //  .background(.yellow)
                    Button {
                        withAnimation {
                            currentMonth += 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3.bold())
                            .frame(width: 40, height: 40, alignment: .center)
                    }
                    .disabled(currentDate.isSameMonth(with: maxEventDate))
                 //   .background(.yellow)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
              //  .background(.red)
            Divider()
            VStack{
                HStack {
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.lightGray3)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 5)
                
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(extractDate()) { value in
                        CardView(value: value)
                    }
                }
            }
            Divider()
        }
        .onChange(of: currentMonth) { oldValue, newValue in
            currentDate = getCurrentMonth()
        }
    }
    
    @ViewBuilder
    func CardView(value: DateValue) -> some View {
        VStack{
            if value.day != -1 {
                Button {
                    selectedDate = value.date
                } label: {
                    Text("\(value.day)")
                        .font(.body)
                      //  .foregroundStyle(value.date.isToday ? .red : AppColors.lightGray3)
                        .fontWeight(value.date.isToday || activeDates.contains(where: { $0.isSameDayWithOtherDate(value.date)}) ? .bold : .regular)
                        .frame(width: 35, height: 35, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                      //  .padding(10)
                       .background(activeDates.contains(where: { $0.isSameDayWithOtherDate(value.date)}) ? .blue : .clear)
                        .clipShape(Circle())
                }
                .disabled(!activeDates.contains(where: { $0.isSameDayWithOtherDate(value.date)}) )

                
                
                
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
    
    func extractDate() -> [DateValue] {
        let calendar = Calendar.current
        let currentMonth = getCurrentMonth()
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        return days
    }
    
    func extraDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        let date = formatter.string(from: currentDate)
        return date.components(separatedBy: " ")
    }
}

extension Date{
    
    func isSameMonth(with otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.month], from: self)
        let components2 = calendar.dateComponents([.month], from: otherDate)
        return components1.month == components2.month
    }
    
    func getAllDates()-> [Date] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        return range.compactMap { day -> Date in
            return calendar.date (byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}

struct DateValue: Identifiable{
    var id = UUID().uuidString
    var day: Int
    var date: Date
}
