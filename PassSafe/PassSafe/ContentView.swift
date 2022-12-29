//
//  ContentView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 24/12/2022.
//

import SwiftUI
import FirebaseCore

struct ContentView: View {
    @StateObject var passwordManager: PasswordManager = PasswordManager()
    
    @State var screenManager = "login"
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some View {
        if screenManager == "login" {
            LoginView(screenManager: $screenManager)
                .environmentObject(passwordManager)
                .onChange(of: passwordManager.signedIn) { _ in
                    screenManager = "home"
                }
        } else if screenManager == "home" {
            HomeView(screenManager: $screenManager)
                .environmentObject(passwordManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
