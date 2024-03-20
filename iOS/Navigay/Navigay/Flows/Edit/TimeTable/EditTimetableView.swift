//
//  EditTimetableView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.11.23.
//

import SwiftUI

struct EditTimetableView: View {
    
    //MARK: - Properties
    
    var onSave: ([NewWorkingDay]) -> Void
    
    //MARK: - Private Properties
    
    @State private var days: [DayOfWeek] = DayOfWeek.allCases
    @State private var timetable: [NewWorkingDay] = []
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits
    
    init(timetable: [NewWorkingDay], onSave: @escaping ([NewWorkingDay]) -> Void) {
        _timetable = State(initialValue: timetable)
        _days = State(initialValue: DayOfWeek.allCases.filter { day in
            return !timetable.contains { $0.day == day }
        })
        self.onSave = onSave
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                daysButtons
                if !days.isEmpty {
                    Divider()
                }
                timetableView
                Spacer()
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Timetable")
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
                        onSave(timetable)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
    
    //MARK: - Views
    
    private var daysButtons: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(days.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { day in
                    Button {
                        dayButtonTupped(day: day)
                    } label: {
                        Text(day.getShortString())
                            .font(.caption)
                            .bold()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
    }
    
    private var timetableView: some View {
        VStack(spacing: 10) {
            ForEach($timetable) { $day in
                HStack {
                    Text(day.day.getString())
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    DatePicker(
                        "open time",
                        selection: $day.opening,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.automatic)
                    .labelsHidden()
                    Text("—")
                        .font(.callout)
                    DatePicker(
                        "Select Time",
                        selection: $day.closing,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    Button {
                        deleteButtonTupped(day: day)
                    } label: {
                        AppImages.iconTrash
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.bordered)
                    .padding(.leading)
                }
            }
        }
        .padding()
    }
    
    //MARK: - Private Functions
    
    private func dayButtonTupped(day: DayOfWeek) {
        guard !timetable.contains(where: { $0.day == day } ) else { return }
        let newWorkingDay = NewWorkingDay(day: day)
        withAnimation {
            timetable.append(newWorkingDay)
            timetable.sort(by: { $0.day.rawValue < $1.day.rawValue })
            days.removeAll(where: { $0 == day })
        }
    }
    
    private func deleteButtonTupped(day: NewWorkingDay) {
        guard let index = timetable.firstIndex(of: day) else { return }
        timetable.remove(at: index)
        days.append(day.day)
    }
}

#Preview {
    EditTimetableView(timetable: [NewWorkingDay(day: .friday)]) { timetable in
        print(timetable)
    }
}
