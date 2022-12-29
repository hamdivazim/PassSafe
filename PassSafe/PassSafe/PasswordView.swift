//
//  PasswordView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 24/12/2022.
//

import SwiftUI

struct PasswordView: View {
    var preview: Bool = false
    
    var index: Int?
    
    @EnvironmentObject var passwordManager: PasswordManager
    @Environment(\.scenePhase) var scenePhase
    
    @State var showPasscodeView = false
    
    @State var linkAvailable = true
    
    var body: some View {
        var shortUrl = passwordManager.websites[index ?? 0]
        
        if shortUrl.contains("https://") {
            shortUrl = String(shortUrl.dropFirst(8))
        }
        
        let websiteLink = try! AttributedString(markdown: "[\(shortUrl)](\(passwordManager.websites[index ?? 0]))")
        
        
        return ZStack {
            VStack {
                List {
                    Section {
                        Text(passwordManager.isAuth ? passwordManager.passwords[index ?? 0] : "●●●●●●●●")
                            .if(passwordManager.isAuth) { view in
                                view.textSelection(.enabled)
                            }
                            .onChange(of: scenePhase) { newPhase in
                                if newPhase == .inactive {
                                    passwordManager.isAuth = false
                                }
                            }
                    } header: {
                        if passwordManager.websites[index ?? 0].contains("https://") {
                            Text("Password for \(websiteLink)")
                        } else {
                            Text("Password for \(shortUrl)")
                        }
                    }
                    
                    Section {
                        Button {
                            if passwordManager.isAuth {
                                withAnimation {
                                    passwordManager.isAuth.toggle()
                                }
                            } else {
                                if passwordManager.biometryType != .none {
                                    Task.init {
                                        await passwordManager.authenticateWithBiometrics()
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)){
                                        showPasscodeView = true
                                    }
                                }
                            }
                        } label: {
                            if passwordManager.isAuth {
                                Text("\(Image(systemName: "lock.fill")) Lock")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            } else {
                                switch passwordManager.biometryType {
                                case .faceID:
                                    Text("\(Image(systemName: "faceid")) Unlock with Face ID")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                case .touchID:
                                    Text("\(Image(systemName: "touchid")) Unlock with Touch ID")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                default:
                                    Text("\(Image(systemName: "lock.open.fill")) Unlock with Passcode")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .alert(isPresented: $passwordManager.showAlert) {
                            if passwordManager.errorDescription == "Authentication failure." {
                                return Alert(title: Text("Error"), message: Text("We couldn't authenticate you. Would you like to enter your passcode?"), primaryButton: .default(Text("Enter Passcode"), action: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)){
                                        showPasscodeView = true
                                    }
                                }), secondaryButton: .cancel(Text("Cancel")))
                                
                            } else {
                                return Alert(title: Text("Error"), message: Text(passwordManager.errorDescription ?? "An error occurred while attempting authentication."), dismissButton: .default(Text("Ok")))
                            }
                            

                        }
                    } header: {
                        Text("Lock/Unlock")
                    }

                }
            }
            .task {
                if !preview {
                    passwordManager.isAuth = false
                    passwordManager.currentWebsite = shortUrl
                    await passwordManager.authenticateWithBiometrics()
                } else {
                    passwordManager.isAuth = false
                }
            }
            
            if showPasscodeView {
                PasscodeView(showView: $showPasscodeView)
                    .transition(.move(edge: .bottom))
                    .environmentObject(passwordManager)
            }
        }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(index: 0)
            .environmentObject(PasswordManager())
    }
}
