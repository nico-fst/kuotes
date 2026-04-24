//
//  FetchServices+Highlights.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import Foundation

private struct HighlightFileEntry: Codable {
    let chapter: String
    let pos1: String?
    var color: String
    var drawer: String
    let page: String?
    let pageno: Int
    let pos0: String?
    let text: String
    let datetime: String
    var datetime_updated: String?
}

extension FetchServices {
    /// Updates the color of a single highlight in its source JSON file.
    /// - Parameters:
    ///   - kuote: The kuote whose highlight color should be updated.
    ///   - newColor: The new color. Must be one of the supported `ColorType` values.
    /// - Returns: `true` if a matching highlight was found, otherwise `false`.
    func updateHighlightColor(for kuote: Kuote, to newColor: ColorType) async throws
        -> Bool
    {
        try await updateHighlight(for: kuote) { highlight in
            guard highlight.color != newColor.rawValue else { return false }
            highlight.color = newColor.rawValue
            return true
        }
    }

    /// Updates the drawer type of a single highlight in its source JSON file.
    /// - Parameters:
    ///   - kuote: The kuote whose drawer type should be updated.
    ///   - newDrawer: The new drawer type. It is written using the highlight file naming.
    /// - Returns: `true` if a matching highlight was found, otherwise `false`.
    func updateHighlightDrawer(for kuote: Kuote, to newDrawer: DrawerType)
        async throws -> Bool
    {
        try await updateHighlight(for: kuote) { highlight in
            let mappedDrawer = mappedHighlightDrawerName(for: newDrawer)
            guard highlight.drawer != mappedDrawer else { return false }
            highlight.drawer = mappedDrawer
            return true
        }
    }

    /// Deletes a single highlight from its source JSON file.
    /// - Parameter kuote: The kuote whose highlight should be deleted.
    /// - Returns: `true` if a matching highlight was found and deleted, otherwise `false`.
    func deleteHighlight(for kuote: Kuote) async throws -> Bool {
        var highlights: [HighlightFileEntry] = try await fetchJSON(
            from: kuote.fileItem.href.absoluteString
        )

        guard let highlightIndex = indexOfHighlight(for: kuote, in: highlights)
        else {
            return false
        }

        highlights.remove(at: highlightIndex)
        try await putJSON(highlights, to: kuote.fileItem.href.absoluteString)
        return true
    }

    private func updateHighlight(
        for kuote: Kuote,
        applyChange: (inout HighlightFileEntry) -> Bool
    ) async throws -> Bool {
        var highlights: [HighlightFileEntry] = try await fetchJSON(
            from: kuote.fileItem.href.absoluteString
        )

        guard let highlightIndex = indexOfHighlight(for: kuote, in: highlights)
        else {
            return false
        }

        let didChange = applyChange(&highlights[highlightIndex])
        guard didChange else { return true }

        highlights[highlightIndex].datetime_updated =
            highlightTimestampFormatter.string(from: Date())

        try await putJSON(highlights, to: kuote.fileItem.href.absoluteString)
        return true
    }

    private func indexOfHighlight(
        for kuote: Kuote,
        in highlights: [HighlightFileEntry]
    ) -> Int? {
        let kuoteTimestamp = highlightTimestampFormatter.string(from: kuote.datetime)
        return highlights.firstIndex {
            $0.datetime == kuoteTimestamp
                && $0.chapter == kuote.chapter
                && $0.text == kuote.text
                && $0.pageno == kuote.pageno
        }
    }

    private func mappedHighlightDrawerName(for drawer: DrawerType) -> String {
        switch drawer {
        case .lighten:
            return "lighten"
        case .underline:
            return "underscore"
        case .strikethrough:
            return "strikeout"
        case .invert:
            return "invert"
        }
    }
}
