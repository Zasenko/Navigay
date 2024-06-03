//
//  ReportView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.06.24.
//

import SwiftUI

struct ReportView: View {
    
    // MARK: - Properties
    
    @StateObject var viewModel: ReportViewModel
    var onSave: () -> Void

    // MARK: - Private Properties
    
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Init
    
    init(viewModel: ReportViewModel, onSave: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSave = onSave
    }
    
    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Group {
                    Divider()
                    Text("Please select a reason for the report.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    VStack(spacing: 10) {
                        ForEach(viewModel.reasons, id: \.self) { reasons in
                            createReasonView(reason: reasons)
                        }
                    }
                    .padding(.bottom)
                }
                .background(AppColors.background)
                .onTapGesture {
                    focused = false
                }
                Divider()
                TextEditor(text: $viewModel.text)
                    .font(.body)
                    .lineSpacing(5)
                    .overlay(alignment: .topLeading) {
                        if !focused && viewModel.text.isEmpty {
                            Text("Describe the issue...")
                                .padding(.top, 10)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 10)
                    .focused($focused)
                    .disabled(viewModel.text.count > viewModel.characterLimit)
                    .onChange(of: viewModel.text, initial: true) { oldValue, newValue in
                        viewModel.text = String(newValue.prefix(viewModel.characterLimit))
                    }
                if focused {
                    Text(String(viewModel.characterLimit - viewModel.text.count))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing).padding(.horizontal)
                }
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Report")
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
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button("Send") {
                            focused = false
                            viewModel.sendReport()
                        }
                        .bold()
                        .disabled(viewModel.reason == nil)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isAdded) {
                onSave()
                dismiss()
            } content: {
                createAddedMessageView()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(25)
            }
        }
    }
    
    // MARK: - Views
        
    private func createAddedMessageView() -> some View {
        VStack {
            Capsule()
                .fill(.ultraThinMaterial)
                .frame(width: 40, height: 5)
                .padding()
            VStack {
                AppImages.iconCheckmark
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
                    .padding()
                Text("Your report has been submitted successfully. Thank you for your contribution!")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding()
                    .textSelection(.enabled)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(AppColors.lightGray3)
    }

    private func createReasonView(reason: ReportReason) -> some View {
        HStack {
            Image(systemName: viewModel.reason == reason ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(viewModel.reason == reason ? .blue : Color.secondary)
            Text(reason.getText())
                .padding(.leading)
                .font(.body)
            Spacer()
        }
        .padding(.horizontal)
        .onTapGesture {
            viewModel.reason = reason
        }
    }
}

#Preview {
    let errorManager = ErrorManager()
    let networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
    let networkManager = ReportNetworkManager(networkMonitorManager: networkMonitorManager)
    
    let viewModel = ReportViewModel(item: .comment, itemId: 1, reasons: [.inappropriateContent, .misleadingInformation, .spam, .other], user: nil, networkManager: networkManager, errorManager: errorManager)
   // viewModel.isAdded = true
   // viewModel.isLoading = true
    return ReportView(viewModel: viewModel, onSave: {
        
    })
}


