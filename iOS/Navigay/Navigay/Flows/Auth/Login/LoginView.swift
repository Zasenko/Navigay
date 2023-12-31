//
//  LoginView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    
    private enum FocusField: Hashable, CaseIterable {
        case email, password
    }
    
    // MARK: - Properties
    
    @StateObject var viewModel: LoginViewModel
    @ObservedObject var authenticationManager: AuthenticationManager
    
    let onDismiss: () -> Void
    
    // MARK: - Private Properties
    
    @Environment(\.modelContext) private var context
    
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FocusField?
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AppColors.background
            authView
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            focusedField = nil
        }
        .onSubmit(focusNextField)
        .disabled(viewModel.allViewsDisabled)
        .navigationBarBackButtonHidden()
        .toolbarBackground(AppColors.background)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation {
                        focusedField = nil
                        dismiss()
                    }
                } label: {
                    AppImages.iconLeft
                        .bold()
                        .frame(width: 30, height: 30, alignment: .leading)
                }
                .tint(.primary)
            }
        }
        .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
            .onEnded { value in
                switch(value.translation.width, value.translation.height) {
                    case (0..., -30...30):
                    dismiss()
                    default:  break
                }
            }
        )
    }
    
    // MARK: - Views

    var authView: some View {
        VStack {
            Spacer()
            Text("Sign in\nto your Account")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .lineSpacing(0)
            Spacer()
            emailView
                .padding(.bottom,10)
            passwordView
                .padding(.bottom,10)
            Spacer()
            loginButtonView
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
                  //  authenticationManager.checkEmail(email: viewModel.email)
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
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .onTapGesture {
            focusedField = .email
        }
    }
    
    var passwordView: some View {
        VStack {
            HStack {
                VStack(spacing: 0) {
                    HStack {
                        Text("Password")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    SecureField("", text: $viewModel.password) {
                     //   authenticationManager.checkPassword(password: viewModel.password)
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
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .onTapGesture {
                focusedField = .password
            }
            HStack {
                Text("Forgot your password?")
                    .foregroundColor(.secondary)
                Button("Reset") {
                    //TODO!
                }
                .bold()
            }
            .font(.footnote)
//            .padding(.top, 20)
            .padding()
        }
    }
    
    var loginButtonView: some View {
        Button {
            loginButtonTapped()
        } label: {
            HStack {
                Text("Sign in")
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
        .disabled(!viewModel.isButtonValid)
        .padding()
    }
    
    // MARK: - Private Functions
    
    @MainActor
    private func loginButtonTapped() {
        focusedField = nil
        viewModel.allViewsDisabled = true
        viewModel.buttonState = .loading
        Task {
            let decodedUser = await authenticationManager.login(email: viewModel.email, password: viewModel.password)
            guard let decodedUser else {
                viewModel.allViewsDisabled = false
                viewModel.buttonState = .normal
                return
            }
            
            do {
                let descriptor = FetchDescriptor(predicate: #Predicate<AppUser>{ $0.id == decodedUser.id })
                
                if let user = try context.fetch(descriptor).first {
                    user.isUserLoggedIn = true
                    user.updateUser(decodedUser: decodedUser)
                    authenticationManager.appUser = user
                } else {
                    let user = AppUser(decodedUser: decodedUser)
                    user.isUserLoggedIn = true
                    authenticationManager.appUser = user
                    context.insert(user)
                }
                onDismiss()
                
            } catch {
                viewModel.allViewsDisabled = false
                viewModel.buttonState = .normal
                print("Fetch failed")
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

#Preview {
    let viewModel = LoginViewModel(email: nil)
    let keychainManager = KeychainManager()
    let appSettingsManager = AppSettingsManager()
    let networkManager = AuthNetworkManager(appSettingsManager: appSettingsManager)
    let errorManager = ErrorManager()
    let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkManager: networkManager, errorManager: errorManager)
    return LoginView(viewModel: viewModel, authenticationManager: authenticationManager) {
        print("dissmised")
    }
}
