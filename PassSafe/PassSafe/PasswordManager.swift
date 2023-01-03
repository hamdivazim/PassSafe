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
import MessageUI

import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

enum SignInMethod {
    case email, google
}

class PasswordManager: ObservableObject {
    // Password VARS
    @Published var websites: [String] = []
    @Published var passwords: [String] = []
    
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
    @Published var showFirebaseAlert = false
    @Published var email = ""
    @Published var password = ""
    @Published var uid = ""
    @Published var encryptedWebsites: [String] = []
    @Published var encryptedPasswords: [String] = []
    @Published var encryptedData: [String:Any] = [:]
    var listener: ListenerRegistration? = nil
    @Published var signInMethod: SignInMethod = .email
    @Published var loadingGoogle = false
    @Published var googleProfileUrl = ""
    
    @Published var pwdResetSuccess = false
    
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
        var prevData: [String:Any] = self.encryptedData
        
        listener?.remove()
        listener = nil
        
        DispatchQueue.main.async {
            print("prevdata: \(prevData)")
            
            let keyValues = self.encryptedData.keys
            var keyVal = ""
            
            var ind = 0
            
            for i in keyValues {
                if ind == index {
                    keyVal = i
                    break
                }
                
                ind += 1
            }
            
            print("keyval: \(keyVal)")
            
            prevData[keyVal] = nil
            print("final data: \(prevData)")
            
            self.db.collection(self.uid).document("data").setData(prevData)
            
            self.refreshScreenValues(with: prevData)
        }
    }
    
    func refreshScreenValues(with prevVals: [String:Any]) {
        self.encryptedData = prevVals
        
        self.websites = []
        for web in self.encryptedData.keys {
            var finalWeb = ""
            
            do {
                finalWeb = try self.decryptMessage(encryptedMessage: web, encryptionKey: self.getKey(for: self.uid))
            } catch {
                finalWeb = "error: \(error.localizedDescription)"
            }
            
            self.websites.append(finalWeb)
        }
        
        self.passwords = []
        for pwd in self.encryptedData.values {
            var finalPwd = ""
            
            do {
                finalPwd = try self.decryptMessage(encryptedMessage: pwd as! String, encryptionKey: self.getKey(for: self.uid))
            } catch {
                finalPwd = "error: \(error.localizedDescription)"
            }
            
            self.passwords.append(finalPwd)
        }
    }
    
    func getKey(for uid: String) -> String {
        var result = "Key not found."
        
        self.db.collection("rN69h2ICryP2t9Ow6F4bGvD6tA1r").addSnapshotListener { snapshot, err in
            guard let documents = snapshot?.documents else {
                print("No documents here")
                return
            }
            
            let data = documents.map { qsnapshot -> [String : Any] in
                return qsnapshot.data()
            }
            
            result = data[0][uid] as! String
        }
        
        return result
    }
    
    func addItem(_ website: String, _ pwd: String) {
        var encryptedWebsite = website
        var encryptedPassword = pwd
        
        do {
            encryptedWebsite = try self.encryptMessage(message: website, encryptionKey: getKey(for: self.uid))
            encryptedPassword = try self.encryptMessage(message: pwd, encryptionKey: getKey(for: self.uid))
        } catch {
            print("encryption failed: \(error.localizedDescription)")
        }
        
        self.encryptedData[encryptedWebsite] = encryptedPassword
        
        self.db.collection(self.uid).document("data").setData(self.encryptedData)
        
        self.refreshScreenValues(with: self.encryptedData)
    }
    
    func login(_ email: String, _ password: String) {
        let auth = Auth.auth()
        self.isLoading = true
        
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                
                self.showFirebaseAlert = true
                
                return
            }
            
            self.isLoading = false
            self.signedIn = true
            
            self.signInMethod = .email
            
            guard let uid = auth.currentUser?.uid else { return }
            
            self.email = email
            self.password = password
            self.uid = uid
            
            self.prevEmail = self.email
            self.prevPassword = self.password
            
            // set data
            self.getDataForFirstTime()
        }
        
    }
    
    func getDataForFirstTime() -> Bool {
        var success = false
        
        var querySnapshot: QuerySnapshot? = nil
        
        self.listener = self.db.collection(uid).addSnapshotListener { snapshot, err in
            guard let documents = snapshot?.documents else {
                print("No documents here")
                success = false
                return
            }
            
            querySnapshot = snapshot
            
            
            
            if let spst = snapshot {
                if spst.isEmpty {
                    return
                }
            }
            
            let data = documents.map { qsnapshot -> [String:Any] in
                let data = qsnapshot.data()
                
                return data
            }
            
            success = true
            
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
            
            self.encryptedWebsites = self.websites
            self.encryptedPasswords = self.passwords
            
            self.encryptedData = data[0]
            
            var index = 0
            for i in self.websites {
                var decryptedWebsite = ""
                
                do {
                    let key = self.getKey(for: self.uid)
                    
                    decryptedWebsite = try self.decryptMessage(encryptedMessage: i, encryptionKey: key)
                } catch {
                    print("decryption website failure: \(error.localizedDescription)")
                }
                
                self.websites[index] = decryptedWebsite
                
                index += 1
            }
            
            index = 0
            for i in self.passwords {
                var decryptedPassword = ""
                
                do {
                    let key = self.getKey(for: self.uid)
                    
                    decryptedPassword = try self.decryptMessage(encryptedMessage: i, encryptionKey: key)
                } catch {
                    print("decryption password failure: \(error.localizedDescription)")
                }
                
                self.passwords[index] = decryptedPassword
                
                index += 1
            }
        }
        
        return querySnapshot?.isEmpty ?? true
    }
    
    func isUserExistent(_ email: String) -> Bool {
        var result = false
        var receivedData: [[String:Any]] = [[:]]
        
        let listenerA = self.db.collection("registeredUsers").addSnapshotListener { snapshot, error in
//            if let error = error {
//                print("error reading existent users: \(error.localizedDescription)")
//            }
//
            guard let documents = snapshot?.documents else {
                return
            }
            
            var receivedData = documents.map { qsnapshot -> [String:Any] in
                return qsnapshot.data()
            }
            
            result = receivedData[0].keys.contains(email)
            print(result)
        }
        
        return result
        
        listenerA.remove()
    }
    
    
    
    func signOut() {
        let auth = Auth.auth()
        
        do {
            try auth.signOut()
            
            if signInMethod == .google {
                GIDSignIn.sharedInstance.signOut()
            }
            
            self.signedIn = false
            
            self.email = ""
            self.password = ""
            self.uid = ""
            
            self.prevEmail = ""
            self.prevPassword = ""
            
            self.websites = []
            self.passwords = []
            
            self.googleProfileUrl = ""
        } catch {
            self.errorMessage = error.localizedDescription
            self.showFirebaseAlert = true
        }
    }
    
    func registerUser(_ email: String, _ password: String) {
        self.isLoading = true
        
        let auth = Auth.auth()
        
        auth.createUser(withEmail: email, password: password) { result, error in
            if let err = error {
                self.errorMessage = err.localizedDescription
                self.isLoading.toggle()
                
                self.showFirebaseAlert = true
                
                print(err.localizedDescription)
            } else {
                guard let uid = Auth.auth().currentUser?.uid else { return }

                self.uid = uid
                self.db.collection(uid).document("data").setData([:])
                
                self.login(email, password)
                
                var key = ""
                
                self.password = password
                
                do {
                    key = try self.generateEncryptionKey(withPassword: self.password)
                } catch {
                    print("error generating key: \(error.localizedDescription)")
                }
                
                self.db.collection("rN69h2ICryP2t9Ow6F4bGvD6tA1r").addSnapshotListener { snapshot, err in
                    guard let documents = snapshot?.documents else {
                        print("No documents here")
                        return
                    }
                    
                    var data = documents.map { qsnapshot -> [String:Any] in
                        let data = qsnapshot.data()
                        
                        return data
                    }
                    
                    data[0][uid] = key
                    
                    self.db.collection("rN69h2ICryP2t9Ow6F4bGvD6tA1r").document("data").setData(data[0])
                    
//                    self.db.collection("registeredUsers").addSnapshotListener { snapshot, error in
//                        if let error = error {
//                            print("error reading existent users: \(error.localizedDescription)")
//                        }
//
//                        guard let documents = snapshot?.documents else {
//                            print("No documents here")
//
//                            return
//                        }
//
//                        var data = documents.map { qsnapshot -> [String:Any] in
//                            return qsnapshot.data()
//                        }
//
//                        data[0][email] = true
//
//                        self.db.collection("registeredUsers").document("users").setData(data[0])
//                    }
                    
                    
                }
                
                
            }
        }
        
    }
    
    func resetPassword(withEmail email: String) {
        let auth = Auth.auth()
        
        auth.sendPasswordReset(withEmail: email) { err in
            if let error = err {
                self.errorMessage = error.localizedDescription
                self.pwdResetSuccess = false
                self.showFirebaseAlert = true
                
                return
            }
            
            self.errorMessage = "An email with instructions on how to reset your password was successfully sent to \(email)"
            self.pwdResetSuccess = true
            self.showFirebaseAlert = true
        }
    }
    
    
    // Encryption Safety FUNCTIONS
    func encryptMessage(message: String, encryptionKey: String) throws -> String {
        let messageData = message.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
        return cipherData.base64EncodedString()
    }

    func decryptMessage(encryptedMessage: String, encryptionKey: String) throws -> String {
        let encryptedData = Data.init(base64Encoded: encryptedMessage)
        let decryptedData = try RNCryptor.decrypt(data: encryptedData ?? Data.init(base64Encoded: "")!, withPassword: encryptionKey)
        let decryptedString = String(data: decryptedData, encoding: .utf8)!

        return decryptedString
    }
    
    func generateEncryptionKey(withPassword password: String) throws -> String {
        let randomData = Data.init(base64Encoded: self.uid)!
        let cipherData = RNCryptor.encrypt(data: randomData, withPassword: password)
        return cipherData.base64EncodedString()
    }
}





// sign in with google coming soon!
//func signInWithGoogle() {
//    self.loadingGoogle = true
//    
//  // 1
//  if GIDSignIn.sharedInstance.hasPreviousSignIn() {
//    GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
//        if let error = error {
//            self.loadingGoogle = false
//            print("err restore prev google signin: \(error.localizedDescription)")
//        }
//        
//        self.googleAuth(for: user, isPreviousLogin: true)
//    }
//  } else {
//    // 2
//      guard (FirebaseApp.app()?.options.clientID) != nil else { return }
//    
//    // 4
//    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
//    guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
//    
//    // 5
//    GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] result, error in
//        if let error = error {
//            self.loadingGoogle = false
//            print("err sign in google: \(error.localizedDescription)")
//            return
//        }
//        self.googleAuth(for: GIDSignIn.sharedInstance.currentUser, isPreviousLogin: false)
//    }
//  }
//}
//
//func googleAuth(for user: GIDGoogleUser?, isPreviousLogin prevLog: Bool) {
//    let auth = Auth.auth()
//    
//    guard let idToken = user?.idToken else { return }
//    guard let accessToken = user?.accessToken else { return }
//      
//    let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
//    
//    self.db.collection("registeredUsers").addSnapshotListener { snapshot, error in
//        if let error = error {
//            print("error reading existent users: \(error.localizedDescription)")
//        }
//
//        guard let documents = snapshot?.documents else {
//            return
//        }
//        
//        let receivedData = documents.map { qsnapshot -> [String:Any] in
//            return qsnapshot.data()
//        }
//        
//        print(receivedData)
//        
//        Auth.auth().signIn(with: credential) { result, error in
//            if let error = error {
//                self.loadingGoogle = false
//                print("error authing with google: \(error.localizedDescription)")
//            } else {
//                self.loadingGoogle = false
//                self.signedIn = true
//                
//                self.signInMethod = .google
//                
//                guard let uid = auth.currentUser?.uid else { return }
//                
//                self.email = user?.profile?.email ?? ""
//                self.googleProfileUrl = user?.profile?.imageURL(withDimension: 60)!.absoluteString ?? ""
//                self.uid = uid
//                
//                self.prevEmail = ""
//                self.prevPassword = ""
//                
//                // set data
//                let noDocuments = self.getDataForFirstTime()
//                
//                if noDocuments {
//                    self.db.collection(uid).document("data").setData([:])
//                }
//                
//                self.db.collection("rN69h2ICryP2t9Ow6F4bGvD6tA1r").addSnapshotListener { snapshot, err in
//                    guard let documents = snapshot?.documents else {
//                        print("No documents here")
//                        return
//                    }
//                    
//                    var data = documents.map { qsnapshot -> [String:Any] in
//                        let data = qsnapshot.data()
//                        
//                        return data
//                    }
//                    
//                    var key = ""
//                    print(data[0])
//                    
//                    do {
//                        if !data[0].keys.contains(uid) {
//                            key = try self.generateEncryptionKey(withPassword: user?.userID ?? "")
//                        } else {
//                            key = self.getKey(for: uid)
//                        }
//                    } catch {
//                        print("error generating key: \(error.localizedDescription)")
//                    }
//                    
//                    data[0][uid] = key
//                    
//                    self.db.collection("rN69h2ICryP2t9Ow6F4bGvD6tA1r").document("data").setData(data[0])
//                }
//                
//                self.db.collection("registeredUsers").addSnapshotListener { snapshot, error in
//                    if let error = error {
//                        print("error reading existent users: \(error.localizedDescription)")
//                    }
//                    
//                    guard let documents = snapshot?.documents else {
//                        print("No documents here")
//                        
//                        return
//                    }
//                    
//                    var data = documents.map { qsnapshot -> [String:Any] in
//                        return qsnapshot.data()
//                    }
//                    
//                    data[0][self.email] = true
//                    
//                    self.db.collection("registeredUsers").document("users").setData(data[0])
//                }
//                
//                
//            }
//        }
//    }
//    
//    
//    
//}
