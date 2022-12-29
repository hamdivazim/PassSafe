//
//  PasswordManager.swift
//  PassSafe
//
//  Created by Hamd Waseem on 24/12/2022.
//

import Foundation

import LocalAuthentication
import SwiftUI
import RNCryptor

import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class PasswordManager: ObservableObject {
    // Password VARS
    @Published var websites: [String] = ["https://apple.com", "https://google.com", "https://gmail.com"]
    @Published var passwords: [String] = ["123456", "mygooglepassword", "aninterestinggmailpassword"]
    
    // Auth VARS
    private(set) var context = LAContext()
    @Published private(set) var biometryType = LABiometryType.none
    private(set) var canEvaluatePolicy = false
    @Published var isAuth = false
    @Published private(set) var errorDescription: String?
    @Published var showAlert = false
    var currentWebsite = ""
    
    // Encryption Safety VARS
    private(set) var safetyKey = ""
    
    // Firebase VARS
    @Published var signedIn = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var email = ""
    @Published var password = ""
    @Published var uid = ""
    
    let db = Firestore.firestore()
    
    @AppStorage("signedInEmail") var prevEmail = ""
    @AppStorage("signedInPassword") var prevPassword = ""
    
    
    // init func
    init() {
        getBiometryType()
        
        if prevEmail != "" {
            self.login(prevEmail, prevPassword)
        }
    }
    
    // Auth FUNCTIONS
    func getBiometryType() {
        canEvaluatePolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        DispatchQueue.main.async {
            self.biometryType = self.context.biometryType
        }
    }
    
    func authenticateWithBiometrics() async {
        context = LAContext()
        getBiometryType()
        if canEvaluatePolicy {
            let reason = "View the password for \(currentWebsite)."
            
            do {
                let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
                
                if success {
                    DispatchQueue.main.async {
                        withAnimation {
                            self.isAuth = true
                        }
                        print("is authenticated \(self.isAuth)")
                    }
                }
            } catch {
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    self.biometryType = .none
                    self.errorDescription = error.localizedDescription
                    self.showAlert = true
                }
            }
            
        }
    }
    
    // Firebase FUNCTIONS
    func removeItem(_ index: Int) {
        self.websites.remove(at: index)
        self.passwords.remove(at: index)
        print(self.passwords)
    }
    
    func addItem(_ website: String, _ password: String) {
        self.db.collection(uid).addSnapshotListener { snapshot, err in
            guard let documents = snapshot?.documents else {
                print("No documents here")
                return
            }
            
            var data = documents.map { qsnapshot -> [String:Any] in
                return qsnapshot.data()
            }
            
            data[0][website] = password
            
            self.db.collection(self.uid).document("data").setData(data[0])
        }
    }
    
    func login(_ email: String, _ password: String) {
        let auth = Auth.auth()
        self.isLoading = true
        
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                
                return
            }
            
            self.isLoading = false
            self.signedIn = true
            
            guard let uid = auth.currentUser?.uid else { return }
            
            self.email = email
            self.password = password
            self.uid = uid
            
            self.prevEmail = self.email
            self.prevPassword = self.password
            
            do {
                try self.safetyKey = self.generateEncryptionKey(withPassword: password)
            } catch {
                print("SAFETY KEY NOT GENERATED with error: \(error.localizedDescription)")
            }
            
            // set data
            self.db.collection(uid).addSnapshotListener { snapshot, err in
                guard let documents = snapshot?.documents else {
                    print("No documents here")
                    return
                }
                
                let data = documents.map { qsnapshot -> [String:Any] in
                    let data = qsnapshot.data()
                    
                    return data
                }
                
                print(data)
                
                self.websites = []
                self.passwords = []
                
                for i in data {
                    for key in i.keys {
                        self.websites.append(key)
                    }
                    for value in i.values {
                        self.passwords.append(value as! String)
                    }
                }
            }
        }
        
    }
    
    func signOut() {
        let auth = Auth.auth()
        
        do {
            try auth.signOut()
            
            self.signedIn = false
            
            self.email = ""
            self.password = ""
            self.uid = ""
            
            self.prevEmail = ""
            self.prevPassword = ""
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func registerUser(_ email: String, _ password: String) {
        self.isLoading = true
        
        let auth = Auth.auth()
        
        auth.createUser(withEmail: email, password: password) { result, error in
            if let err = error {
                self.errorMessage = err.localizedDescription
                self.isLoading.toggle()
                
                print(err.localizedDescription)
            } else {
//                auth.signIn(withEmail: email, password: password) { result, error in
//                    if let err = error {
//                        self.errorMessage = err.localizedDescription
//                        self.isLoading.toggle()
//                        return
//                    } else {
//                        self.password = password
//                        self.email = email
//                        self.signedIn = true
//                    }
//                }
//
//                guard let uid = Auth.auth().currentUser?.uid else { return }
//
//                self.uid = uid
//                self.db.collection(uid).document("data").setData([:])
//
//                self.db.collection(uid).addSnapshotListener { snapshot, err in
//                    guard let documents = snapshot?.documents else {
//                        print("No documents here")
//                        return
//                    }
//
//                    let data = documents.map { qsnapshot -> [String:Any] in
//                        let data = qsnapshot.data()
//
//                        return data
//                    }
//
//                    print(data)
//
//                    self.websites = []
//                    self.passwords = []
//
//                    for i in data {
//                        for key in i.keys {
//                            self.websites.append(key)
//                        }
//                        for value in i.values {
//                            self.passwords.append(value as! String)
//                        }
//                    }
//                }
                guard let uid = Auth.auth().currentUser?.uid else { return }

                self.uid = uid
                self.db.collection(uid).document("data").setData([:])
                
                self.login(email, password)
            }
        }
        
    }
    
    
    // Encryption Safety FUNCTIONS
    func encryptMessage(message: String, encryptionKey: String) throws -> String {
        let messageData = message.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
        return cipherData.base64EncodedString()
    }

    func decryptMessage(encryptedMessage: String, encryptionKey: String) throws -> String {
        let encryptedData = Data.init(base64Encoded: encryptedMessage)!
        let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: encryptionKey)
        let decryptedString = String(data: decryptedData, encoding: .utf8)!

        return decryptedString
    }
    
    func generateEncryptionKey(withPassword password: String) throws -> String {
        // Use the user's firebase account password as the key - randomData should be replaced with users uuid when firebase is implemented
        
        let randomData = Data.init(base64Encoded: "p4f8yquv5Pb4PdvMSCHA9IroDv32")!//"RNCryptor.randomData(ofLength: 32)"
        let cipherData = RNCryptor.encrypt(data: randomData, withPassword: password)
        return cipherData.base64EncodedString()
    }
}
