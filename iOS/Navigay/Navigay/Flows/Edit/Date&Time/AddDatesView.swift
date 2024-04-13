//
//  AddDatesView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 12.04.24.
//

import SwiftUI

struct AddDatesView: View {
    
    // MARK: - Properties
    
    var onSave: ([Date]) -> Void
    
    // MARK: - Private Properties
    
    @State private var currentDate: Date = Date()
    @State private var currentMonth: Int = 0
    
    @State private var eventsDates: [Date]
    private var eventDate: Date
    
    private let days: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    private var title: String = "Add more dates"
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Inits
    
    init(eventDate: Date, eventsDates: [Date], onSave: @escaping ([Date]) -> Void) {
        self.eventDate = eventDate
        self.onSave = onSave
        _eventsDates = State(initialValue: eventsDates)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                ScrollView {
                calendarView
                Divider()
                    Text("Event start dates:")
                        .padding()
                    Text(eventDate.formatted(date: .long, time: .omitted))
                        .padding(.bottom)
                    VStack(alignment: .leading) {
                        ForEach(eventsDates.sorted(), id: \.self) { date in
                            Text(date.formatted(date: .long, time: .omitted))
                                .tint(.primary)
                                .padding(.bottom, 8)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline.bold())
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        AppImages.iconLeft
                            .bold()
                            .frame(width: 30, height: 30, alignment: .leading)
                    }
                    .tint(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onSave(eventsDates)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var calendarView: some View {
        VStack(spacing: 0) {
            HStack {
                Text(getMonthString())
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                Button {
                    withAnimation {
                        currentMonth += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3.bold())
                        .frame(width: 40, height: 40, alignment: .center)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            VStack {
                HStack {
                    ForEach(days, id: \.self) { day in
                        Text(day.uppercased())
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(getMonthDates()) { value in
                        CardView(value: value)
                    }
                }
            }
            .padding()
        }
        .onChange(of: currentMonth) { oldValue, newValue in
            currentDate = getCurrentMonth()
        }
    }
    
    @ViewBuilder
    private func CardView(value: CalendarDay) -> some View {
        VStack {
            if value.day != -1 {
                Button {
                    if let index = eventsDates.firstIndex(where: { $0.isSameDayWithOtherDate(value.date) }) {
                        eventsDates.remove(at: index)
                    } else {
                        eventsDates.append(value.date)
                    }
                } label: {
                    Text("\(value.day)")
                        .font(.body)
                        .foregroundStyle(value.date.isPastDate ? AppColors.lightGray5 : value.date.isToday ? .red : eventsDates.contains(where: { $0.isSameDayWithOtherDate(value.date)}) || value.date.isSameDayWithOtherDate(eventDate) ? .blue : .secondary)
                        .fontWeight(value.date.isToday || eventsDates.contains(where: { $0.isSameDayWithOtherDate(value.date)}) || value.date.isSameDayWithOtherDate(eventDate) ? .bold : .medium)
                        .frame(width: 40, height: 40, alignment: .center)
                        .background(value.date.isPastDate ? .clear : value.date.isSameDayWithOtherDate(eventDate) ? .blue.opacity(0.2) : eventsDates.contains(where: { $0.isSameDayWithOtherDate(value.date)}) ? .blue.opacity(0.2) : AppColors.lightGray6)
                        .clipShape(Circle())
                        .padding(.bottom, 8)
                }
                .disabled(value.date.isPastDate)
                .disabled(value.date.isSameDayWithOtherDate(eventDate))
            }
        }
    }
    
    // MARK: - Private Functions
    
    // TODO: - Doublicate: (CalendarView)
    
    private func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return Date()
        }
        return currentMonth
    }
    
    private func getMonthDates() -> [CalendarDay] {
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
    
    private func getMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM • yy"
        return formatter.string(from: currentDate)
    }
}

#Preview {
    let dateStrings = [
        "2024-04-17 23:00:00 +0000",
        "2024-04-30 23:00:00 +0000",
        "2024-04-18 23:00:00 +0000",
        "2024-04-21 23:00:00 +0000",
        "2024-05-05 23:00:00 +0000",
        "2024-05-06 23:00:00 +0000",
        "2024-06-02 23:00:00 +0000"
    ]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    let dates: [Date] = dateStrings.compactMap { dateString in
        dateFormatter.date(from: dateString)
    }
    return AddDatesView(eventDate: Date().nextDay ?? .now, eventsDates: dates) { _ in
    }
}
