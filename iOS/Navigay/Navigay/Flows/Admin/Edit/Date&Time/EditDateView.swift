//
//  EditDateView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import SwiftUI

struct EditDateView: View {
    
    //MARK: - Properties
    
    var onSave: (Date) -> Void
    var onDelete: () -> Void
    
    //MARK: - Private Properties
    
    @State private var date: Date
    private let pickerStartDay: Date
    private let editType: EditDateType
    private let showDeleteInfo: Bool

    @Environment(\.dismiss) private var dismiss
    private var title: String {
            switch editType {
            case .start:
                return "Start date"
            case .finish:
                return "Finish date"
            }
        }
    
    //MARK: - Inits
    

    init(date: Date?, pickerStartDate: Date?, editType: EditDateType, onSave: @escaping (Date) -> Void, onDelete: @escaping () -> Void) {
        _date = State(initialValue: date ?? Date())
        self.pickerStartDay = pickerStartDate ?? Date()
        self.editType = editType
        self.showDeleteInfo = date != nil && editType == .finish ? true : false
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                DatePicker("Pick a date",
                           selection: $date,
                           in: pickerStartDay...,
                           displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
                Divider()
                if showDeleteInfo {
                    Button(role: .destructive) {
                        onDelete()
                        dismiss()
                    } label: {
                        Label(
                            title: { Text("Delete selected date") },
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
                        onSave(date)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

#Preview {
    EditDateView(date: .now, pickerStartDate: .now.nextDay!, editType: .finish) { date in
        print(date)
    } onDelete: {
        print("delete")
    }
}
