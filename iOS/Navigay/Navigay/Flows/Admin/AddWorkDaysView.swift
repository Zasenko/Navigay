//
//  AddWorkDaysView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 20.10.23.
//

import SwiftUI

//#Preview {
//    AddWorkDaysView()
//}

struct NewWorkingDay: Identifiable, Hashable {
    let id: UUID = UUID()
    let day: DayOfWeek
    var opening: Date
    var closing: Date
    
    init(day: DayOfWeek, opening: Date? = nil, closing: Date? = nil) {
        self.day = day
        let zeroTime = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()
        self.opening = opening ?? zeroTime
        self.closing = closing ?? zeroTime
        
    }
}

struct AddWorkDaysView: View {
    @State private var days: [DayOfWeek] = DayOfWeek.allCases
    @Binding var workDays: [NewWorkingDay]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(days.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { day in
                        Button {
                            let newWorkingDay = NewWorkingDay(day: day)
                            withAnimation {
                                days.removeAll(where: { $0 == day })
                                workDays.append(newWorkingDay)
                                workDays.sort(by: { $0.day.rawValue < $1.day.rawValue })
                            }
                        } label: {
                            Text(day.getShortString())
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            
            VStack {
                ForEach($workDays) { $day in
                    WorkingDayRow(day: $day, onDelete: {
                        if let index = workDays.firstIndex(of: day) {
                            days.append(day.day)
                            workDays.remove(at: index)
                        }
                    })
                }
            }
        }
        .padding()
    }
}

struct WorkingDayRow: View {
    @Binding var day: NewWorkingDay
    var onDelete: () -> Void
    
    var body: some View {
        AddWorkingDaysView(day: $day, onDelete: onDelete)
    }
}

struct AddWorkingDaysView: View {
    @Binding var day: NewWorkingDay
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(day.day.getString())
            DatePicker(
                "open time",
                selection: $day.opening,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.automatic)
            .labelsHidden()
            
            Text("—")
            
            DatePicker(
                "Select Time",
                selection: $day.closing,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            
            Button(action: onDelete) {
                AppImages.iconTrash
                    .foregroundStyle(.red)
            }
            .buttonStyle(.bordered)
        }
    }
}
