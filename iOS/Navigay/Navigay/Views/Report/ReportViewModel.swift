//
//  ReportViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.06.24.
//

import SwiftUI

final class ReportViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var reason: ReportReason? = nil
    @Published var text: String = ""
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    @Published var isAdded = false
    
    let characterLimit = 255
    let reasons: [ReportReason]
    
    // MARK: - Private Properties

    
    private let item: ReportItem
    private let itemId: Int
    private let user: AppUser?
    
    private let networkManager: ReportNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol
    
    // MARK: - Init

    init(item: ReportItem, itemId: Int, reasons: [ReportReason], user: AppUser?, networkManager: ReportNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.item = item
        self.itemId = itemId
        self.reasons = reasons
        self.networkManager = networkManager
        self.user = user
        self.errorManager = errorManager
    }
    
}
extension ReportViewModel {
    
    // MARK: - Functions

    func sendReport() {
        isLoading = true
        let errorMessage = "Failed to submit report. Please try again later."
        Task {
            let report = Report(item: item, itemId: itemId, reason: reason ?? .other, text: text, userId: user?.id)
            
            do {
                try await networkManager.sendReport(report)
                await MainActor.run {
                    isAdded = true
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorMessage, img: nil, color: nil))
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
