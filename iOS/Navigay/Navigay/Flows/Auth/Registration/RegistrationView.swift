//
//  RegistrationView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import SwiftUI

struct RegistrationView: View {
    
    // MARK: - Private Properties
    
    @StateObject private var viewModel: RegistrationViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FocusField?
    private enum FocusField: Hashable, CaseIterable {
        case email, password
    }
    
    // MARK: - Init
    
    init(viewModel: RegistrationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                ErrorView(viewModel: ErrorViewModel(errorManager: authenticationManager.errorManager), moveFrom: .top, alignment: .top)
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
            do {
                let decodedAppUser = try await authenticationManager.registration(email: viewModel.email, password: viewModel.password)
                
                await MainActor.run {
                    let user = AppUser(decodedUser: decodedAppUser)
                    user.isUserLoggedIn = true
                    authenticationManager.lastLoginnedUserId = user.id
                    authenticationManager.isUserOnline = true
                    context.insert(user)
                    authenticationManager.appUser = user
                    viewModel.isPresented = false
                }
                return
            } catch NetworkErrors.noConnection {
                authenticationManager.errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                authenticationManager.errorManager.showApiError(apiError: apiError, or: authenticationManager.errorManager.errorMessage, img: nil, color: nil)
            } catch {
                authenticationManager.errorManager.showError(model: ErrorModel(error: error, message: authenticationManager.errorManager.errorMessage, img: AppImages.iconPersonError, color: nil))
            }
            await MainActor.run {
                viewModel.allViewsDisabled = false
                viewModel.buttonState = .normal
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
