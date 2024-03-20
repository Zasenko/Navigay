//
//  NetworkErrors.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import Foundation

enum NetworkErrors: Error {
    case noSessionKey
    case connection
    case noConnection
    case decoderError
    case encoderError
    case bodyEncoderError
    case imageDataError
    case badUrl
    case invalidData
    case bedResponse
    case api
    case apiError(ApiError?)
    case dataConversionError
}
