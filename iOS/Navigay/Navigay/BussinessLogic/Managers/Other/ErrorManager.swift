//
//  ErrorManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import SwiftUI

protocol ErrorManagerProtocol {
    var getError: ((ErrorModel) -> Void)? { get set }
    func showError()
    func showError(error: Error)
    func showError(text: String)
    func showError(model: ErrorModel)
    func showApiError(error: ApiError?)
    func showApiErrorOrMessage(apiError: ApiError?, or error: ErrorModel)
}

final class ErrorManager: ErrorManagerProtocol {
    
    // MARK: - Properties
    
    var getError: ((ErrorModel) -> Void)?
    
    // MARK: - Functions
    
    func showApiError(error: ApiError?) {
        guard let error = error else { return }
        if error.show {
            getError?(ErrorModel.init(massage: error.message, img: Image(systemName: "exclamationmark.triangle"), color: .red))
        } else {
            showError()
        }
    }
    
    func showApiErrorOrMessage(apiError: ApiError?, or error: ErrorModel) {
        if let apiError = apiError {
            if apiError.show {
                getError?(ErrorModel.init(massage: apiError.message, img: nil, color: nil))
            } else {
                debugPrint(apiError.message)
            }
        } else {
            showError(model: error)
        }
    }
    
    func showError() {
        getError?(ErrorModel.init(massage: "Что-то пошло не так", img: Image(systemName: "exclamationmark.triangle"), color: .red))
    }
    
    func showError(model: ErrorModel) {
        getError?(model)
    }
    
    func showError(error: Error) {
        getError?(ErrorModel.init(massage: "\(error.localizedDescription): \(error)", img: Image(systemName: "exclamationmark.triangle"), color: .gray))
    }
    
    func showError(text: String) {
        getError?(ErrorModel.init(massage: text, img: Image(systemName: "exclamationmark.triangle"), color: .yellow))
    }
}
