//
//  SettingsView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 25/12/2022.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @EnvironmentObject var passwordManager: PasswordManager
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage("setPasscode") private var passcode = ""
    
    @State var resultText = ""
    
    @State var showPasscodeReset = false
    @State var showPrivacyNotice = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    NavigationLink(destination: AccountSettingsView().environmentObject(passwordManager)) {
                        HStack {
                            if passwordManager.googleProfileUrl != "" {
                                AsyncImage(url: URL(string: passwordManager.googleProfileUrl))
                                    .frame(width: 60, height: 60)
                                    .mask {
                                        Circle()
                                            .frame(width: 60, height: 60)
                                    }
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                            }
                            VStack {
                                Text(passwordManager.email)
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .offset(x: 5)
                                Text("Active Account")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .offset(x: 5)
                            }
                        }
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
                    
                    Section {
                        Button("Show Privacy Notice") {
                            showPrivacyNotice = true
                        }
                    }
                    
                }
                .navigationTitle("Settings")
            }
            .popover(isPresented: $showPasscodeReset) {
                PasscodeResetView(showScreen: $showPasscodeReset)
                    .interactiveDismissDisabled()
            }
            .popover(isPresented: $showPrivacyNotice) { PrivacyNoticeView(showPopup: $showPrivacyNotice) }
            
            
        }
    }
}

struct AccountSettingsView: View {
    @State var disableResult: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingDisableView = false
    @State var showConfirmDisable = false
    
    @State var deleteResult: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingDeleteView = false
    @State var showConfirmDelete = false
    
    @State var showPwdReset = false
    
    @EnvironmentObject var passwordManager: PasswordManager
    
    var body: some View {
        List {
            HStack {
                if passwordManager.googleProfileUrl != "" {
                    AsyncImage(url: URL(string: passwordManager.googleProfileUrl))
                        .frame(width: 60, height: 60)
                        .mask {
                            Circle()
                                .frame(width: 60, height: 60)
                        }
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                }
                VStack {
                    Text(passwordManager.email)
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: 5)
                    Text("Active Account")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: 5)
                }
            }
            
            Section {
                
                Button {
                    showPwdReset = true
                } label: {
                    Text("Reset Password")
                }
                .popover(isPresented: $showPwdReset) {
                    PasswordResetView(showPopup: $showPwdReset, placeholder: passwordManager.email)
                        .environmentObject(passwordManager)
                }
            } header: {
                Text("Account Settings")
            }

            Section {
                Button(role: .destructive) {
                    showConfirmDisable = true
                } label: {
                    Text("Request to Disable Account")
                }
                .disabled(!MFMailComposeViewController.canSendMail())
                .alert(isPresented: $showConfirmDisable) {
                    Alert(title: Text("Alert"), message: Text("You can send an email to request for your account to be disabled. Do you want to continue?"), primaryButton: .destructive(Text("Yes"), action: {
                        isShowingDisableView = true
                    }), secondaryButton: .cancel(Text("Cancel")))
                }
                .sheet(isPresented: $isShowingDisableView) {
                    MailView(result: $disableResult, subject: "Disable \(self.passwordManager.email) on PassSafe", emailBody: "<p>Hi,</p><p>I would like to disable the account \(self.passwordManager.email) on PassSafe.</p><p>Thanks!</p>")
                        .environmentObject(passwordManager)
                }
                
                Button(role: .destructive) {
                    showConfirmDelete = true
                } label: {
                    Text("Request to Delete Account")
                }
                .disabled(!MFMailComposeViewController.canSendMail())
                .alert(isPresented: $showConfirmDelete) {
                    Alert(title: Text("Alert"), message: Text("Are you sure? Once an administrator sees your message and deletes your account, there will be NO going back."), primaryButton: .destructive(Text("Yes"), action: {
                        isShowingDeleteView = true
                    }), secondaryButton: .cancel(Text("Cancel")))
                }
                .sheet(isPresented: $isShowingDeleteView) {
                    MailView(result: $deleteResult, subject: "Delete \(self.passwordManager.email) on PassSafe", emailBody: "<p>Hi,</p><p>I would like to delete the account \(self.passwordManager.email) on PassSafe.</p><p>Thanks!</p>")
                        .environmentObject(passwordManager)
                }
                
            } header: {
                Text("Danger Zone")
                    .foregroundColor(.init(red: 181/255, green: 93/255, blue: 89/255))
            }

        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(PasswordManager())
    }
}
