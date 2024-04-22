//
//  LoginView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    
    // MARK: - Properties
    
    let onDismiss: () -> Void
    
    // MARK: - Private Properties
    
    @StateObject private var viewModel: LoginViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FocusField?
    
    private enum FocusField: Hashable, CaseIterable {
        case email, password
    }
    
    // MARK: - Init
    
    init(viewModel: LoginViewModel, onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onDismiss = onDismiss
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
//            .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
//                .onEnded { value in
//                    switch(value.translation.width, value.translation.height) {
//                    case (0..., -30...30):
//                        dismiss()
//                    default:  break
//                    }
//                }
//            )
    
    // MARK: - Views

    private var listView: some View {
        List {
            Text("Sign in\nto your Account")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
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
            
            loginButtonView
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
    
    var emailView: some View {
        HStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
        VStack {
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
            HStack {
                Text("Forgot your password?")
                    .foregroundColor(.secondary)
                Button("Reset") {
                    viewModel.showForgetPasswordView.toggle()
                }
                .bold()
                .foregroundStyle(.blue)
            }
            .font(.footnote)
//            .padding(.top, 20)
            .padding()
            .navigationDestination(isPresented: $viewModel.showForgetPasswordView) {
                ForgetPasswordView(email: viewModel.email) { email in
                    viewModel.email = email
                }
            }
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
        .frame(maxWidth: .infinity)
        .disabled(!viewModel.isButtonValid)
        .padding()
    }
    
    // MARK: - Private Functions
    
    private func loginButtonTapped() {
        focusedField = nil
        viewModel.allViewsDisabled = true
        viewModel.buttonState = .loading
        
        Task {
            let message = "Oops! Something went wrong. You're not logged in. Please try again later."
            do {
                let decodedAppUser = try await authenticationManager.login(email: viewModel.email, password: viewModel.password)
                let descriptor = FetchDescriptor(predicate: #Predicate<AppUser>{ $0.id == decodedAppUser.id })
                if let user = try context.fetch(descriptor).first {
                    user.isUserLoggedIn = true
                    user.updateUser(decodedUser: decodedAppUser)
                    authenticationManager.appUser = user
                    authenticationManager.isUserOnline = true
                    setLikedItems(for: user)
                } else {
                    let user = AppUser(decodedUser: decodedAppUser)
                    user.isUserLoggedIn = true
                    authenticationManager.appUser = user
                    authenticationManager.isUserOnline = true
                    context.insert(user)
                }
                onDismiss()
                return
            } catch NetworkErrors.noConnection {
                authenticationManager.errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                authenticationManager.errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
            } catch {
                authenticationManager.errorManager.showError(model: ErrorModel(error: error, message: message, img: AppImages.iconPersonError, color: nil))
            }
            await MainActor.run {
                viewModel.allViewsDisabled = false
                viewModel.buttonState = .normal
            }
        }
    }
    
    private func setLikedItems(for user: AppUser) {
        do {
            let placeDescriptor = FetchDescriptor<Place>()
            let eventDescriptor = FetchDescriptor<Event>()
            let places = try context.fetch(placeDescriptor)
            let events = try context.fetch(eventDescriptor)
            places.forEach { place in
                if user.likedPlaces.contains(where: { $0 == place.id } ) {
                    place.isLiked = true
                }
            }
            events.forEach { event in
                if user.likedEvents.contains(where: { $0 == event.id } ) {
                    event.isLiked = true
                }
            }
            //запрос в сеть на локации, которых нет в базе.
        } catch {
            debugPrint("-Error- LoginView setLikedItems: ", error)
        }
    }
}

//#Preview {
//    let viewModel = LoginViewModel(email: nil)
//    let keychainManager = KeychainManager()
//    let appSettingsManager = AppSettingsManager()
//    let networkManager = AuthNetworkManager(appSettingsManager: appSettingsManager)
//    let errorManager = ErrorManager()
//    let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkManager: networkManager, errorManager: errorManager)
//    return LoginView(viewModel: viewModel, authenticationManager: authenticationManager) {
//        print("dissmised")
//    }
//}
