//
//  UserAuthModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 22.02.24.
//

import SwiftUI
import GoogleSignIn

class UserAuthModel: ObservableObject {
    
    @Published var givenName: String = ""
    @Published var profilePicUrl: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    
    init(){
        check()
        
    }
    
    func checkStatus(){
        if(GIDSignIn.sharedInstance.currentUser != nil){
            let user = GIDSignIn.sharedInstance.currentUser
            guard let user = user else { return }
            let givenName = user.profile?.givenName
            let profilePicUrl = user.profile!.imageURL(withDimension: 100)!.absoluteString
            self.givenName = givenName ?? ""
            self.profilePicUrl = profilePicUrl
            self.isLoggedIn = true
        }else{
            self.isLoggedIn = false
            self.givenName = ""
            self.profilePicUrl =  ""
        }
    }
    
    func check(){
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                self.errorMessage = "error: \(error.localizedDescription)"
                print("error: \(error.localizedDescription)")
            }
            
            self.checkStatus()
        }
    }
    
    func signIn(){
        
       guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                self.errorMessage = "error: \(error.localizedDescription)"
                debugPrint("--error signIn: \(error.localizedDescription)", error)
            }
            self.checkStatus()
        }
    }
    
    func signOut(){
        GIDSignIn.sharedInstance.signOut()
        self.checkStatus()
    }
}
