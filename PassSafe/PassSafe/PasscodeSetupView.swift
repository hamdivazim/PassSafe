//
//  PasscodeSetupView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 27/12/2022.
//

import SwiftUI

struct PasscodeSetupView: View {
    @Environment(\.colorScheme) var colourScheme
    @EnvironmentObject var passwordManager: PasswordManager
    
    @AppStorage("setPasscode") var setPasscode = ""
    
    @State var currentScreen = 1
    
    @State var passcodeText = ""
    @FocusState var isKeyboardShowing: Bool
    
    @State var passcode = ""
    
    @State var showAlert = false
    
    var body: some View {
        ZStack {
            if colourScheme == .dark {
                Color.black.ignoresSafeArea()
            } else {
                Color.white.ignoresSafeArea()
            }
            
            VStack {
                if currentScreen == 1 {
                    Text("Passcode Setup")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("It looks like your passcode isn't setup; please setup your passcode to securely store passwords.")
                        .multilineTextAlignment(.center)
                    
                    Button {
                        currentScreen = 2
                    } label: {
                        LargeButton(text: "Set Passcode")
                    }
                }
                
                if currentScreen == 2 {
                    VStack {
                        Spacer()
                        
                        Text("Enter Your Passcode")
                            .font(.largeTitle.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack(spacing: 0) {
                            ForEach(0..<4, id: \.self) { i in
                                TextEntry(i)
                            }
                        }
                        .background(content: {
                            TextField("", text: $passcodeText.limit(4))
                                .keyboardType(.numberPad)
                                .frame(width: 1, height: 1)
                                .opacity(0.001)
                                .blendMode(.screen)
                                .focused($isKeyboardShowing)
                        })
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isKeyboardShowing.toggle()
                        }
                        .padding(.bottom, 20)
                        .padding(.top, 10)
                        
                        Button {
                            passcode = passcodeText
                            passcodeText = ""
                            currentScreen = 3
                        } label: {
                            Text("Set Code")
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
                        .disableWithOpacity(passcodeText.count < 4)
                        
                        Spacer()
                        
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            Button("Done") {
                                isKeyboardShowing.toggle()
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
                
                if currentScreen == 3 {
                    VStack {
                        Spacer()
                        
                        Text("Confirm Your Passcode")
                            .font(.title.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack(spacing: 0) {
                            ForEach(0..<4, id: \.self) { i in
                                TextEntry(i)
                            }
                        }
                        .background(content: {
                            TextField("", text: $passcodeText.limit(4))
                                .keyboardType(.numberPad)
                                .frame(width: 1, height: 1)
                                .opacity(0.001)
                                .blendMode(.screen)
                                .focused($isKeyboardShowing)
                        })
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isKeyboardShowing.toggle()
                        }
                        .padding(.bottom, 20)
                        .padding(.top, 10)
                        
                        Button {
                            if passcodeText == passcode {
                                isKeyboardShowing = false
                                setPasscode = passcode
                            } else {
                                showAlert = true
                            }
                        } label: {
                            Text("Confirm and Set Code")
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
                        .disableWithOpacity(passcodeText.count < 4)
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Error"), message: Text("The password did not match your previously set password."), dismissButton: .default(Text("Ok")))
                        }
                        
                        Spacer()
                        
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            Button("Done") {
                                isKeyboardShowing.toggle()
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func TextEntry(_ index: Int) -> some View {
        ZStack {
            if passcodeText.count > index {
                let startIndex = passcodeText.startIndex
                let charIndex = passcodeText.index(startIndex, offsetBy: index)
                let charToString = String(passcodeText[charIndex])
                Text(charToString)
            } else {
                Text(" ")
            }
        }
        .frame(width: 45, height: 45)
        .background {
            let status = (isKeyboardShowing && passcodeText.count == index)
            
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(status ? (colourScheme == .dark ? .white : .black) : .gray, lineWidth: status ? 1 : 0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PasscodeSetupView_Previews: PreviewProvider {
    static var previews: some View {
        PasscodeSetupView()
            .environmentObject(PasswordManager())
    }
}
