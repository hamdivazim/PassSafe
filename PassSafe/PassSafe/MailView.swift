//
//  MailView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 31/12/2022.
//

import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    @EnvironmentObject var passwordManager: PasswordManager
    
    var subject: String
    var emailBody: String

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        var pwdMgr: PasswordManager

        init(presentation: Binding<PresentationMode>, result: Binding<Result<MFMailComposeResult, Error>?>, pwdManager: PasswordManager) {
            _presentation = presentation
            _result = result
            self.pwdMgr = pwdManager
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation, result: $result, pwdManager: self.passwordManager)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        
        vc.setToRecipients(["coding.wizard4@gmail.com"])
        vc.setSubject(self.subject)
        vc.setMessageBody(self.emailBody, isHTML: true)
        
        
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {

    }
}
