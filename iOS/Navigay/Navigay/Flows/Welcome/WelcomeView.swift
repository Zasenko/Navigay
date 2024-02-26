//
//  WelcomeView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.02.24.
//

import SwiftUI

struct WelcomeView: View {
    
    // MARK: - Properties
    
    @ObservedObject var authenticationManager: AuthenticationManager
    let onFinish: () -> Void
    
    // MARK: - Private Properties
    
    @State private var showLoginView = false
    @State private var showRegistrationView = false
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 0) {
                Text("Welcome to")
                    .font(.title2)
                    .fontWeight(.light)
                
                AppImages.logoFull
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
            }
            .padding(.vertical, 100)
            
            authButtonsView
            
            Spacer()
            
            Button {
                onFinish()
            } label: {
                HStack(spacing: 0) {
                    AppImages.iconX
                        .bold()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.primary)
                    Text("skip")
                    
                        .font(.subheadline)
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var authButtonsView: some View {
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
                LoginView(viewModel: LoginViewModel(), authenticationManager: authenticationManager, errorManager: authenticationManager.errorManager) {
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
                RegistrationView(viewModel: RegistrationViewModel(), authenticationManager: authenticationManager, errorManager: authenticationManager.errorManager) {
                    onFinish()
                }
            }
            
//            Button {
//            } label: {
//                HStack(spacing: 10) {
//                    AppImages.iconGoogleG
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 20, height: 20)
//                    Text("Log In with Google")
//                        .font(.body)
//                        .bold()
//                }
//                .padding(12)
//                .padding(.horizontal)
//                .background(AppColors.lightGray6)
//                .clipShape(Capsule())
//            }
        }
    }
}

//#Preview {
//    WelcomeView()
//}
