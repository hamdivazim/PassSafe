//
//  PasscodeResetView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 29/12/2022.
//

import SwiftUI

struct PasscodeResetView: View {
    @Environment(\.colorScheme) var colourScheme
    @EnvironmentObject var passwordManager: PasswordManager
    
    @AppStorage("setPasscode") var setPasscode = ""
    
    @State var currentScreen = 1
    
    @State var passcodeText = ""
    @FocusState var isKeyboardShowing: Bool
    
    @Binding var showScreen: Bool
    
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
                
                HStack {
                    Spacer()
                    Button("Cancel") { showScreen = false }
                }
                
                Spacer()
                
                if currentScreen == 1 {
                    VStack {
                        Spacer()
                        
                        Text("Enter Your Current Passcode")
                            .font(.title2.bold())
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
                            if passcodeText == setPasscode {
                                currentScreen = 2
                                passcodeText = ""
                            } else {
                                showAlert = true
                            }
                        } label: {
                            Text("Confirm Code")
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
                                passcodeText = ""
                                setPasscode = passcode
                                showScreen = false
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
                            Alert(title: Text("Error"), message: Text("The passcode did not match your previously set passcode."), dismissButton: .default(Text("Ok")))
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
                
                if currentScreen == 2 {
                    VStack {
                        Spacer()
                        
                        Text("Set Your Passcode")
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
                            isKeyboardShowing = false
                            passcode = passcodeText
                            currentScreen = 3
                            passcodeText = ""
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
                
                Spacer()
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

struct PasscodeResetView_Previews: PreviewProvider {
    @State static var showScreen = true
    static var previews: some View {
        PasscodeResetView(showScreen: $showScreen)
    }
}
