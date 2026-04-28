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
    
    @State private var showFolderSheet = false
    @Namespace private var folderTransition
    

    var body: some View {
        NavigationStack {
            Form {
                Section() {
                    TextFieldLabeled("URL", $webdavURL, "lead by https://, without trailing '/'")
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    
                    TextFieldLabeled("Username", $webdavUsername, "some@email.com")
                        .autocapitalization(.none)

                    TextFieldLabeled(
                        "Folder of Kuotes",
                        $selectedKuotesFolderPath,
                        "(Optional to hardcode path/to/folder)"
                    )

                    Button("Change WebDAV Password") {
                        showingPasswordPopup.toggle()
                    }
                } header: {
                    Text("WebDAV Connection")
                } footer: {
                    Text("webdavURL: \(webdavURL) \nwebdavUsername: \(webdavUsername)\nselectedKuotesFolderPath: \(selectedKuotesFolderPath)")
                }
                .listRowBackground(Color(.secondarySystemGroupedBackground).opacity(0.3))
                
                Section() {
                    Picker("Order", selection: $namingConventionOrderRaw) {
                        ForEach(NamingConventionOrder.allCases) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if namingConventionOrder != .mixed {
                        TextField("Separator (e.g. -)", text: $namingConventionSeparator)
                    }
                } header: {
                    Text("Naming of Files")
                } footer: {
                    if namingConventionOrder == .titleFirst {
                        Text("Currently, Kuotes expects ALL books to be named like this: 'Title \(namingConventionSeparator) Author'")
                            .foregroundStyle(.red)
                    } else if namingConventionOrder == .authorFirst {
                        Text("Currently, Kuotes expects ALL books to be named like this: 'Author \(namingConventionSeparator) Title'")
                            .foregroundStyle(.red)
                    } else {
                        Text("Only toggle this when ALL your books follow the same naming convention")
                            .font(.footnote)
                    }
                }
                .listRowBackground(Color(.secondarySystemGroupedBackground).opacity(0.3))
            }
            .scrollContentBackground(.hidden)
            .background(.kBackground)
            .navigationTitle("Settings")
            .toolbar {
                // Ref: https://serialcoder.dev/text-tutorials/swiftui/morphing-sheets-out-of-buttons-in-swiftui/
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Select Folder") {
                        showFolderSheet = true
                    }
                }
                .matchedTransitionSource(id: "folder-button", in: folderTransition)
            }
            .sheet(isPresented: $showFolderSheet) {
                FolderView() {
                    showFolderSheet = false
                }
                .presentationDetents([.medium, .large])
                .navigationTransition(
                    .zoom(sourceID: "folder-button", in: folderTransition)
                )
            }
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
