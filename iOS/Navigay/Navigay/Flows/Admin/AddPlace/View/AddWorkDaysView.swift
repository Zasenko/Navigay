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

struct AddWorkDaysView: View {
    
    //MARK: - Properties
    
    @Binding var workDays: [NewWorkingDay]
    
    //MARK: - Private Properties
    @State private var days: [DayOfWeek] = DayOfWeek.allCases
    
    //MARK: - Body
    
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
