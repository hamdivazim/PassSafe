//
//  PasswordResetView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 31/12/2022.
//

import SwiftUI

struct PasswordResetView: View {
    @EnvironmentObject var passwordManager: PasswordManager
    @Binding var showPopup: Bool
    
    @State var email = ""
    
    var placeholder: String?
    
    var body: some View {
        VStack {
            HStack {
                Text("Reset Password")
                    .font(.largeTitle.bold())
                
                Spacer()
                
                Button {
                    showPopup = false
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "xmark")
                    }
                }
            }
            
            VStack {
                Text("We can send you an email with instructions on how to reset your password.")
                    .multilineTextAlignment(.center)
                
                
                HeaderText("Email")
                    .offset(x: 5, y: 10)
                BoxField(text: $email, placeholder: "Email", keyboardType: .emailAddress)
                
                Button {
                    passwordManager.resetPassword(withEmail: email)
                } label: {
                    Text("Send Email")
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
                .alert(isPresented: $passwordManager.showFirebaseAlert) {
                    Alert(title: Text(passwordManager.pwdResetSuccess ? "Message" : "Error"), message: Text(passwordManager.errorMessage), dismissButton: passwordManager.pwdResetSuccess ? .default(Text("Ok"), action: {
                        showPopup = false
                    }) : .default(Text("Ok")))
                }
            }
            .padding(.vertical, 15)
            
            Spacer()
            
            Text("Note: if you cannot see the email, try checking spam.")
                .font(.caption)
        }
        .padding()
        .onAppear { email = placeholder ?? "" }
    }
    
    @ViewBuilder
    func HeaderText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.smallCaps())
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    @State static var showPopup = true
    
    static var previews: some View {
        PasswordResetView(showPopup: $showPopup)
    }
}
