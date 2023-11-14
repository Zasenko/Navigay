//
//  EventTimeFieldsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import SwiftUI

struct EventTimeFieldsView: View {
    
    @Binding var startDate: Date?
    @Binding var startTime: Date?
    @Binding var finishDate: Date?
    @Binding var finishTime: Date?
    
    var body: some View {
            VStack(spacing: 0) {
                StartDateField
                Divider()
                    .padding(.horizontal)
                StartTimeField
                Divider()
                    .padding(.horizontal)
                FinishDateField
                Divider()
                    .padding(.horizontal)
                FinisTimeField
            }
            .background(AppColors.lightGray6)
            .cornerRadius(10)
            .padding()
    }
    
    private var StartDateField: some View {
        NavigationLink {
            EditDateView(date: startDate, pickerStartDate: nil, editType: .start) { date in
                startDate = date
            } onDelete: { }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text("Start date")
                        .font(.callout)
                        .foregroundStyle(startDate == nil ? .red : .green)
                    if let startDate {
                        Text(startDate.formatted(date: .long, time: .omitted))
                            .multilineTextAlignment(.leading)
                            .tint(.primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                AppImages.iconRight
                    .foregroundStyle(.quaternary)
            }
            .padding()
            .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
        }
    }
    
    private var StartTimeField: some View {
        NavigationLink {
            EditTimeView(time: startTime, editType: .start) { time in
                startTime = time
            } onDelete: {
                startTime = nil
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text("Start time")
                        .font(.callout)
                        .foregroundStyle(startTime == nil ? Color.secondary : .green)
                    if let startTime {
                        Text(startTime.formatted(date: .omitted, time: .shortened))
                            .multilineTextAlignment(.leading)
                            .tint(.primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                AppImages.iconRight
                    .foregroundStyle(.quaternary)
            }
            .padding()
            .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
        }
    }
    
    private var FinishDateField: some View {
        NavigationLink {
            EditDateView(date: finishDate, pickerStartDate: startDate, editType: .finish) { date in
                finishDate = date
            } onDelete: { 
                finishDate = nil
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text("Finish date")
                        .font(.callout)
                        .foregroundStyle(finishDate == nil ? Color.secondary : .green)
                    if let finishDate {
                        Text(finishDate.formatted(date: .long, time: .omitted))
                            .multilineTextAlignment(.leading)
                            .tint(.primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                AppImages.iconRight
                    .foregroundStyle(.quaternary)
            }
            .padding()
            .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
        }
    }
    
    private var FinisTimeField: some View {
        NavigationLink {
            EditTimeView(time: finishTime, editType: .finish) { time in
                finishTime = time
            } onDelete: {
                finishTime = nil
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text("Finish time")
                        .font(.callout)
                        .foregroundStyle(finishTime == nil ? Color.secondary : .green)
                    if let finishTime {
                        Text(finishTime.formatted(date: .omitted, time: .shortened))
                            .multilineTextAlignment(.leading)
                            .tint(.primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                AppImages.iconRight
                    .foregroundStyle(.quaternary)
            }
            .padding()
            .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
        }
    }
}

//#Preview {
//    EventTimeFieldsView(startDate: .constant(.now), startTime: .constant(.now), finishDate: .constant(.now), finishTime: .constant(.now))
//}
