//
//  SettingsView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 25/12/2022.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var passwordManager: PasswordManager
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage("setPasscode") private var passcode = ""
    
    @State var resultText = ""
    
    @State var showPasscodeReset = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    NavigationLink(destination: AccountSettingsView()) {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                            VStack {
                                Text(passwordManager.email)
                                    .font(.subheadline.bold())
                                Text("Active Account")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .offset(x: 5)
                            }
                        }
                    }
                    
                    Section {
                        Text("\(resultText)")
                            .onAppear {
                                do {
                                    let encrypted = try passwordManager.encryptMessage(message: "the encryption system works if you see this message!!!", encryptionKey: passwordManager.safetyKey)
                                    resultText = try passwordManager.decryptMessage(encryptedMessage: encrypted, encryptionKey: passwordManager.safetyKey)
                                } catch {
                                    resultText = "An error occured: \(error.localizedDescription)"
                                }
                            }
                    } header: {
                        Text("Dev settings (temp)")
                    }

                    Section {
                        Button {
                            showPasscodeReset = true
                        } label: {
                            Text("Reset Passcode")
                        }

                    } header: {
                        Text("Passcode Settings")
                    }
                    
                }
                .navigationTitle("Settings")
            }
            .popover(isPresented: $showPasscodeReset) {
                PasscodeResetView(showScreen: $showPasscodeReset)
                    .interactiveDismissDisabled()
            }
            
            
        }
    }
}

struct AccountSettingsView: View {
    var body: some View {
        Text("interesting account settings...")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(PasswordManager())
    }
}
