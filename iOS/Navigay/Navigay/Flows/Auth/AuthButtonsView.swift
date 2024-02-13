//
//  AuthButtonsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 12.02.24.
//

import SwiftUI

struct AuthButtonsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var authenticationManager: AuthenticationManager
    let onFinish: () -> Void
    
    // MARK: - Private Properties
    
    @State private var showLoginView = false
    @State private var showRegistrationView = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 10) {
            Button {
                showLoginView = true
            } label: {
                Text("Log In")
                    .font(.body)
                    .bold()
                    .padding(12)
                    .padding(.horizontal)
                    .background(AppColors.lightGray6)
                    .clipShape(Capsule())
            }
            .fullScreenCover(isPresented: $showLoginView) {
                LoginView(viewModel: LoginViewModel(), authenticationManager: authenticationManager) {
                    onFinish()
                }
            }
            
            Button {
                showRegistrationView = true
            } label: {
                Text("Registration")
                    .font(.body)
                    .bold()
                    .padding(12)
                    .padding(.horizontal)
                    .background(AppColors.lightGray6)
                    .clipShape(Capsule())
            }
            .fullScreenCover(isPresented: $showRegistrationView) {
                RegistrationView(viewModel: RegistrationViewModel(), authenticationManager: authenticationManager) {
                    onFinish()
                }
            }
            
            Button {
            } label: {
                HStack(spacing: 10) {
                    AppImages.iconGoogleG
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("Log In with Google")
                        .font(.body)
                        .bold()
                }
                .padding(12)
                .padding(.horizontal)
                .background(AppColors.lightGray6)
                .clipShape(Capsule())
                
            }
        }
    }
}

#Preview {
    AuthButtonsView(authenticationManager: AuthenticationManager(keychainManager: KeychainManager(), networkManager: AuthNetworkManager(appSettingsManager: AppSettingsManager(), errorManager: ErrorManager()), errorManager: ErrorManager())) {
        print("onFinish")
    }
}
