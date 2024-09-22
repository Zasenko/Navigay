//
//  EditPlaceTimetableView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 20.03.24.
//

import SwiftUI

struct EditPlaceTimetableView: View {
    
    @ObservedObject private var viewModel: EditPlaceViewModel
        
    @State private var days: [DayOfWeek] = DayOfWeek.allCases
    @State private var timetable: [NewWorkingDay] = []
    
    @State private var isLoading: Bool = false
    
    private let title: String = "Timetable"
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: EditPlaceViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
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
                if isLoading {
                    ProgressView()
                        .tint(.blue)
                } else {
                    Button("Save") {
                        update()
                    }
                    .bold()
                    .disabled(isLoading)
                }
            }
        }
        .onAppear() {
            timetable = viewModel.timetable
            days.removeAll { dayOfWeek in
                if timetable.contains(where: { $0.day == dayOfWeek } ) {
                    true
                } else {
                    false
                }
            }
        }
    }
    
    //MARK: - Private Functions
    
    private func update() {
        isLoading = true
        Task {
            if await viewModel.updateTimetable(timetable: timetable) {
                await MainActor.run {
                    dismiss()
                }
            }
            await MainActor.run {
                isLoading = false
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

//#Preview {
//    let errorManager: ErrorManagerProtocol = ErrorManager()
//    let decodetUser = DecodedAppUser(id: 0, name: "", email: "", status: .admin, sessionKey: "", bio: "", photo: "")
//    let user = AppUser(decodedUser: decodetUser)
//    return EditPlaceTimetableView(viewModel: EditPlaceViewModel(id: 122, place: nil, user: user, networkManager: EditPlaceNetworkManager(networkMonitorManager: NetworkMonitorManager(errorManager: errorManager)), errorManager: errorManager))
//}
