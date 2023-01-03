//
//  AddItemView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 25/12/2022.
//

import SwiftUI

struct AddItemView: View {
    @EnvironmentObject var passwordManager: PasswordManager
    @Binding var popupState: Bool
    
    @State var website = "https://"
    @State var password = ""
    
    @State var showAlert = false
    @State var alertMessage = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Add Item")
                    .font(.largeTitle.bold())
                
                Spacer()
                
                Button {
                    popupState = false
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "xmark")
                    }
                }
            }
            
            HeaderText("Website")
                .offset(x: 5, y: 10)
            BoxField(text: $website, placeholder: "Website", keyboardType: .URL)
            
            HeaderText("Password")
                .offset(x: 5, y: 10)
            BoxField(text: $password, placeholder: "Password", keyboardType: .alphabet, isPassword: true)
            
            Button {
                if website.isValidURL {
                    if !passwordManager.websites.contains(website) {
                        passwordManager.addItem(website, password)
                        popupState.toggle()
                    } else {
                        alertMessage = "You already have an entry with this website."
                        showAlert = true
                    }
                } else {
                    alertMessage = "The website is not a valid URL."
                    showAlert = true
                }
            } label: {
                Text("\(Image(systemName: "plus")) Add Item")
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
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
            }
            
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    func HeaderText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.smallCaps())
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LargeButton: View {
    var text: String
    
    var body: some View {
        Text(text)
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
}

struct BoxField: View {
    @Binding var text: String
    var placeholder: String
    
    var keyboardType: UIKeyboardType?
    
    var isPassword: Bool?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.thickMaterial)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            
            if (isPassword ?? false) {
                SecureField(placeholder, text: $text)
                    .padding()
                    .keyboardType(keyboardType ?? .default)
                    .autocapitalization(.none)
            } else {
                TextField(placeholder, text: $text)
                    .padding()
                    .keyboardType(keyboardType ?? .default)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
            }
        }
    }
}

struct AddItemView_Previews: PreviewProvider {
    @State static var popupState = true
    static var previews: some View {
        AddItemView(popupState: $popupState)
            .environmentObject(PasswordManager())
    }
}
