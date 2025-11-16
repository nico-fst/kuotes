//
//  FileItem.swift
//  kuotes
//
//  Created by Nico Stern on 16.11.25.
//

import SwiftData
import Foundation

@Model
final class FileItem {
    var name: String
    var displayName: String // ohne Endung(en)
    var href: URL
    
    init(name: String, displayName: String, href: URL) {
        self.name = name
        self.displayName = displayName
        self.href = href
    }
}
