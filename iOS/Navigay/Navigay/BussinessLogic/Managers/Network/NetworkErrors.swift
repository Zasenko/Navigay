//
//  NetworkErrors.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import Foundation

enum NetworkErrors: Error {
    case noConnection
    case decoderError
    case encoderError
    case bodyEncoderError
    case imageDataError
    case bedUrl
    case invalidData
    case bedResponse
    case apiError
//    case noUser
//    case apiErrorWithMassage(String)
}
