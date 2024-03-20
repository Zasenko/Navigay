//
//  ErrorManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import SwiftUI

protocol ErrorManagerProtocol {
    var getError: ((ErrorModel) -> Void)? { get set }
    
    var errorMessage: String { get }
    var updateMessage: String { get }
    
    func showError(model: ErrorModel)
    
    func showErrorMessage(error: Error)
    func showApiError(apiError: ApiError?, or message: String, img: Image?, color: Color?)
    func showUpdateError(error: Error)
    
    func showNetworkNoConnected()
    func showNetworkConnected()
}

final class ErrorManager: ErrorManagerProtocol {
    
    // MARK: - Properties
    
    var getError: ((ErrorModel) -> Void)?
    
    let updateMessage: String = "Something went wrong. The information has not been updated. Please try again later."
    let errorMessage: String = "Something went wrong. Please try again later."
    // MARK: - Functions
    
    func showError(model: ErrorModel) {
        debugPrint(model.error, model.message)
        getError?(model)
    }
    
    func showErrorMessage(error: Error) {
        debugPrint(error)
        getError?(ErrorModel(error: error, message: errorMessage, img: nil, color: nil))
    }
    
    func showApiError(apiError: ApiError?, or message: String, img: Image? = nil, color: Color? = nil) {
        if let apiError = apiError {
            if apiError.show {
                showError(model: ErrorModel(error: NetworkErrors.api, message: apiError.message, img: img, color: color))
                debugPrint(apiError.message)
            } else {
                showError(model: ErrorModel(error: NetworkErrors.api, message: message, img: img, color: color))
                debugPrint(apiError.message)
            }
        } else {
            showError(model: ErrorModel(error: NetworkErrors.api, message: message, img: img, color: color))
        }
    }
    
    func showNetworkNoConnected() {
        getError?(ErrorModel(error: NetworkErrors.connection, message: "No internet connection.", img: AppImages.iconNoWifi, color: nil))
    }
    func showNetworkConnected() {
        getError?(ErrorModel(error: NetworkErrors.connection, message: "Device is connected to network.", img: AppImages.iconWifi, color: .green))
    }
    
    func showUpdateError(error: Error) {
        debugPrint(error)
        getError?(ErrorModel(error: error, message: updateMessage, img: nil, color: nil))
    }
    
    func showUpdateInternetError(error: Error) {
        debugPrint(error)
        getError?(ErrorModel(error: error, message: "No internet connection. The information has not been updated. Please try again later.", img: AppImages.iconNoWifi, color: nil))
    }
}
