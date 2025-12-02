//
//  KuoteTypes.swift
//  kuotes
//
//  Created by Nico Stern on 16.11.25.
//

import AppIntents
import Foundation
import SwiftUI

// for convenience init when fetching
struct KuoteData: Decodable {
    let datetime: String  // has to be parsed to datetime

    let pageno: Int
    let chapter: String
    let text: String

    let drawer: String  // has to be parsed to DrawerType
    let color: String  // has to be parsed to ColorType
}

// CaseIterable: ermöglicht alle Fälle als Collection bekommbar
// CaseDisplayRepresentable: macht AppIntents-kompatibel: wie jeder Fall in UI angezeigt
// AppEnum: macht als Paramter verfügbar
enum ColorType: String, AppEnum, Codable, CaseIterable, CaseDisplayRepresentable
{
    case gray
    case red
    case orange
    case yellow
    case green
    case cyan
    case blue
    case olive
    case purple

    var swiftUIColor: Color {
        switch self {
        case .gray: return .gray
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .cyan: return .cyan
        case .blue: return .blue
        case .olive: return .indigo
        case .purple: return .purple
        }
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .gray: .init(stringLiteral: "Gray"),
            .red: .init(stringLiteral: "Red"),
            .orange: .init(stringLiteral: "Orange"),
            .yellow: .init(stringLiteral: "Yellow"),
            .green: .init(stringLiteral: "Green"),
            .cyan: .init(stringLiteral: "Cyan"),
            .blue: .init(stringLiteral: "Blue"),
            .olive: .init(stringLiteral: "Olive"),
            .purple: .init(stringLiteral: "Purple"),
        ]
    }

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Color")
    }
}

enum DrawerType: String, AppEnum, Codable, CaseIterable,
    CaseDisplayRepresentable
{
    case lighten
    case underline
    case strikethrough
    case invert

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .lighten: .init(stringLiteral: "Lighten"),
            .underline: .init(stringLiteral: "Underline"),
            .strikethrough: .init(stringLiteral: "Strikethrough"),
            .invert: .init(stringLiteral: "Invert"),
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
