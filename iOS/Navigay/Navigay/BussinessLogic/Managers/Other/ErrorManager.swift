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
    func showErrorMassage(error: Error)
    func showApiError(apiError: ApiError?, or massage: String, img: Image?, color: Color?)
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
    
    func showErrorMassage(error: Error) {
        debugPrint(error)
        getError?(ErrorModel(error: error, massage: errorMessage, img: nil, color: nil))
    }
    
    func showApiError(apiError: ApiError?, or massage: String, img: Image? = nil, color: Color? = nil) {
        if let apiError = apiError {
            if apiError.show {
                showError(model: ErrorModel(error: NetworkErrors.api, massage: apiError.message, img: img, color: color))
            } else {
                showError(model: ErrorModel(error: NetworkErrors.api, massage: massage, img: img, color: color))
            }
        } else {
            showError(model: ErrorModel(error: NetworkErrors.api, massage: massage, img: img, color: color))
        }
    }
    
    func showNetworkNoConnected() {
        getError?(ErrorModel(error: NetworkErrors.connection, massage: "No internet connection.", img: AppImages.iconNoWifi, color: nil))
    }
    func showNetworkConnected() {
        getError?(ErrorModel(error: NetworkErrors.connection, massage: "Device is connected to network.", img: AppImages.iconWifi, color: .green))
    }
    
    func showUpdateError(error: Error) {
        debugPrint(error)
        getError?(ErrorModel(error: error, massage: updateMessage, img: nil, color: nil))
    }
    
    func showUpdateInternetError(error: Error) {
        debugPrint(error)
        getError?(ErrorModel(error: error, massage: "No internet connection. The information has not been updated. Please try again later.", img: AppImages.iconNoWifi, color: nil))
    }
}
