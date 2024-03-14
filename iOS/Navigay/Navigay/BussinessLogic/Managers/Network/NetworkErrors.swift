//
//  NetworkErrors.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import Foundation

enum NetworkErrors: Error {
    case noSessionKey
    case noConnection
    case decoderError
    case encoderError
    case bodyEncoderError
    case imageDataError
    case bedUrl
    case invalidData
    case bedResponse
    case apiError(ApiError?)
    case dataConversionError
}
