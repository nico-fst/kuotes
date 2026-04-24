//
//  FetchServices+Folders.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import Foundation
import Fuzi

extension FetchServices {
    /// Fetches folders from the specified endpoint using a PROPFIND request.
    /// - Parameter endpoint: The endpoint string to fetch folders from.
    /// - Throws: An error if fetching or parsing fails.
    /// - Returns: An array of Folder objects.
    func fetchFolders(endpoint: String) async throws -> [Folder] {
        let respXML = try await propfind(from: endpoint)
        let folders = parseFoldersFromXML(xml: respXML)

        return folders
    }

    /// Parses folder information from the given XML string.
    /// - Parameter xml: The XML string to parse.
    /// - Returns: An array of Folder objects parsed from the XML.
    func parseFoldersFromXML(xml: String) -> [Folder] {
        let doc = try! XMLDocument(string: xml)

        return doc.xpath("//*[local-name()='response']").compactMap {
            (r) -> Folder? in
            let isDir =
                r.firstChild(
                    xpath:
                        "*[local-name()='propstat']/*[local-name()='prop']/*[local-name()='resourcetype']/*"
                ) != nil
            guard isDir else { return nil }

            guard
                let hrefString = r.firstChild(xpath: "*[local-name()='href']")?
                    .stringValue,
                let href = URL(string: hrefString)
            else { return nil }

            let folderName =
                href.lastPathComponent.removingPercentEncoding
                ?? href.lastPathComponent

            return Folder(name: folderName, href: href)
        }
    }
}
