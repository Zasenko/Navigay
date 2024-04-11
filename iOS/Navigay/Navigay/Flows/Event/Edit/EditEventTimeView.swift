//
//  EditEventTimeView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.04.24.
//

import SwiftUI

struct EditEventTimeView: View {
    
    //MARK: - Private Properties
    
    @ObservedObject private var viewModel: EditEventViewModel
    
    @State private var startDate: Date?
    @State private var startTime: Date?
    @State private var finishDate: Date?
    @State private var finishTime: Date?
    
    @State private var didApear: Bool = false
    @State private var isLoading: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    private let title: String = "time of the event"
    
    // MARK: - init
    
    init(viewModel: EditEventViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            EventTimeFieldsView(startDate: $startDate, startTime: $startTime, finishDate: $finishDate, finishTime: $finishTime)
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
                    .disabled(startDate == nil)
                    .disabled(isLoading)
                }
            }
        }
        .onAppear {
            if !didApear {
                startDate = viewModel.startDate
                startTime = viewModel.startTime
                finishDate = viewModel.finishDate
                finishTime = viewModel.finishTime
                didApear = true
            }
        }
    }
    
    //MARK: - Private Functions
    
    private func update() {
        isLoading = true
        
        Task {
            guard let startDate else { return }
            if await viewModel.updateTime(startDate: startDate, startTime: startTime, finishDate: finishDate, finishTime: finishTime) {
                await MainActor.run {
                    dismiss()
                }
            } else {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

    #Preview {
        let appSettingsManager = AppSettingsManager()
        let errorManager = ErrorManager()
        let networkMonitorManager: NetworkMonitorManagerProtocol = NetworkMonitorManager(errorManager: errorManager)
        let networkManager: EditEventNetworkManagerProtocol = EditEventNetworkManager(networkMonitorManager: networkMonitorManager)
        let user = AppUser(decodedUser: DecodedAppUser(id: 0, name: "Dima", email: "test@test.ru", status: .admin, sessionKey: "fddddddd", bio: "dddd", photo: nil))
        
        return EditEventTimeView(viewModel: EditEventViewModel(eventID: 1, user: user, event: nil, networkManager: networkManager, errorManager: errorManager))
    }
