//
//  AppColors.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 06.09.23.
//

import SwiftUI

struct AppColors {
    
   // static let red = Color("red")
    
    static let background = Color(uiColor: UIColor.systemBackground)
    
    static let lightGray6 = Color(UIColor.systemGray6)
    static let lightGray5 = Color(UIColor.systemGray5)
    static let lightGray3 = Color(UIColor.systemGray3)
    static let background2 = Color(UIColor.secondarySystemBackground)
    static let rainbowGradient = LinearGradient(
        colors: [.red, .blue, .green, .yellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing)
    
    static let gradient1 = LinearGradient(
        colors: [.red, .blue],
        startPoint: .leading,
        endPoint: .trailing)
    
    static let gradient2 = LinearGradient(
        colors: [.red, .yellow],
        startPoint: .leading,
        endPoint: .trailing)
    
    static let gradient3 = LinearGradient(
        colors: [.red, .orange],
        startPoint: .leading,
        endPoint: .trailing)
    
    static let gradient4 = LinearGradient(
        colors: [.orange, .yellow],
        startPoint: .leading,
        endPoint: .trailing)
    
    static let gradient5 = LinearGradient(
        colors: [.gray.opacity(0.5), .gray.opacity(0.2)],
        startPoint: .leading,
        endPoint: .trailing)
}
