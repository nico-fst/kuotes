//
//  Kuote.swift
//  kuotes
//
//  Created by Nico Stern on 16.11.25.
//

import AppIntents
import Foundation
import SwiftData

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
            pageno: 99,
            chapter: "Some Chapter",
            text: "Every action you take is a vote for the type of person you wish to become.",
            drawer: .lighten,
            color: .gray
        )
    }
    
    static var templateMedium: Kuote {
        Kuote(
            datetime: Date(),
            fileItem: FileItem(
                name: "Bastian Sick - Der Dativ ist dem Genitiv sein Tod.sdr.json",
                displayName: "Bastian Sick - Der Dativ ist dem Genitiv sein Tod",
                href: URL(string: "/Documents/Bastian%20Sick%20-%20Dativ%20ist%20dem%20Genitiv%20sein%20Tod.sdr.json")!
            ),
            pageno: 31,
            chapter: "Deutschland, deine Apostroph's",
            text: "Liest man in der Sauna den Hinweis »Kein Schweiß aufs Holz«, so brennt es einem in den Augen. Ebenso beim Anblick von Läden, die »Alles für's Kind« anbieten. Zwar ist der Apostroph hier überflüssig, aber immerhin scheint sich der Schildermaler noch was dabei gedacht zu haben.",
            drawer: .lighten,
            color: .gray
        )
    }
    
    static var templateLong: Kuote {
        Kuote(
            datetime: Date(),
            fileItem: FileItem(
                name: "Bastian Sick - Der Dativ ist dem Genitiv sein Tod.sdr.json",
                displayName: "Bastian Sick - Der Dativ ist dem Genitiv sein Tod",
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

