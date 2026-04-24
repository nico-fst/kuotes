//
//  FetchServices.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import Foundation
import SwiftData
import SwiftUI

class FetchServices {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("webdavURL") var webdavURL: String = ""
    @AppStorage("webdavUsername") var webdavUsername: String = ""
    @Query private var kuotes: [Kuote]

    static let shared = FetchServices()

    let highlightTimestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
