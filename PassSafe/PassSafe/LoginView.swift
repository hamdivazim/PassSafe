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
    @State var showPasswordReset = false
    
    @AppStorage("signedInEmail") var signedInEmail = ""
    @AppStorage("signedInPassword") var signedInPassword = ""
    
    var body: some View {
        if showLogin {
            if !(signedInEmail == "") && !passwordManager.showFirebaseAlert {
                VStack {
                    ProgressView()
                        .padding()
                    Text("Signing In ...")
                        .font(.headline.bold())
                }
                .padding()
            } else {
                NavigationStack {
                    VStack {
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
                                    .wideButton()
                            }
                            .disableWithOpacity(email == "" || password == "")
                            .alert(isPresented: $passwordManager.showFirebaseAlert) {
                                Alert(title: Text("Error"), message: Text(passwordManager.errorMessage), dismissButton: .default(Text("Ok"), action: {
                                    signedInEmail = ""
                                    signedInPassword = ""
                                }))
                            }
                        }
                        
                        // coming soon
                        
//                        if passwordManager.isLoading {
//                            ProgressView()
//                                .padding()
//                        } else {
//                            GoogleSignInButton()
//                                .frame(height: 50)
//                                .onTapGesture {
//                                    passwordManager.signInWithGoogle()
//                                }
//                                .alert(isPresented: $passwordManager.showFirebaseAlert) {
//                                    Alert(title: Text("Error"), message: Text(passwordManager.errorMessage), dismissButton: .default(Text("Ok")))
//                                }
//                        }
                        
                        Spacer()
                        
                        HStack {
                            Text("Don't have an account?")
                            Button("Register now!") {
                                showLogin = false
                            }
                        }
                        
                        Button("Forgotten your password?") {
                            showPasswordReset = true
                        }
                    }
                    .padding()
                    .navigationTitle("Login")
                }
                .popover(isPresented: $showPasswordReset) {
                    PasswordResetView(showPopup: $showPasswordReset)
                        .environmentObject(passwordManager)
                }
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
                    .textInputAutocapitalization(.never)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .padding()
                    .focused($isKeyboardShowing)
                    .textInputAutocapitalization(.never)
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
