//
//  WorkingDayRow.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 24.10.23.
//

import SwiftUI

struct WorkingDayRow: View {
    
    //MARK: - Properties
    
    @Binding var day: NewWorkingDay
    var onDelete: () -> Void
    
    //MARK: - Body
    
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
