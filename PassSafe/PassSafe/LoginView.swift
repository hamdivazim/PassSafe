//
//  LoginView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 28/12/2022.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var passwordManager: PasswordManager
    
    @Binding var screenManager: String
    
    @State var email = ""
    @State var password = ""
    
    @State var showLogin = true
    
    var body: some View {
        if showLogin {
            NavigationStack {
                VStack {
                    Spacer()
                    
                    FocusField(text: $email, placeholder: "Email", keyboardType: .emailAddress)
                    FocusField(text: $password, isSecure: true, placeholder: "Password", keyboardType: .default)
                    
                    if passwordManager.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Button {
                            passwordManager.login(email, password)
                            
                        } label: {
                            Text("Sign In")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(.blue)
                                }
                                .padding(.vertical)
                        }
                        .disableWithOpacity(email == "" || password == "")
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("Don't have an account?")
                        Button("Register now!") {
                            showLogin = false
                        }
                    }
                }
                .padding()
                .navigationTitle("Login")
            }
        } else {
            RegisterView(showLogin: $showLogin)
                .environmentObject(passwordManager)
        }
    }

    
}

struct FocusField: View {
    @Environment(\.colorScheme) var colourScheme
    
    @Binding var text: String
    var isSecure: Bool?
    
    var placeholder: String
    
    var keyboardType: UIKeyboardType
    
    @FocusState var isKeyboardShowing: Bool
    
    var body: some View {
        ZStack {
            if (isSecure ?? false) {
                SecureField(placeholder, text: $text)
                    .padding()
                    .focused($isKeyboardShowing)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .padding()
                    .focused($isKeyboardShowing)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 45)
        .background {
            let status = isKeyboardShowing
            
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(status ? (colourScheme == .dark ? .white : .black) : .gray, lineWidth: status ? 1 : 0.5)
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    @State static var screenManager = "login"
    
    static var previews: some View {
        LoginView(screenManager: $screenManager)
            .environmentObject(PasswordManager())
    }
}
