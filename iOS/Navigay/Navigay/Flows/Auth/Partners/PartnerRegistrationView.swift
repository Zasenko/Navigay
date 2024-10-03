//
//  PartnerRegistrationView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.10.24.
//

import SwiftUI

struct PartnerRegistrationView: View {
    
    // MARK: - Private Properties
    
    private enum FocusField: Hashable, CaseIterable {
        case email, password
    }
    
    @FocusState private var focusedField: FocusField?
    @StateObject private var viewModel: PartnerRegistrationViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Namespace private var namespace
    
    // MARK: - Init
    
    init(viewModel: PartnerRegistrationViewModel) {
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
        GeometryReader { proxy in
            ScrollView {
                LazyVStack {
                    Text("Partner Registration")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                    VStack {
                        VStack(spacing: 20) {
                            emailView
                            passwordView
                            typeView(proxy: proxy)
                                .padding(.bottom)
                        }
                        .frame(maxWidth: 400)
                    }
                    .frame(maxWidth: .infinity)
                    registrationButtonView
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .onTapGesture {
                focusedField = nil
            }
            .disabled(viewModel.allViewsDisabled)
        }
    }
    
    private func typeView(proxy: GeometryProxy) -> some View {
        VStack {
            Text("Partner type")
                .font(.caption).bold()
                .foregroundColor(.secondary)
            HStack {
                ZStack {
                    if viewModel.type == .location {
                        Color.green
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .clipShape(Capsule())
                            .matchedGeometryEffect(id: "type", in: namespace)
                    }
                    Button {
                        focusedField = nil
                        if viewModel.type == .location {
                            withAnimation {
                                viewModel.type = .organizer
                            }
                        } else {
                            withAnimation {
                                viewModel.type = .location
                            }
                        }
                    } label: {
                        Text("Location")
                            .foregroundStyle(viewModel.type == .location ? .primary : .secondary)
                            .font(.body)
                            .bold()
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                ZStack {
                    if viewModel.type == .organizer {
                        Color.green
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .clipShape(Capsule())
                            .matchedGeometryEffect(id: "type", in: namespace)
                    }
                    Button {
                        focusedField = nil
                        if viewModel.type == .location {
                            withAnimation {
                                viewModel.type = .organizer
                            }
                        } else {
                            withAnimation {
                                viewModel.type = .location
                            }
                        }
                    } label: {
                        Text("Event Organizer")
                            .foregroundStyle(viewModel.type == .organizer ? .primary : .secondary)
                            .font(.body)
                            .bold()
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .background(AppColors.lightGray6)
            .clipShape(Capsule())
            
            ZStack(alignment: .topLeading) {
                Text("Create your unique page for your location. Provide the address, hours of operation, and other essential details. You will also have the option to add events hosted at your location.")
                    .font(.callout)
                    .padding(.vertical)
                    .opacity(viewModel.type == .location ? 1 : 0)
                Text("If you are an event organizer, create a page for your organization. Share information about events that you are organizing.")
                    .font(.callout)
                    .padding(.vertical)
                    .opacity(viewModel.type == .organizer ? 1 : 0)
            }
        }
        .padding(.bottom)
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

#Preview {
    let errorManager: ErrorManagerProtocol = ErrorManager()
    let keychainManager: KeychainManagerProtocol = KeychainManager()
    let appSettingsManager: AppSettingsManagerProtocol = AppSettingsManager()
    let networkMonitorManager: NetworkMonitorManagerProtocol = NetworkMonitorManager(errorManager: errorManager)
    let notificationsManager = NotificationsManager()
    let networkManager = NetworkManager(session: URLSession.shared, networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager, keychainManager: keychainManager)
    let authNetworkManager = AuthNetworkManager(networkManager: networkManager)
    var authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: networkManager, authNetworkManager: authNetworkManager, errorManager: errorManager)
    let vm = PartnerRegistrationViewModel(isPresented: .constant(true))
    return PartnerRegistrationView(viewModel: vm)
        .environmentObject(authenticationManager)
}
