//
//  EditEventAdminView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.04.24.
//

import SwiftUI

struct EditEventAdminView: View {
    
    @ObservedObject private var viewModel: EditEventViewModel
    
    @State private var didApear: Bool = false
    
    @State private var isActive: Bool = false
    @State private var isChecked: Bool = false
    @State private var adminNotes: String = ""
    private let title: String = "Admin Panel"
    
    @State private var isLoading: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: EditEventViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            ActivationFieldsView(isActive: $isActive, isChecked: $isChecked)
                .padding(.vertical)
            Divider()
            NavigationLink {
                EditTextEditorView(title: "Notes", text: adminNotes, characterLimit: 3000, onSave: { string in
                    adminNotes = string
                })
            } label: {
                EditField(title: "Notes", text: $adminNotes, emptyFieldColor: .secondary)
                    .padding(.vertical)
            }
            .padding(.horizontal)
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
            if !didApear {
                isActive = viewModel.isActive
                isChecked = viewModel.isChecked
                adminNotes = viewModel.adminNotes
                didApear = true
            }
        }
    }
    
    //MARK: - Private Functions
    
    private func update() {
        isLoading = true
        Task {
            if await viewModel.updateActivity(isActive: isActive, isChecked: isChecked, adminNotes: adminNotes) {
                await MainActor.run {
                    dismiss()
                }
            } else {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}
