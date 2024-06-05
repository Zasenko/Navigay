//
//  WelcomeView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.02.24.
//

import SwiftUI

struct WelcomeView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.colorScheme) private var deviceColorScheme
    let onFinish: () -> Void
    
    // MARK: - Private Properties
    
    @State private var showLoginView = false
    @State private var showRegistrationView = false
    
    // MARK: - Init
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 0) {
                Text("Welcome to")
                    .font(.title2).bold()
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
                    Text("skip")
                       
                }
            }
            .foregroundStyle(deviceColorScheme == .light ? .primary : .primary)
            .font(.subheadline)
        }
        .background {
            ZStack(alignment: .center) {
                Image("bg2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .scaleEffect(CGSize(width: 2, height: 2))
                    .blur(radius: 100)
                    .saturation(3)
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
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
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .foregroundStyle(deviceColorScheme == .light ? .blue : .white)
            }
            
            .fullScreenCover(isPresented: $showLoginView) {
                LoginView(viewModel: LoginViewModel()) {
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
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .foregroundStyle(deviceColorScheme == .light ? .blue : .white)
            }
            .fullScreenCover(isPresented: $showRegistrationView) {
                RegistrationView(viewModel: RegistrationViewModel(), authenticationManager: authenticationManager, errorManager: authenticationManager.errorManager) {
                    onFinish()
                }
            }
        }
    }
}

#Preview {
    let errorManager: ErrorManagerProtocol = ErrorManager()
    let appSettingsManager: AppSettingsManagerProtocol = AppSettingsManager()
    let networkMonitorManager: NetworkMonitorManagerProtocol = NetworkMonitorManager(errorManager: errorManager)
    
    let keychainManager: KeychainManagerProtocol = KeychainManager()
    
    let authNetworkManager = AuthNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
    
    let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: authNetworkManager, errorManager: errorManager)
   return WelcomeView(onFinish: {
       print("on Finish")
    })
   .environmentObject(authenticationManager)
}

/// Google button
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
