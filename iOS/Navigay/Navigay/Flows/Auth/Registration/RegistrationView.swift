//
//  RegistrationView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import SwiftUI

struct RegistrationView: View {
    
    // MARK: - Private Properties
    
    private enum FocusField: Hashable, CaseIterable {
        case email, password
    }
    
    @FocusState private var focusedField: FocusField?
    @StateObject private var viewModel: RegistrationViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

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
                        .padding(.bottom)
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
        .disabled(viewModel.allViewsDisabled)
    }
    
    private var emailView: some View {
        HStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Email")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                TextField("", text: $viewModel.email)
                    .font(.body)
                    .bold()
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .lineLimit(1)
                    .focused($focusedField, equals: .email)
                    .onChange(of: viewModel.email) { _, newValue in
                        Task {
                            await viewModel.validateEmail()
                        }
                    }
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
    
    private var passwordView: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(spacing: 0) {
                    HStack {
                        Text("Password")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    SecureField("", text: $viewModel.password)
                        .font(.body)
                        .bold()
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .lineLimit(1)
                        .focused($focusedField, equals: .password)
                        .onChange(of: viewModel.password) { _, newValue in
                            Task {
                                await viewModel.validatePassword()
                            }
                        }
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
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    AppImages.iconCheckmark
                        .opacity(viewModel.isPasswordCountValid ? 1 : 0)

                    Text("At least 8 characters")
                }
                .foregroundColor(viewModel.isPasswordCountValid ? .green : .secondary)

                HStack(alignment: .firstTextBaseline) {
                    AppImages.iconCheckmark
                        .opacity(viewModel.isPasswordNumberValid ? 1 : 0)

                    Text("At least one number")
                }
                .foregroundColor(viewModel.isPasswordNumberValid ? .green : .secondary)

                HStack(alignment: .firstTextBaseline) {
                    AppImages.iconCheckmark
                        .opacity(viewModel.isPasswordLetterValid ? 1 : 0)
                    Text("At least one letter")
                    
                }
                .foregroundColor(viewModel.isPasswordLetterValid ? .green : .secondary)

            }
            .font(.footnote)
            .multilineTextAlignment(.leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
        
    private var registrationButtonView: some View {
        Button {
            registrationButtonTapped()
        } label: {
            HStack {
                Text("Login")
                    .foregroundColor(viewModel.isFormValid ? .white : .secondary)
                switch viewModel.buttonState {
                case .normal, .success, .failure:
                    AppImages.iconArrowRight
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .frame(width: 20, height: 20)
                        .foregroundColor(viewModel.isFormValid ? .white : .secondary)
                case .loading:
                    ProgressView()
                        .frame(width: 20, height: 20)
                }
            }
            .font(.title3)
            .bold()
            .padding(12)
            .padding(.horizontal)
            .background(viewModel.isFormValid ? .green : AppColors.lightGray5)
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .disabled(!viewModel.isFormValid)
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
}
//
//#Preview {
//    let viewModel = RegistrationViewModel(isPresented: .constant(true))
//    
//    let errorManager = ErrorManager()
//    let keychainManager = KeychainManager()
//    let appSettingsManager = AppSettingsManager()
//    let networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
//    let networkManager = NetworkManager(session: URLSession.shared, networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager, keychainManager: keychainManager)
//    let authNetworkManager = AuthNetworkManager(networkManager: networkManager)
//    let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: networkManager, authNetworkManager: authNetworkManager, errorManager: errorManager)
//    return RegistrationView(viewModel: viewModel)
//        .environmentObject(authenticationManager)
//        .modelContainer(sharedModelContainer)
//}
//
//var sharedModelContainer: ModelContainer = {
//    let schema = Schema([
//        AppUser.self, Country.self, Region.self, City.self, Event.self, Place.self, User.self
//    ])
//    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//    
//    do {
//        return try ModelContainer(for: schema, configurations: [modelConfiguration])
//    } catch {
//        fatalError("Could not create ModelContainer: \(error)")
//    }
//}()
