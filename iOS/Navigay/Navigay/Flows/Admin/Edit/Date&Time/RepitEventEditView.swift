//
//  RepitEventEditView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 28.02.24.
//

import SwiftUI

struct RepitEventEditView: View {
    
    //MARK: - Properties
    
    var onSave: (EventTime) -> Void
    var onDelete: (EventTime) -> Void
    
    //MARK: - Private Properties
    
    @State private var eventTime: EventTime
    
    @Environment(\.dismiss) private var dismiss
    

    //MARK: - Inits
    
    init(eventTime: EventTime, onSave: @escaping (EventTime) -> Void, onDelete: @escaping (EventTime) -> Void) {
        _eventTime = State(initialValue: eventTime)
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                
                EventTimeFieldsView(startDate: $eventTime.startDate, startTime: $eventTime.startTime, finishDate: $eventTime.finishDate, finishTime: $eventTime.finishTime)
                Button {
                    onDelete(eventTime)
                    dismiss()
                } label: {
                    Text("Delete")
                }

                Spacer()
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Event Time")
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
                        onSave(eventTime)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

//#Preview {
//    RepitEventEditView(eventTime: EventTime(), onSave: { _ in print("Save") }, onDelete: { _ in print("Delete") })
//}
