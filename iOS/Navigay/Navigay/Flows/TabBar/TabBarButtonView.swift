//
//  TabBarButtonView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 04.10.23.
//

import SwiftUI

struct TabBarButtonView : View {
    
    // MARK: - Properties
    
    @Binding var selectedPage: TabBarRouter
    let button: TabBarButton
    
    // MARK: - Body
    
    var body: some View{
        Button {
            selectedPage = button.page
        } label: {
            button.img
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(selectedPage == button.page ? .red : AppColors.lightGray5)
                .bold()
        }
    }
}


#Preview {
    TabBarButtonView(selectedPage: .constant(.search), button: TabBarButton(title: "Admin", img: AppImages.iconAdmin, page: .admin))
}
