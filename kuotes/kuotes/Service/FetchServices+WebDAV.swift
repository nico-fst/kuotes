//
//  FetchServices+WebDAV.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import Foundation

extension FetchServices {
    /// Creates a URL from the given endpoint string.
    /// - Parameter endpoint: The endpoint string which can be absolute or relative.
    /// - Returns: A URL if the endpoint is valid, otherwise nil.
    func makeURL(from endpoint: String) -> URL? {
        if let url = URL(string: endpoint), url.scheme != nil {
            return url
        } else {
            return URL(string: endpoint, relativeTo: URL(string: webdavURL))
        }
    }

    /// Fetches and decodes JSON data from the specified endpoint.
    /// - Parameter endpoint: The endpoint string to fetch JSON from.
    /// - Throws: An error if the URL is invalid or the data cannot be decoded.
    /// - Returns: A decoded object of type T.
    func fetchJSON<T: Decodable>(from endpoint: String) async throws -> T {
        guard let url = makeURL(from: endpoint) else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.setValue(
            "Basic \(webdavCredentials.base64EncodedString())",
            forHTTPHeaderField: "Authorization"
        )

        let (data, _) = try await URLSession.shared.data(for: req)

        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Uploads JSON data to the specified endpoint using a PUT request.
    /// - Parameters:
    ///   - value: The encodable value that should be stored as JSON.
    ///   - endpoint: The target endpoint string.
    func putJSON<T: Encodable>(_ value: T, to endpoint: String) async throws {
        guard let url = makeURL(from: endpoint) else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue(
            "Basic \(webdavCredentials.base64EncodedString())",
            forHTTPHeaderField: "Authorization"
        )
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        req.httpBody = try encoder.encode(value)

        let (_, resp) = try await URLSession.shared.data(for: req)

        guard let httpResp = resp as? HTTPURLResponse,
            (200...299).contains(httpResp.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
    }

    /// Sends a PROPFIND request to the given endpoint to retrieve XML response.
    /// - Parameters:
    ///   - endpoint: The endpoint string to send the PROPFIND request to.
    ///   - depth: The depth header value for the PROPFIND request (default is "5").
    /// - Throws: An error if the URL is invalid or the server response is invalid.
    /// - Returns: The XML response as a string.
    func propfind(from endpoint: String, depth: String = "5") async throws
        -> String
    {
        guard let url = makeURL(from: endpoint) else { throw URLError(.badURL) }
        var req = URLRequest(url: url)

        req.httpMethod = "PROPFIND"
        req.setValue(depth, forHTTPHeaderField: "Depth")
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.setValue(
            "Basic \(webdavCredentials.base64EncodedString())",
            forHTTPHeaderField: "Authorization"
        )

        let xmlBody = """
            <?xml version="1.0"?>
            <propfind xmlns="DAV:">
              <allprop/>
            </propfind>
            """
        req.httpBody = xmlBody.data(using: .utf8)

        let (data, resp) = try await URLSession.shared.data(for: req)

        guard resp is HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        return String(data: data, encoding: .utf8) ?? ""
    }

    private var webdavCredentials: Data {
        let pw = KeychainHelper.read("webdavPassword") ?? ""
        return Data("\(webdavUsername):\(pw)".utf8)
    }
}
