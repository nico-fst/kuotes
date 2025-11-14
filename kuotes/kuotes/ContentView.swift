//
//  ContentView.swift
//  kuotes
//
//  Created by Nico Stern on 13.11.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedKuotesFolderPath") var selectedKuotesFolderPath: String = ""
    @AppStorage("webdavURL") var webdavURL: String = ""
    
    @Query private var folders: [Folder]
    @Query private var kuotes: [Kuote]
    
    private var services = KuotesService()
    
    func reloadFolders() async {
        do {
            // alte folder löschen
            let oldFolders = try modelContext.fetch(FetchDescriptor<Folder>())
            for folder in oldFolders {
                modelContext.delete(folder)
            }
            
            // neue folder speichern
            let folders = try await services.fetchFolder(from: "/")
            for folder in folders {
                let newFolder = Folder(name: folder.name, href: folder.href)
                print(newFolder.name)
                modelContext.insert(newFolder)
            }
            
            // speichern - optional, weil eig mit Auto-Save implizit
            try modelContext.save()
        } catch {
            print("Error replacing cached folders with fetched ones: ", error)
        }
    }
    
    func reloadKuotes() async {
        do {
            //  alte Kuotes löschen
            let oldKuotes = try modelContext.fetch(FetchDescriptor<Kuote>())
            for kuote in oldKuotes {
                modelContext.delete(kuote)
            }
            
            // neue Kuotes speichern
            let kuoteFiles: [FileItem] = try await services.fetchKuoteFiles(from: selectedKuotesFolderPath)
            let newKuotes: [Kuote] = try await services.fetchKuotesForFiles(for: kuoteFiles)
            for kuote in newKuotes {
                modelContext.insert(kuote)
            }

            // speichern - optional, weil eig mit Auto-Save implizit
            try modelContext.save()
        } catch {
            print("Error replacing cached Kuotes with fetched ones: ", error)
        }
    }

    var body: some View {
        TabView {
            Tab("Kuotes", systemImage: "quote.bubble.fill") {
                NavigationStack {
                    List {
                        ForEach(kuotes) { kuote in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(kuote.fileItem.displayName)
                                Text("@ \(kuote.chapter)")
                                    .fontWeight(.bold)
                                Text(kuote.text)
                            }
                        }
                    }
                    .refreshable { await reloadKuotes() }
                    .navigationTitle("Kuotes")
                    .navigationSubtitle("Fetched from \(webdavURL)\(selectedKuotesFolderPath)")
                }
            }
            Tab("Folders", systemImage: "folder.fill") {
                NavigationStack {
                    VStack {
                        List {
                            ForEach(folders) { folder in
                                NavigationLink {
                                    Text(folder.href.absoluteString)
                                        .fontWeight(.bold)
                                    Button("Select this folder") {
                                        selectedKuotesFolderPath = folder.href.absoluteString
                                    }
                                } label: {
                                    Text(folder.name)
                                }
                            }
                            Text("Only the top-level folder will be listed here. Set the URL manually when using a subfolder.")
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                        .task { await reloadFolders() }
                        .refreshable { await reloadFolders() }
                        .navigationTitle("Select Kuotes Folder")
                        .navigationSubtitle("Or set the absolute URL in Settings")
                    }
                }
            }
            Tab("Settings", systemImage: "gearshape.fill") {
               SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Folder.self, Kuote.self], inMemory: true)
}
