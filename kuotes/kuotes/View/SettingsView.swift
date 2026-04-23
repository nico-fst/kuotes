//
//  SettingsView.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import Combine
import SwiftUI

enum NamingConventionOrder: String, CaseIterable, Identifiable {
    case authorFirst = "Author first"
    case titleFirst = "Title first"
    case mixed = "Mixed"

    var id: String { rawValue }
}

struct SettingsView: View {
    // AppStorage ist Wrapper um UserDefaults - auslesbar auf Festplatte
    @AppStorage("webdavURL") var webdavURL: String = ""
    @AppStorage("webdavUsername") var webdavUsername: String = ""
    @AppStorage("selectedKuotesFolderPath") var selectedKuotesFolderPath:
        String = ""
    @AppStorage("namingConventionOrder") private var namingConventionOrderRaw: String = NamingConventionOrder.titleFirst.rawValue
    @AppStorage("namingConventionSeparator") private var namingConventionSeparator: String = ""

    // Umweg, weil in UserDefaults nur primitive Datentypen speicherbar
    var namingConventionOrder: NamingConventionOrder {
        get { NamingConventionOrder(rawValue: namingConventionOrderRaw) ?? .titleFirst }
        set { namingConventionOrderRaw = newValue.rawValue }
    }

    @State private var showingPasswordPopup = false
    @State private var tempPassword: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("WebDAV Connection") {
                    TextField(
                        "URL (lead by https://, without trailing '/')",
                        text: $webdavURL
                    )
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    TextField("Username", text: $webdavUsername)
                        .autocapitalization(.none)

                    TextField(
                        "(Optional: Hardcode path/to/folder",
                        text: $selectedKuotesFolderPath
                    )

                    Text(
                        "webdavURL: \(webdavURL) \nwebdavUsername: \(webdavUsername)\nselectedKuotesFolderPath: \(selectedKuotesFolderPath)"
                    )
                    .font(.footnote)
                    .opacity(0.3)

                    Button("Change WebDAV Password") {
                        showingPasswordPopup.toggle()
                    }
                }
                
                Section("Naming Convention") {Picker("Order", selection: $namingConventionOrderRaw) {
                        ForEach(NamingConventionOrder.allCases) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if namingConventionOrder != .mixed {
                        TextField("Separator (e.g. -)", text: $namingConventionSeparator)
                    }
                    
                    if namingConventionOrder == .titleFirst {
                        Text("Currently, Kuotes expects ALL books to be named like this: 'Title \(namingConventionSeparator) Author'")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    } else if namingConventionOrder == .authorFirst {
                        Text("Currently, Kuotes expects ALL books to be named like this: 'Author \(namingConventionSeparator) Title'")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    } else {
                        Text("Only toggle this when ALL your books follow the same naming convention")
                            .font(.footnote)
                            .foregroundStyle(.red)
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
                            Button {
                                showingPasswordPopup.toggle()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        // Rechts: Check
                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                                let success = KeychainHelper.save(
                                    tempPassword,
                                    for: "webdavPassword"
                                )
                                print(
                                    "Saved webdavPassword - success: ",
                                    success
                                )
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
