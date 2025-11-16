//
//  Item.swift
//  kuotes
//
//  Created by Nico Stern on 13.11.25.
//

import Foundation
import SwiftData
import SwiftUI
import AppIntents

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

// for convenience init when fetching
struct KuoteData: Decodable {
    let datetime: String // has to be parsed to datetime
    
    let pageno: Int
    let chapter: String
    let text: String
    
    let drawer: String // has to be parsed to DrawerType
    let color: String // has to be parsed to ColorType
}

// CaseIterable: ermöglicht alle Fälle als Collection bekommbar
// CaseDisplayRepresentable: macht AppIntents-kompatibel: wie jeder Fall in UI angezeigt
// AppEnum: macht als Paramter verfügbar
enum ColorType: String, AppEnum, Codable, CaseIterable, CaseDisplayRepresentable {
    case red
    case orange
    case yellow
    case green
    case olive
    case cyan
    case blue
    case purple
    case gray
    
    var swiftUIColor: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .olive: return .indigo
        case .cyan: return .cyan
        case .blue: return .blue
        case .purple: return .purple
        case .gray: return .gray
        }
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .red: .init(stringLiteral: "Red"),
            .orange: .init(stringLiteral: "Orange"),
            .yellow: .init(stringLiteral: "Yellow"),
            .green: .init(stringLiteral: "Green"),
            .olive: .init(stringLiteral: "Olive"),
            .cyan: .init(stringLiteral: "Cyan"),
            .blue: .init(stringLiteral: "Blue"),
            .purple: .init(stringLiteral: "Purple"),
            .gray: .init(stringLiteral: "Gray")
        ]
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Color")
    }
}

enum DrawerType: String, AppEnum, Codable, CaseIterable, CaseDisplayRepresentable {
    case lighten
    case underline
    case strikethrough
    case invert
    
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .lighten: .init(stringLiteral: "Lighten"),
            .underline: .init(stringLiteral: "Underline"),
            .strikethrough: .init(stringLiteral: "Strikethrough"),
            .invert: .init(stringLiteral: "Invert")
        ]
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Type of Highlight")
    }
}

extension DrawerType {
    // since Highlight Sync Plugin saves using different names
    init(toMapped: String) {
        switch toMapped {
        case "lighten": self = .lighten
        case "underscore": self = .underline
        case "strikeout": self = .strikethrough
        case "invert": self = .invert
        default: self = .lighten
        }
    }
}

@Model
final class Kuote: Identifiable {
    var id = UUID()
    
    var datetime: Date // e.g. "2025-10-23 01:26:17"
    var fileItem: FileItem
    
    var pageno: Int // e.g. 21
    var chapter: String // e.g. "Krieg der Geschlechter"
    var text: String // e.g. "Um das Geschlecht eines Produktnamens bestimmen zu können, muss man sich Klarheit darüber verschaffen, was das Produkt darstellt.\nNamen wie Colgate, Blendamed, Sensodyne, Elmex und Dentagard sind weiblich, weil sie für die weiblichen Begriffe Zahnpasta und Zahncreme stehen."
    
    var drawer: DrawerType // e.g. "lighten"
    var color: ColorType // e.g. "gray"
    
//    var pos0: String // e.g. "/body/DocFragment[2]/body/p[375]/text().23"
//    var page: String // e.g. "/body/DocFragment[2]/body/p[375]/text().23"
//    var pos1: String // e.g. "/body/DocFragment[2]/body/p[376]/text().145"
    
    init(datetime: Date, fileItem: FileItem, pageno: Int, chapter: String, text: String, drawer: DrawerType, color: ColorType) {
        self.datetime = datetime
        self.fileItem = fileItem
        self.pageno = pageno
        self.chapter = chapter
        self.text = text
        self.drawer = drawer
        self.color = color
    }
}

extension Kuote {
    // normal aufrufbar, parst date, color, drawer
    convenience init?(data: KuoteData, fileItem: FileItem) {
        // date: try String -> Date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = formatter.date(from: data.datetime) else { return nil }
        
        // Color: String -> ColorType
        let colorEnum = ColorType(rawValue: data.color) ?? .gray
        
        // Drawer: String -> DrawerType
        let drawerEnum = DrawerType(toMapped: data.drawer) // uses init correcting String names from Sync Highlights Plugin
        print(data.drawer, "->", drawerEnum)
        
        self.init(datetime: date,
                  fileItem: fileItem,
                  pageno: data.pageno,
                  chapter: data.chapter,
                  text: data.text,
                  drawer: drawerEnum,
                  color: colorEnum
        )
    }
    
    static var templateShort: Kuote {
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
            drawer: .lighten,
            color: .gray
        )
    }
    
    static var templateLong: Kuote {
        Kuote(
            datetime: Date(),
            fileItem: FileItem(
                name: "Bastian Sick - Dativ ist dem Genitiv sein Tod.sdr.json",
                displayName: "Bastian Sick - Dativ ist dem Genitiv sein Tod",
                href: URL(string: "/Documents/Bastian%20Sick%20-%20Dativ%20ist%20dem%20Genitiv%20sein%20Tod.sdr.json")!
            ),
            pageno: 75,
            chapter: "This Chapter is quite long long long oh wow so long long long",
            text: "Bei Zusammensetzungen mit Fremdwörtern gilt: Der Bindestrich dient zur Hervorhebung des Un-bekannten, Unerwarteten, Ungewöhnlichen. Für viele deutschsprachige Menschen sind Wörter wie Computer, Internet und online heute nichts Ungewöhnliches mehr, sodass sie in Zusammensetzungen wie Computerbranche, Internetfirma und Onlinedienste auf den Bindestrich verzichten. Dies entspricht durchaus dem Prinzip der deutschen Sprache: Wortzusammensetzungen, die sich bewährt haben, werden als ein Wort geschrieben.",
            drawer: .lighten,
            color: .gray
        )
    }
}

