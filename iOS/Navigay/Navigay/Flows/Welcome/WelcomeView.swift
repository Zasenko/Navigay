//
//  WelcomeView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.02.24.
//

import SwiftUI

struct WelcomeView: View {
    
    // MARK: - Properties
    
    @Binding var firstTimeInApp: Bool
    
    // MARK: - Private Properties
    
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.colorScheme) private var deviceColorScheme
    @State private var showLoginView = false
    @State private var showRegistrationView = false
    @State private var showPartnerRegistrationView = false
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
                authButton(img: AppImages.iconArrowRight, text: "Log In")
            }
            .fullScreenCover(isPresented: $showLoginView) {
                LoginView(viewModel: LoginViewModel(isPresented: $firstTimeInApp))
            }
            Button {
                showRegistrationView = true
            } label: {
                authButton(img: AppImages.iconPlus, text: "Registration")
            }
            .fullScreenCover(isPresented: $showRegistrationView) {
                RegistrationView(viewModel: RegistrationViewModel(isPresented: $firstTimeInApp))
            }
            Spacer()
            Button {
                showPartnerRegistrationView = true
            } label: {
                authButton(img: AppImages.iconPartnersRegistrations, text: "For Partners")
            }
            .fullScreenCover(isPresented: $showPartnerRegistrationView) {
                PartnerRegistrationView(viewModel: PartnerRegistrationViewModel(isPresented: $firstTimeInApp))
            }
            Spacer()
            Button {
                firstTimeInApp = false
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
        .frame(maxWidth: 200)
    }
    
    private func authButton(img: Image, text: String) -> some View {
        HStack(spacing: 10) {
            img
                .foregroundStyle(.secondary)
            Text(text)
                .frame(maxWidth: .infinity)
            
        }
        .font(.body)
        .bold()
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .foregroundStyle(deviceColorScheme == .light ? .blue : .white)
    }
}

#Preview {
    let errorManager: ErrorManagerProtocol = ErrorManager()
    let keychainManager: KeychainManagerProtocol = KeychainManager()
    let appSettingsManager: AppSettingsManagerProtocol = AppSettingsManager()
    let networkMonitorManager: NetworkMonitorManagerProtocol = NetworkMonitorManager(errorManager: errorManager)
    let networkManager = NetworkManager(session: URLSession.shared, networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager, keychainManager: keychainManager)
    let authNetworkManager = AuthNetworkManager(networkManager: networkManager)
    var authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: networkManager, authNetworkManager: authNetworkManager, errorManager: errorManager)
    return WelcomeView(firstTimeInApp: .constant(true))
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
