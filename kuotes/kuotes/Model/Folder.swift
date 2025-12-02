//
//  Folder.swift
//  kuotes
//
//  Created by Nico Stern on 16.11.25.
//

import AppIntents
import SwiftData

@Model
final class Folder {
    var name: String
    var href: URL

    init(name: String, href: URL) {
        self.name = name
        self.href = href
    }
}
