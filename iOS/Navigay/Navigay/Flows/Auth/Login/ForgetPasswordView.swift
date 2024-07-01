//
//  ForgetPasswordView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.03.24.
//

import SwiftUI

struct ForgetPasswordView: View {
    //MARK: - Properties
    
    var onSave: (String) -> Void
    
    //MARK: - Private Properties
    
    @State private var email: String
    
    private let title: String = "Forgot your password?"
    private let placeholder: String = "Email"
    private let info: String = "Please enter your email address below, and we'll send you a link to reset your password."
    @State private var isEmailValid: Bool = false
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    
    @State private var showResetPasswordView = false
    //MARK: - Inits
    
    init(email: String, onSave: @escaping (String) -> Void) {
        self._email = State(initialValue: email)
        self.onSave = onSave
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                        .onAppear {
                            focused = true
                        }
                    Divider()
                    Text(info)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                        .padding()
                    Spacer()
                }
                ErrorView(viewModel: ErrorViewModel(errorManager: authenticationManager.errorManager), moveFrom: .top, alignment: .top)
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
                    Button("Submit") {
                        Task {
                            let result = await authenticationManager.resetPassword(email: email)
                            if result {
                                await MainActor.run {
                                    showResetPasswordView.toggle()
                                }
                            }
                        }
                    }
                    .bold()
                    .disabled(isEmailValid)
                }
            }
            .sheet(isPresented: $showResetPasswordView, onDismiss: {
                onSave(email)
                dismiss()
            }, content: {
                ResetPasswordMessageView(email: email)
                    .background(AppColors.lightGray5)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(25)
            })
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

//#Preview {
//    ForgetPasswordView(email: "") { string in
//        print(string)
//    }
//}
