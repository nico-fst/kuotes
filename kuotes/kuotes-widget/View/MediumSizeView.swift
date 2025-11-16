//
//  MediumSizeView.swift
//  kuotes-widgetExtension
//
//  Created by Nico Stern on 14.11.25.
//

import SwiftUI
import WidgetKit

struct MediumSizeView: View {
    var entry: Provider.Entry
    
    var body: some View {
        GeometryReader { geometry in
            let displayNameHeight: CGFloat = 24
            
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.kuote.fileItem.displayName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(0.3)
                        .lineLimit(1)
                        .frame(width: geometry.size.width * 0.9, height: displayNameHeight, alignment: .leading)
                    Text("\(entry.kuote.text)")
                        .font(.system(size: 32))
                        .lineLimit(5)
                        .minimumScaleFactor(0.4)
                        .foregroundColor(.white)
                        .opacity(0.6)
                    Text("\(entry.kuote.chapter) ⋅ page \(entry.kuote.pageno)")
                        .font(.system(size: 12))
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .opacity(0.3)
                }
                .containerBackground(for: .widget) {
                    ContainerRelativeShape()
                        .fill(Color(red: 0x29/255, green: 0x29/255, blue: 0x28/255))
                }
                .frame(width: geometry.size.width, height: geometry.size.height) // platziert alles mittig
                
                Text("❞")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(0.3)
                    .frame(height: displayNameHeight)
            }
        }
        .widgetURL(URL(string: "kuotes://kuote/\(entry.kuote.id.uuidString.lowercased())"))
    }
}
