//
//  EditEventTitleView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.04.24.
//

import SwiftUI

struct EditEventTitleView: View {
    //MARK: - Private Properties
        
        @ObservedObject private var viewModel: EditEventViewModel
        
        @State private var name: String = ""
        @State private var type: EventType = .other
        @State private var isLoading: Bool = false
        
        @FocusState private var focused: Bool
        @Environment(\.dismiss) private var dismiss

        private let characterLimit: Int = 255
        private let title: String = "Title & Type"
        private let placeholder: String = "Title"
        
        // MARK: - init
        
        init(viewModel: EditEventViewModel) {
            self.viewModel = viewModel
        }
        
        // MARK: - Body
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                typeField
                Divider()
                TextField(placeholder, text: $name)
                    .focused($focused)
                    .onChange(of: name, initial: true) { oldValue, newValue in
                        name = String(newValue.prefix(characterLimit))
                    }
                    .padding()
                Divider()
                    .padding(.bottom)
                Text(String(characterLimit - name.count))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing).padding(.horizontal)
                
                Spacer()
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline.bold())
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        AppImages.iconLeft
                            .bold()
                            .frame(width: 30, height: 30, alignment: .leading)
                    }
                    .tint(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isLoading {
                        ProgressView()
                            .tint(.blue)
                    } else {
                        Button("Save") {
                            update()
                        }
                        .bold()
                        .disabled(name.isEmpty || name.count < 2)
                    }
                }
            }
            .onAppear {
                focused = true
                name = viewModel.name
                type = viewModel.type
            }
        }
        
        //MARK: - Views
        
        private var typeField: some View {
            Menu {
                ForEach(EventType.allCases, id: \.self) { type in
                    Button("\(type.getName())") {
                        self.type = type
                    }
                }
            } label: {
                HStack {
                    Text("Type:")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("\(type.getName())")
                        .tint(.primary)
                    AppImages.iconRight
                        .foregroundStyle(.quaternary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
            }
        }
        
        //MARK: - Private Functions
        
        private func update() {
            isLoading = true
            focused = false
            Task {
                if await viewModel.updateTitleAndType(name: name, type: type) {
                    await MainActor.run {
                        dismiss()
                    }
                }
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }

//#Preview {
//    let appSettingsManager = AppSettingsManager()
//    let errorManager = ErrorManager()
//    let networkMonitorManager: NetworkMonitorManagerProtocol = NetworkMonitorManager(errorManager: errorManager)
//    let networkManager: EditEventNetworkManagerProtocol = EditEventNetworkManager(networkMonitorManager: networkMonitorManager)
//    let user = AppUser(decodedUser: DecodedAppUser(id: 0, name: "Dima", email: "test@test.ru", status: .admin, sessionKey: "fddddddd", bio: "dddd", photo: nil))
//    
//    return EditEventTitleView(viewModel: EditEventViewModel(eventID: 1, user: user, event: nil, networkManager: networkManager, errorManager: errorManager))
//}
