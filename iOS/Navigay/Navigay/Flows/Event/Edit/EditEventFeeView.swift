//
//  EditEventFeeView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 11.04.24.
//

import SwiftUI

struct EditEventFeeView: View {
    
    @ObservedObject private var viewModel: EditEventViewModel
    
    @State private var didApear: Bool = false
    
    @State private var isFree: Bool = false
    @State private var fee: String = ""
    @State private var tickets: String = ""
    
    private let title: String = "Fee"
    
    @State private var isLoading: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: EditEventViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            ScrollView {
                EventFeeFieldsView(isFree: $isFree, fee: $fee, tickets: $tickets)
                    .padding(.vertical)
            }
            .scrollIndicators(.hidden)
            
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
                }
            }
        }
        .onAppear() {
            if !didApear {
                isFree = viewModel.isFree
                fee = viewModel.fee
                tickets = viewModel.tickets
                didApear = true
            }
        }
    }
    
    //MARK: - Private Functions
    
    private func update() {
        isLoading = true
        Task {
            if await viewModel.updateFee(isFree: isFree, fee: fee.isEmpty ? nil : fee, tickets: tickets.isEmpty ? nil : tickets) {
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

//#Preview {
//    EditEventFeeView()
//}
