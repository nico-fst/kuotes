//
//  KuoteTypes.swift
//  kuotes
//
//  Created by Nico Stern on 16.11.25.
//

import Foundation
import AppIntents
import SwiftUI

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

