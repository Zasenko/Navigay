//
//  RegistrationView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import SwiftUI

struct RegistrationView: View {
    
    private enum FocusField: Hashable, CaseIterable {
        case email, password
    }
    
    // MARK: - Properties
    
    @StateObject var viewModel: RegistrationViewModel = RegistrationViewModel()
    @ObservedObject var authenticationManager: AuthenticationManager
    let errorManager: ErrorManagerProtocol
    let onDismiss: () -> Void
    
    // MARK: - Private Properties
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FocusField?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                listView
                    .navigationBarBackButtonHidden()
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .toolbarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                focusedField = nil
                                dismiss()
                            } label: {
                                AppImages.iconX
                                    .bold()
                                    .frame(width: 30, height: 30)
                            }
                            .tint(.primary)
                        }
                    }
                ErrorView(viewModel: ErrorViewModel(errorManager: errorManager), edge: .top)
            }
        }
    }
    
    // MARK: - Views
    
    private var listView: some View {
        List {
            Text("Create Account")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
                .listRowSeparator(.hidden)
            
            VStack {
                VStack(spacing: 20) {
                    emailView
                    passwordView
                }
                .frame(maxWidth: 400)
            }
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
            
            registrationButtonView
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .buttonStyle(.plain)
        .scrollIndicators(.hidden)
        .onTapGesture {
            focusedField = nil
        }
        .onSubmit(focusNextField)
        .disabled(viewModel.allViewsDisabled)
    }
    
    var emailView: some View {
        HStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Email")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                TextField("", text: $viewModel.email) {
               //     authenticationManager.checkEmail(email: viewModel.email)
                }
                .font(.body)
                .bold()
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .lineLimit(1)
                .focused($focusedField, equals: .email)
            }
            AppImages.iconEnvelope
                .font(.callout)
                .foregroundColor(.secondary)
                .bold()
        }
        .padding(10)
        .padding(.horizontal, 10)
        .background(AppColors.lightGray6)
        .cornerRadius(16)
        .onTapGesture {
            focusedField = .email
        }
    }
    
    var passwordView: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(spacing: 0) {
                    HStack {
                        Text("Password")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    SecureField("", text: $viewModel.password) {
                       // authenticationManager.checkPassword(password: viewModel.password)
                    }
                    .font(.body)
                    .bold()
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .lineLimit(1)
                    .focused($focusedField, equals: .password)
                }
                AppImages.iconLock
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .bold()
            }
            .padding(10)
            .padding(.horizontal, 10)
            .background(AppColors.lightGray6)
            .cornerRadius(16)
            .onTapGesture {
                focusedField = .password
            }
            Text("The password must consist of at least 8 characters, at least one number and one letter.")
                .foregroundColor(.secondary)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
    
    var registrationButtonView: some View {
        Button {
            registrationButtonTapped()
        } label: {
            HStack {
                Text("Login")
                    .foregroundColor(viewModel.isButtonValid ? .white : .secondary)
                switch viewModel.buttonState {
                case .normal, .success, .failure:
                    AppImages.iconArrowRight
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .frame(width: 20, height: 20)
                        .foregroundColor(viewModel.isButtonValid ? .white : .secondary)
                case .loading:
                    ProgressView()
                        .frame(width: 20, height: 20)
                }
            }
            .font(.title3)
            .bold()
            .padding(12)
            .padding(.horizontal)
            .background(viewModel.isButtonValid ? .green : AppColors.lightGray5)
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .disabled(!viewModel.isButtonValid)
    }
        
    // MARK: - Private Functions
    
    @MainActor
    private func registrationButtonTapped() {
        focusedField = nil
        viewModel.allViewsDisabled = true
        viewModel.buttonState = .loading
        Task {
            let error = ErrorModel(massage: "Что-то пошло не так. Повтарите попытку позже.", img: AppImages.iconPersonError, color: .red)
            do {
                let appUser = try await authenticationManager.registration(email: viewModel.email, password: viewModel.password)
                context.insert(appUser)
                onDismiss()
            } catch NetworkErrors.apiError(let apiError) {
                viewModel.allViewsDisabled = false
                viewModel.buttonState = .normal
                errorManager.showApiErrorOrMessage(apiError: apiError, or: error)
            } catch NetworkErrors.noConnection {
                viewModel.allViewsDisabled = false
                viewModel.buttonState = .normal
            } catch {
                viewModel.allViewsDisabled = false
                viewModel.buttonState = .normal
                errorManager.showError(error: error)
            }
        }
    }
    
    private func focusNextField() {
        switch focusedField {
        case .email:
            if viewModel.password.isEmpty {
                focusedField = .password
            } else {
                focusedField = nil
            }
        case .password:
            if viewModel.email.isEmpty {
                focusedField = .email
            } else {
                focusedField = nil
            }
        case .none:
            break
        }
    }
    
    private func checkEmptyFields() -> Bool {
        if viewModel.email.isEmpty {
            focusedField = .email
            return false
        } else if viewModel.password.isEmpty {
            focusedField = .password
            return false
        } else {
            focusedField = nil
            return true
        }
    }
}

//#Preview {
//    let viewModel = RegistrationViewModel()
//    let keychainManager = KeychainManager()
//    let appSettingsManager = AppSettingsManager()
//    let networkManager = AuthNetworkManager(appSettingsManager: appSettingsManager)
//    let errorManager = ErrorManager()
//    let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkManager: networkManager, errorManager: errorManager)
//    return RegistrationView(viewModel: viewModel, authenticationManager: authenticationManager) {
//        print("dissmised")
//    }
//}
