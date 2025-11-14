//
//  Item.swift
//  kuotes
//
//  Created by Nico Stern on 13.11.25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

@Model
final class Folder {
    var name: String
    var href: URL
    
    init(name: String, href: URL) {
        self.name = name
        self.href = href
    }
}

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

struct KuoteData: Decodable {
    let datetime: String // has to be parsed to datetime
    
    let pageno: Int
    let chapter: String
    let text: String
    
    let drawer: String
    let color: String
}

@Model
final class Kuote {
    var datetime: Date
    var fileItem: FileItem
    
    var pageno: Int
    var chapter: String
    var text: String
    
    var drawer: String
    var color: String
    
//    var pos0: String
//    var page: String
//    var pos1: String
    
    init(datetime: Date, fileItem: FileItem, pageno: Int, chapter: String, text: String, drawer: String, color: String) {
        self.datetime = datetime
        self.fileItem = fileItem
        self.pageno = pageno
        self.chapter = chapter
        self.text = text
        self.drawer = drawer
        self.color = color
    }
    
//    //  complete e.g.:
    
//    "pageno": 21,
//    "chapter": "Krieg der Geschlechter",
//    "drawer": "lighten",
//    "datetime": "2025-10-23 01:26:17",
//    "pos0": "/body/DocFragment[2]/body/p[375]/text().23",
//    "page": "/body/DocFragment[2]/body/p[375]/text().23",
//    "pos1": "/body/DocFragment[2]/body/p[376]/text().145",
//    "text": "Um das Geschlecht eines Produktnamens bestimmen zu können, muss man sich Klarheit darüber verschaffen, was das Produkt darstellt.\nNamen wie Colgate, Blendamed, Sensodyne, Elmex und Dentagard sind weiblich, weil sie für die weiblichen Begriffe Zahnpasta und Zahncreme stehen.",
//    "color": "gray"
}

extension Kuote {
    static var templateKuote: Kuote {
        Kuote(
            datetime: Date(),
            fileItem: FileItem(
                name: "Atomic Habits.sdr.json",
                displayName: "Atomic Habits",
                href: URL(string: "/Documents/Bastian%20Sick%20-%20Dativ%20ist%20dem%20Genitiv%20sein%20Tod.sdr.json")!
            ),
            pageno: 38,
            chapter: "Some Chapter",
            text: "Every action you take is a vote for the type of person you wish to become.",
            drawer: "lighten",
            color: "gray"
        )
    }
}
