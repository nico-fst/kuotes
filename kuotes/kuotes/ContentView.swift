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
    
    @State private var selectedKuote: Kuote? = nil
    
    func reloadFolders() async {
        do {
            // alte folder löschen
            let oldFolders = try modelContext.fetch(FetchDescriptor<Folder>())
            for folder in oldFolders {
                modelContext.delete(folder)
            }
            
            // neue folder speichern
            let folders = try await KuotesService.shared.fetchFolder(from: "/")
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
            let kuoteFiles: [FileItem] = try await KuotesService.shared.fetchKuoteFiles(from: selectedKuotesFolderPath)
            let newKuotes: [Kuote] = try await KuotesService.shared.fetchKuotesForFiles(for: kuoteFiles)
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
                                    .fontWeight(.bold)
                                Text(kuote.chapter)
                                    .italic()
                                Text(kuote.text)
                                    .lineLimit(2)
                            }
                            .onTapGesture {
                                selectedKuote = kuote
                            }
                            Button("Open Kuote in App") {
                                let urlString = "kuotes://kuote/\(kuote.id.uuidString.lowercased())"
                                print("Trying to open URL: \(urlString)")

                                if let url = URL(string: urlString) {
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url) { success in
                                            print("Open URL success: \(success)")
                                        }
                                    } else {
                                        print("Cannot open URL (canOpenURL returned false)")
                                    }
                                } else {
                                    print("Invalid URL: \(urlString)")
                                }
                            }
                        }
                    }
                    .refreshable { await reloadKuotes() }
                    .navigationTitle("Kuotes")
                    .navigationSubtitle("Fetched from \(webdavURL)\(selectedKuotesFolderPath)")
                    .sheet(item: $selectedKuote) { kuote in
                        NavigationStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Spacer()
                                
                                Text(kuote.chapter)
                                    .font(.headline)
                                    .italic()
                                
                                Text(kuote.text)
                                Text("On page \(String(kuote.pageno))")
                                    .font(.subheadline)
                                    .opacity(0.3)
                                
                                Spacer()
                            }
                            .navigationTitle(kuote.fileItem.displayName)
                            .padding()
                        }
                        .presentationDetents([.medium, .large])
                        .onOpenURL { url in
                            guard
                                url.scheme == "kuotes",
                                url.host == "kuote",
                                url.pathComponents.count > 1
                            else {
                                print("Error opening link: \(url)")
                                return
                            }
                            let id = url.pathComponents[1]
                            
                            selectedKuote = KuotesService.shared.getKuote(id: id)
                        }
                    }
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
