//
//  EditTimeView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import SwiftUI

struct EditTimeView: View {
    
    //MARK: - Properties
    
    var onSave: (Date) -> Void
    var onDelete: () -> Void
    
    //MARK: - Private Properties
    
    @State private var time: Date
    private let editType: EditDateType
    private let showDeleteInfo: Bool

    @Environment(\.dismiss) private var dismiss
    private var title: String {
            switch editType {
            case .start:
                return "Start time"
            case .finish:
                return "Finish time"
            }
        }
    
    //MARK: - Inits
    

    init(time: Date?, editType: EditDateType, onSave: @escaping (Date) -> Void, onDelete: @escaping () -> Void) {
        _time = State(initialValue: time ?? Date())
        self.editType = editType
        self.showDeleteInfo = time != nil ? true : false
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                DatePicker(
                    "startTime",
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                    .padding()
                Divider()
                if showDeleteInfo {
                    Button(role: .destructive) {
                        onDelete()
                        dismiss()
                    } label: {
                        Label(
                            title: { Text("Delete selected time") },
                            icon: { AppImages.iconTrash }
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .padding(.top)
                }
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
                    Button("Done") {
                        onSave(time)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

#Preview {
    EditTimeView(time: nil, editType: .start) { time in
        print(time)
    } onDelete: {
        print("delete")
    }

}
