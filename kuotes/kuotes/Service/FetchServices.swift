//
//  FetchServices.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import Foundation
import SwiftUI
import SwiftData
import Fuzi

class FetchServices {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("webdavURL") var webdavURL: String = ""
    @AppStorage("webdavUsername") var webdavUsername: String = ""
    @Query private var kuotes: [Kuote]
    
    static let shared = FetchServices()
    
    /// Fetches folders from the specified endpoint using a PROPFIND request.
    /// - Parameter endpoint: The endpoint string to fetch folders from.
    /// - Throws: An error if fetching or parsing fails.
    /// - Returns: An array of Folder objects.
    func fetchFolders(endpoint: String) async throws -> [Folder] {
        let respXML = try await propfind(from: endpoint)
        let folders = parseFoldersFromXML(xml: respXML)
        
        return folders
    }
    
    /// Fetches Kuote objects from the specified endpoint.
    /// - Parameter endpoint: The endpoint string to fetch Kuotes from.
    /// - Throws: An error if fetching or parsing fails.
    /// - Returns: An array of Kuote objects.
    func fetchKuotes(endpoint: String) async throws -> [Kuote] {
        let respXML = try await propfind(from: endpoint, depth: "1")
        let files = parseFilesFromXML(xml: respXML)
        let newKuotes: [Kuote] = try await extractKuotesFromFiles(files: files)
        
        
        return newKuotes
    }
    
    /// Retrieves a Kuote object by its string ID.
    /// - Parameter id: The string representation of the Kuote's UUID.
    /// - Returns: A Kuote object if found, otherwise nil.
    func getKuote(id: String) -> Kuote? {
        if let uuid = UUID(uuidString: id) {
            if let match = kuotes.first(where: { $0.id == uuid }) {
                return match
            }
        }
        return nil
    }
    
    
    // ----------------------------------------------
    // HELPER
    // ----------------------------------------------
    
    
    /// Extracts Kuote objects from the given list of FileItem objects by fetching and decoding their JSON content.
    /// - Parameter files: An array of FileItem objects to extract Kuotes from.
    /// - Throws: An error if fetching or decoding fails.
    /// - Returns: An array of Kuote objects extracted from the files.
    func extractKuotesFromFiles(files: [FileItem]) async throws -> [Kuote] {
        var res: [Kuote] = []
        
        for file in files {
            do {
                let kuotes: [KuoteData] = try await fetchJSON(from: file.href.absoluteString)

                for kuote in kuotes {
                    // using convenience init for parsing fields
                    if let newKuote = Kuote(data: kuote, fileItem: file) {
                        res.append(newKuote)
                    } else {
                        print("Skipping invalid Kuote in file: \(file.name)")
                    }
                }
            } catch {
                print("Skipping parsing Kuotes from file \(file.name) due to decode error")
            }
        }
        return res
    }
    
    /// Creates a URL from the given endpoint string.
    /// - Parameter endpoint: The endpoint string which can be absolute or relative.
    /// - Returns: A URL if the endpoint is valid, otherwise nil.
    fileprivate func makeURL(from endpoint: String) -> URL? {
        if let url = URL(string: endpoint), url.scheme != nil {
            return url  // schon absolute URL
        } else {
            return URL(string: endpoint, relativeTo: URL(string: webdavURL))
        }
    }
    
    /// Fetches and decodes JSON data from the specified endpoint.
    /// - Parameter endpoint: The endpoint string to fetch JSON from.
    /// - Throws: An error if the URL is invalid or the data cannot be decoded.
    /// - Returns: A decoded object of type T.
    fileprivate func fetchJSON<T: Decodable>(from endpoint: String) async throws -> T {
        guard let url = makeURL(from: endpoint) else { throw URLError(.badURL) }
        
        let pw = KeychainHelper.read("webdavPassword") ?? ""
        let loginString = "\(webdavUsername):\(pw)"
        var req = URLRequest(url: url)
        req.setValue("Basic \(Data(loginString.utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: req) // actual fetch
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    /// Sends a PROPFIND request to the given endpoint to retrieve XML response.
    /// - Parameters:
    ///   - endpoint: The endpoint string to send the PROPFIND request to.
    ///   - depth: The depth header value for the PROPFIND request (default is "5").
    /// - Throws: An error if the URL is invalid or the server response is invalid.
    /// - Returns: The XML response as a string.
    fileprivate func propfind(from endpoint: String, depth: String = "5") async throws -> String {
        guard let url = makeURL(from: endpoint) else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        
        // WebDAV Configs
        req.httpMethod = "PROPFIND"
        req.setValue(depth, forHTTPHeaderField: "Depth")
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        
        // Minimaler Body (sonst liefern viele Server keine Props)
        let xmlBody = """
        <?xml version="1.0"?>
        <propfind xmlns="DAV:">
          <allprop/>
        </propfind>
        """
        req.httpBody = xmlBody.data(using: .utf8)
        
        // Basic Auth
        let pw = KeychainHelper.read("webdavPassword") ?? ""
        let loginString = "\(webdavUsername):\(pw)"
        req.setValue("Basic \(Data(loginString.utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        guard let http = resp as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    /// Parses folder information from the given XML string.
    /// - Parameter xml: The XML string to parse.
    /// - Returns: An array of Folder objects parsed from the XML.
    fileprivate func parseFoldersFromXML(xml: String) -> [Folder] {
        let doc = try! XMLDocument(string: xml)
        
        // Use namespace-agnostic XPath with local-name()
        return doc.xpath("//*[local-name()='response']").compactMap { (r) -> Folder? in
            // nur Folder behandeln
            let isDir = r.firstChild(
                xpath: "*[local-name()='propstat']/*[local-name()='prop']/*[local-name()='resourcetype']/*"
            ) != nil
            guard isDir else { return nil }
            
            // href Ordners extrahieren
            guard let hrefString = r.firstChild(xpath: "*[local-name()='href']")?.stringValue,
                  let href = URL(string: hrefString)
            else { return nil }
            
            // lesbaren Ordnername ableiten, dekodieren: $20 -> space
            let folderName = href.lastPathComponent.removingPercentEncoding ?? href.lastPathComponent
            
            return Folder(name: folderName, href: href)
        }
    }
    
    /// Parses file information from the given XML string.
    /// - Parameter xml: The XML string to parse.
    /// - Returns: An array of FileItem objects parsed from the XML.
    fileprivate func parseFilesFromXML(xml: String) -> [FileItem] {
        let doc = try! XMLDocument(string: xml)
        
        // Use namespace-agnostic XPath with local-name()
        return doc.xpath("//*[local-name()='response']").compactMap { (r) -> FileItem? in
            // nur Nicht-Folder behandeln
            let isDir = r.firstChild(
                xpath: "*[local-name()='propstat']/*[local-name()='prop']/*[local-name()='resourcetype']/*"
            ) != nil
            guard !isDir else { return nil }
            
            // href FileItems extrahieren
            guard let hrefString = r.firstChild(xpath: "*[local-name()='href']")?.stringValue,
                  let href = URL(string: hrefString)
            else { return nil }
            
            // lesbaren Ordnername ableiten, dekodieren: $20 -> space
            let name = href.lastPathComponent.removingPercentEncoding ?? href.lastPathComponent
            
            // ... und ohne Dateiendung
            guard name.hasSuffix(".json") else { return nil }
            let displayName = name.split(separator: ".").first.map(String.init) ?? name
            
            return FileItem(name: name, displayName: displayName, href: href)
        }
    }
}
