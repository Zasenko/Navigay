//
//  Report.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.06.24.
//

import Foundation

struct Report: Codable {
    let item: ReportItem
    let itemId: Int
    let reason: ReportReason
    let text: String?
    let userId: Int?
}

enum ReportReason: Int, Codable {
    case other = 0
    case inappropriateContent = 1
    case misleadingInformation = 2
    case spam = 3
}

extension ReportReason {
    func getText() -> String {
        switch self {
        case .inappropriateContent:
            return "Inappropriate Content"
        case .misleadingInformation:
            return "Misleading Information"
        case .spam:
            return "Spam"
        case .other:
            return "Other"
        }
    }
}

enum ReportItem: Int, Codable {
    case other = 0
    case comment = 1
}
