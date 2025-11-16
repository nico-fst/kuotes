//
//  SettingsView.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import SwiftUI
import Combine

struct SettingsView: View {
    // AppStorage ist Wrapper um UserDefaults - auslesbar auf Festplatte
    @AppStorage("webdavURL") var webdavURL: String = ""
    @AppStorage("webdavUsername") var webdavUsername: String = ""
    @AppStorage("selectedKuotesFolderPath") var selectedKuotesFolderPath: String = ""
    @State private var showingPasswordPopup = false
    @State private var tempPassword: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("WebDAV Connection")) {
                    TextField("URL (mit https://, ohne '/' am Ende)", text: $webdavURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    TextField("Username", text: $webdavUsername)
                        .autocapitalization(.none)
                    
                    TextField("(Optional: Hardcode path/to/folder", text: $selectedKuotesFolderPath)
                    
                    Text("webdavURL: \(webdavURL) \nwebdavUsername: \(webdavUsername)\nselectedKuotesFolderPath: \(selectedKuotesFolderPath)")
                        .font(.footnote)
                        .opacity(0.3)
                    
                    Button("Change WebDAV Password") {
                        showingPasswordPopup.toggle()
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPasswordPopup) {
                NavigationStack {
                    VStack {
                        Text("Enter WebDAV Password")
                            .font(.headline)
                        
                        SecureField("Password", text: $tempPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                    .navigationTitle("WebDAV Password")
                    .toolbar {
                        // Links: X
                        ToolbarItem(placement: .cancellationAction) {
                            Button() {
                                showingPasswordPopup.toggle()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        // Rechts: Check
                        ToolbarItem(placement: .confirmationAction) {
                            Button() {
                                let success = KeychainHelper.save(tempPassword, for: "webdavPassword")
                                print("Saved webdavPassword - success: ", success)
                                showingPasswordPopup.toggle()
                            } label: {
                                Image(systemName: "checkmark")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    SettingsView()
}
