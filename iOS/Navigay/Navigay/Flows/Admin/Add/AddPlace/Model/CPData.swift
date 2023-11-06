//
//  CPData.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.11.23.
//

import Foundation

struct CPData: Codable, Identifiable {
    
    //MARK: - Properties
    
    let id: String
    let name: String
    let flag: String
    let code: String
    let dial_code: String
    let pattern: String
    let limit: Int
}
