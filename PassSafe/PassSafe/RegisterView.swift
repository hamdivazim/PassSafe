//
//  RegisterView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 28/12/2022.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var passwordManager: PasswordManager
    
    @Binding var showLogin: Bool
    
    @State var email = ""
    @State var password = ""
    
    var body: some View {
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
                        passwordManager.registerUser(email, password)
                    } label: {
                        Text("Register")
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
                    .alert(isPresented: $passwordManager.showFirebaseAlert) {
                        Alert(title: Text("Error"), message: Text(passwordManager.errorMessage), dismissButton: .default(Text("Ok")))
                    }
                }
                
                Spacer()
                
                HStack {
                    Text("Already have an account?")
                    Button("Sign in now!") {
                        showLogin = true
                    }
                }
            }
            .padding()
            .navigationTitle("Register")
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    @State static var showLogin = false
    
    static var previews: some View {
        RegisterView(showLogin: $showLogin)
            .environmentObject(PasswordManager())
    }
}
