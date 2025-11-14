//
//  Fetch.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import Foundation
import SwiftSoup
import SwiftUI
import SwiftData

class KuotesService {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("webdavURL") var webdavURL: String = ""
    @AppStorage("webdavUsername") var webdavUsername: String = ""
    
    static let shared = KuotesService()
    
    private func makeURL(from endpoint: String) -> URL? {
        if let url = URL(string: endpoint), url.scheme != nil {
            return url  // schon absolute URL
        } else {
            return URL(string: endpoint, relativeTo: URL(string: webdavURL))
        }
    }
    
    // from ist externes Label - intern endpoint
    func fetch<T: Decodable>(from endpoint: String) async throws -> T {
        guard let url = makeURL(from: endpoint) else { throw URLError(.badURL) }
        
        let pw = KeychainHelper.read("webdavPassword") ?? ""
        let loginString = "\(webdavUsername):\(pw)"
        var req = URLRequest(url: url)
        req.setValue("Basic \(Data(loginString.utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: req) // actual fetch
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func fetchHTML(from endpoint: String) async throws -> Document {
        guard let url = makeURL(from: endpoint) else { throw URLError(.badURL) }
        
        let pw = KeychainHelper.read("webdavPassword") ?? ""
        let loginString = "\(webdavUsername):\(pw)"
        var req = URLRequest(url: url)
        req.setValue("Basic \(Data(loginString.utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: req) // actual fetch
        
        let html = String(data: data, encoding: .utf8) ?? ""
        return  try SwiftSoup.parse(html)
    }
    
    func fetchFolder(from endpoint: String) async throws -> [Folder] {
        let doc = try await fetchHTML(from: endpoint)
        let links = try doc.select("pre a")
        
        var folders: [Folder] = []
        
        for link in links.array() {
            // URL nur wenn gültig entpackt
            if let href = try URL(string: link.attr("href")) {
                let text = try link.text()
                
                folders.append(Folder(name: text, href: href))
            }
        }
        
        return folders
    }
    
    func fetchKuoteFiles(from endpoint: String) async throws -> [FileItem] {
        do {
            let doc = try await fetchHTML(from: endpoint)
            let links = try doc.select("pre a")
            
            var jsonFiles: [FileItem] = []
            
            for link in links.array() {
                let href = try link.attr("href")
                guard href.hasSuffix(".json") else { continue }
                
                if let url = URL(string: href) {
                    let name = try link.text()
                    let displayName = name.split(separator: ".").first.map(String.init) ?? name
                    let file = FileItem(name: name, displayName: displayName, href: url)
                    jsonFiles.append(file)
                }
            }
            return jsonFiles
        } catch {
            print("Error fetching Kuote JSON Files: ", error)
            return []
        }
    }
    
    func fetchKuotesForFiles(for files: [FileItem]) async throws -> [Kuote] {
        do {
            var res: [Kuote] = []
            
            for file in files {
                let kuotes: [KuoteData] = try await fetch(from: file.href.absoluteString)
                for kuote in kuotes {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    if let date = formatter.date(from: kuote.datetime) {
                        let newKuote = Kuote(datetime: date, fileItem: file, pageno: kuote.pageno, chapter: kuote.chapter, text: kuote.text, drawer: kuote.drawer, color: kuote.color)
                        print(newKuote.chapter)
                        res.append(newKuote)
                    }
                }
            }
            return res
        } catch {
            print("Erorr fetching Kuotes for files: ", error)
            return []
        }
    }
    
    func getAllKuotes() -> [Kuote]? {
        do {
            return try modelContext.fetch(FetchDescriptor<Kuote>())
        } catch {
            return nil
        }
    }
}
