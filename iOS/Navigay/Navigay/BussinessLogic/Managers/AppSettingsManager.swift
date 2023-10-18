//
//  AppSettingsManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 06.09.23.
//

import SwiftUI

protocol AppSettingsManagerProtocol {
    var language: String { get set }
}

final class AppSettingsManager: AppSettingsManagerProtocol  {
    
    //MARK: - Properties
    
    var language: String = ""
    @AppStorage("prefferedLanguage") private var prefferedLanguage: String = ""
    
    //MARK: - Inits
    
    init() {
        if prefferedLanguage.isEmpty {
            let phoneLanguage = NSLocale.preferredLanguages.first
            self.language = phoneLanguage?.components(separatedBy: "-").first  ?? "en"
        } else {
            self.language = prefferedLanguage
        }
    }
}
