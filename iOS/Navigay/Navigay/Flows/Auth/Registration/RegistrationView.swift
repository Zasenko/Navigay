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
    
    @Environment(\.modelContext) private var context
    
    @StateObject var viewModel: RegistrationViewModel = RegistrationViewModel()
    @ObservedObject var authenticationManager: AuthenticationManager
    
   // let showSkip: Bool
    let onDismiss: () -> Void
    
    // MARK: - Private Properties
    
    @FocusState private var focusedField: FocusField?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                VStack {
                    skipView
                    authView
                    signInView
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                focusedField = nil
            }
            .onSubmit(focusNextField)
            .disabled(viewModel.allViewsDisabled)
        }
    }
    
    // MARK: - Views
    
    var skipView: some View {
        HStack {
            Spacer()
            Button {
                focusedField = nil
                onDismiss()
            } label: {
                HStack {
                 //   if showSkip {
                        Text("skip")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                 //   }
                    AppImages.iconX
                        .font(.title2)
                        .bold()
                }
            }
            .padding()
        }
        
    }
    
    var authView: some View {
        VStack {
            Spacer()
            Text("Create Account")
            .font(.largeTitle)
            .bold()
            Spacer()
            emailView
                .padding(.bottom, 8)
            passwordView
                .padding(.bottom, 8)
            Spacer()
            registrationButtonView
            Spacer()
            
        }
        .padding()
        .frame(maxWidth: 400)
    }
    
    var emailView: some View {
        HStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
//            Text("The password must consist of at least 8 characters, at least one number and one letter.")
//                .foregroundColor(.secondary)
//                .font(.caption)
//                .multilineTextAlignment(.center)
//                .padding()
        }
    }
    
    var registrationButtonView: some View {
        Button {
            registrationButtonTapped()
        } label: {
            HStack {
                Text("Login")
                    .foregroundColor(viewModel.isButtonValid ? AppColors.lightGray5 : .black)
                switch viewModel.buttonState {
                case .normal, .success, .failure:
                    AppImages.iconArrowRight
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .frame(width: 20, height: 20)
                        .foregroundColor(viewModel.isButtonValid ? AppColors.lightGray5 : .black)
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
        .disabled(!viewModel.isButtonValid)


    }
    
    var signInView: some View {
        HStack {
            Text("Already a member?")
            
            NavigationLink {
//                LoginView(viewModel: LoginViewModel(), authenticationManager: authenticationManager) {
//                    onDismiss()
//                }
            } label: {
                Text("Sign In")
                .bold()
                .foregroundColor(.blue)
            }
        }
        .font(.subheadline)
        .padding()
    }
    
    // MARK: - Private Functions
    
    @MainActor
    private func registrationButtonTapped() {
        focusedField = nil
        viewModel.allViewsDisabled = true
        viewModel.buttonState = .loading
        Task {
            if let user = await authenticationManager.registration(email: viewModel.email, password: viewModel.password) {
                context.insert(user)
                onDismiss()
            } else{
                viewModel.allViewsDisabled = false
                viewModel.buttonState = .normal
                print("no")
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
//    RegistrationView(authenticationManager: AuthenticationManager(keychainManager: <#T##KeychainManagerProtocol#>, networkManager: <#T##AuthNetworkManagerProtocol#>, errorManager: <#T##ErrorManagerProtocol#>), onDismiss: <#() -> Void#>)
//}
