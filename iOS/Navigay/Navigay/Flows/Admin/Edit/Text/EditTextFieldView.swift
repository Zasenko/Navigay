//
//  EditTextFieldView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 31.10.23.
//

import SwiftUI

struct EditTextFieldView: View {
    
    //MARK: - Properties
    
    var onSave: (String) -> Void
    
    //MARK: - Private Properties
    
    @State private var text: String
    private let characterLimit: Int
    private let minHaracters: Int
    private let title: String
    private let placeholder: String
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits
    
    init(text: String, characterLimit: Int, minHaracters: Int, title: String, placeholder: String?, onSave: @escaping (String) -> Void) {
        self._text = State(initialValue: text)
        self.characterLimit = characterLimit
        self.minHaracters = minHaracters
        self.title = title
        self.placeholder = placeholder ?? ""
        self.onSave = onSave
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                TextField(placeholder, text: $text)
                    .focused($focused)
                    .onChange(of: text, initial: true) { oldValue, newValue in
                        text = String(newValue.prefix(characterLimit))
                    }
                    .padding()
                Divider()
                    .padding(.bottom)
                Text(String(characterLimit - text.count))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing).padding(.horizontal)
                
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
                    Button("Готово") {
                        onSave(text)
                        dismiss()
                    }
                    .bold()
                    .disabled(text.count < minHaracters)
                }
            }
            .onAppear {
                focused = true
            }
        }
    }
}

#Preview {
    EditTextFieldView(text: "", characterLimit: 50, minHaracters: 2, title: "Name", placeholder: nil)  { string in
        print(string)
    }
}
