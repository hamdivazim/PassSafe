//
//  HomeView.swift
//  PassSafe
//
//  Created by Hamd Waseem on 28/12/2022.
//

import SwiftUI

struct HomeView: View {
    @State var searchText = ""
    
    @State var showAddItem = false
    
    @AppStorage("setPasscode") private var passcode = ""
    
    @EnvironmentObject var passwordManager: PasswordManager
    
    @Binding var screenManager: String
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    if passwordManager.websites.count == 0 {
                        VStack {
                            Image(systemName: "text.magnifyingglass")
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .aspectRatio(contentMode: .fill)
                                
                            Text("No items found!")
                                .font(.callout.bold())
                            Text("Add an item in the top corner of the screen.")
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        ForEach(0..<searchResults.count, id: \.self) { i in
                            NavigationLink(destination: PasswordView(index: passwordManager.websites.firstIndex(of: searchResults[i])).environmentObject(passwordManager)) {
                                Text("\"\(searchResults[i])\"")
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    passwordManager.removeItem(i)
                                } label: {
                                    Label("Delete Item", systemImage: "trash.fill")
                                }
                                .tint(.red)
                            }
                            .contextMenu {
                                NavigationLink(destination: PasswordView(index: passwordManager.websites.firstIndex(of: searchResults[i])).environmentObject(passwordManager)) {
                                    Label("Open Saved Password", systemImage: "lock.open.fill")
                                }
                                Button(role: .destructive) {
                                    passwordManager.removeItem(i)
                                } label: {
                                    Label("Delete Item", systemImage: "trash.fill")
                                }
                                .tint(.red)
                            }

                            
                        }
                        .padding()
                    }
                    
                }
                .navigationTitle("Your Passwords")
                .searchable(text: $searchText, prompt: Text("Search your websites"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            NavigationLink(destination: SettingsView().environmentObject(passwordManager)) {
                                Label("Settings", systemImage: "gear")
                            }
                            
                            Button(role: .destructive) {
                                passwordManager.signOut()
                                passwordManager.signedIn = false
                                screenManager = "login"
                            } label: {
                                Label("Sign Out", systemImage: "gear")
                            }
                        } label: {
                            Label("Account Settings", systemImage: "person.crop.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showAddItem.toggle()
                        } label: {
                            Label("Add Item", systemImage: "plus.circle")
                        }
                    }
                }
            }
            .popover(isPresented: $showAddItem) {
                AddItemView(popupState: $showAddItem).environmentObject(passwordManager)
            }
            
            if passcode == "" {
                PasscodeSetupView()
                    .transition(.move(edge: .bottom))
                    .environmentObject(passwordManager)
            }
        }
        
    }
    
    var searchResults: [String] {
        if searchText.isEmpty {
            return passwordManager.websites
        } else {
            return passwordManager.websites.filter { $0.contains(searchText) }
        }
    }
    
    func delete(at offsets: IndexSet) {
        passwordManager.websites.remove(atOffsets: offsets)
        passwordManager.passwords.remove(atOffsets: offsets)
    }
}

//                preview: {
//                    PasswordView(preview: true, index: passwordManager.websites.firstIndex(of: searchResults[i])).environmentObject(passwordManager)
//                }

struct HomeView_Previews: PreviewProvider {
    @State static var screenManager = ""
    
    static var previews: some View {
        HomeView(screenManager: $screenManager)
            .environmentObject(PasswordManager())
    }
}
