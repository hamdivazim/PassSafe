//
//  PasscodeView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 26/12/2022.
//

import SwiftUI

struct PasscodeView: View {
    @Binding var showView: Bool
    
    @Environment(\.colorScheme) var colourScheme
    @EnvironmentObject var passwordManager: PasswordManager
    
    @State var passcodeText = ""
    
    @FocusState var isKeyboardShowing: Bool
    
    @AppStorage("setPasscode") var passcode = ""
    
    @State var showAlert = false
    
    var body: some View {
        ZStack {
            if colourScheme == .dark {
                Color.black.ignoresSafeArea()
            } else {
                Color.white.ignoresSafeArea()
            }
            
            VStack {
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
                    if passcodeText == passcode {
                        passwordManager.isAuth = true
                        isKeyboardShowing = false
                        passwordManager.getBiometryType()
                        showView = false
                    } else {
                        showAlert = true
                    }
                } label: {
                    Text("Check Code")
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
                    Alert(title: Text("Error"), message: Text("The passcode is incorrect."), dismissButton: .default(Text("Ok")))
                }
                
            }
            .padding()
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

struct PasscodeView_Previews: PreviewProvider {
    @State static var showView = true
    static var previews: some View {
        PasscodeView(showView: $showView)
            .environmentObject(PasswordManager())
    }
}
