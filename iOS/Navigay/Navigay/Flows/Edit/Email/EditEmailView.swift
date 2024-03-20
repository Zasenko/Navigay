//
//  EditEmailView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.10.23.
//

import SwiftUI

struct EditEmailView: View {
    
    //MARK: - Properties
    
    var onSave: (String) -> Void
    
    //MARK: - Private Properties
    
    @State private var email: String
    private let title: String = "Email"
    private let placeholder: String = "example@example.com"
    private let info: String = "The email will not be visible to application users."
    @State private var isEmailValid: Bool = false
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits
    
    init(email: String, onSave: @escaping (String) -> Void) {
        self._email = State(initialValue: email)
        self.onSave = onSave
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                TextField(placeholder, text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .focused($focused)
                    .onChange(of: email, initial: true) { oldValue, newValue in
                        isEmailValid = checkEmail(email: newValue)
                    }
                    .padding()
                Divider()
                Text(info)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                .padding()
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
                        onSave(email)
                        dismiss()
                    }
                    .bold()
                    .disabled(isEmailValid)
                }
            }
            .onAppear {
                focused = true
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func checkEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailPred.evaluate(with: email) {
            return false
        } else {
            return true
        }
    }
}

#Preview {
    EditEmailView(email: "") { string in
        print(string)
    }
}
