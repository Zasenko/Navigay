//
//  TimetableView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 29.01.24.
//

import SwiftUI

struct TimetableView: View {
    
    let place: Place
    let showOpenInfo: Bool
    
    var body: some View {
        Section {
            Text("Timetable")
            .font(.title)
            .foregroundStyle(.secondary)
            ForEach(place.timetable.sorted(by: { $0.day.rawValue < $1.day.rawValue } )) { day in
                let dayOfWeek = Date().dayOfWeek
                HStack {
                    Text(day.day.getString())
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if showOpenInfo, dayOfWeek == day.day {
                        if place.isOpenNow() {
                            Text("open now")
                                .font(.footnote).bold()
                                .foregroundColor(.green)
                                .padding(.trailing)
                        }
                    }
                    Text(day.open.formatted(date: .omitted, time: .shortened))
                    Text("—")
                    Text(day.close.formatted(date: .omitted, time: .shortened))
                }
                .font(.caption)
                .listRowBackground(dayOfWeek == day.day ? AppColors.lightGray6.opacity(0.5) : AppColors.background)
            }
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .listSectionSeparator(.hidden)
    }
}
//#Preview {
//    TimetableView()
//}
