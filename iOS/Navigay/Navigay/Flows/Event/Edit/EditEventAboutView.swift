//
//  EditEventAboutView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 18.01.24.
//

import SwiftUI

struct EditEventAboutView: View {
    
    //MARK: - Private Properties
    
    @ObservedObject private var viewModel: EditEventViewModel
    
    @State private var isLoading: Bool = false
    @State private var about: String = ""
    
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss
    
    private let title: String = "Information"
    private let characterLimit: Int = 3000
    
    //MARK: - Inits

    init(viewModel: EditEventViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            Divider()
            TextEditor(text: $about)
                .font(.body)
                .lineSpacing(5)
                .padding(.horizontal, 10)
                .focused($focused)
                .onChange(of: about, initial: true) { oldValue, newValue in
                    about = String(newValue.prefix(characterLimit))
                }
            Text(String(characterLimit - about.count))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal)
                .padding(.bottom)
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
        .onAppear {
            focused = true
            self.about = viewModel.about
        }
    }
    
    // MARK: - Private Functions
    
    private func update() {
        isLoading = true
        focused = false
        Task {
            if await viewModel.updateAbout(about: about) {
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
//    EditEventAboutView()
//}
