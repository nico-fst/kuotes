//
//  FetchServices+Kuotes.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import Foundation
import Fuzi

extension FetchServices {
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

    /// Extracts Kuote objects from the given list of FileItem objects by fetching and decoding their JSON content.
    /// - Parameter files: An array of FileItem objects to extract Kuotes from.
    /// - Throws: An error if fetching or decoding fails.
    /// - Returns: An array of Kuote objects extracted from the files.
    func extractKuotesFromFiles(files: [FileItem]) async throws -> [Kuote] {
        var res: [Kuote] = []

        for file in files {
            do {
                let kuotes: [KuoteData] = try await fetchJSON(
                    from: file.href.absoluteString
                )

                for kuote in kuotes {
                    if let newKuote = Kuote(data: kuote, fileItem: file) {
                        res.append(newKuote)
                    } else {
                        print("Skipping invalid Kuote in file: \(file.name)")
                    }
                }
            } catch {
                print(
                    "Skipping parsing Kuotes from file \(file.name) due to decode error:",
                    error
                )
            }
        }
        return res
    }

    /// Parses file information from the given XML string.
    /// - Parameter xml: The XML string to parse.
    /// - Returns: An array of FileItem objects parsed from the XML.
    func parseFilesFromXML(xml: String) -> [FileItem] {
        let doc = try! XMLDocument(string: xml)

        return doc.xpath("//*[local-name()='response']").compactMap {
            (r) -> FileItem? in
            let isDir =
                r.firstChild(
                    xpath:
                        "*[local-name()='propstat']/*[local-name()='prop']/*[local-name()='resourcetype']/*"
                ) != nil
            guard !isDir else { return nil }

            guard
                let hrefString = r.firstChild(xpath: "*[local-name()='href']")?
                    .stringValue,
                let href = URL(string: hrefString)
            else { return nil }

            let name =
                href.lastPathComponent.removingPercentEncoding
                ?? href.lastPathComponent

            guard name.hasSuffix(".json") else { return nil }
            let baseName =
                name.split(separator: ".").first.map(String.init) ?? name
            let displayName = baseName.replacingOccurrences(of: "_", with: " ")

            return FileItem(name: name, displayName: displayName, href: href)
        }
    }
}
