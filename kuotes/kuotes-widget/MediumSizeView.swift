//
//  MediumSizeView.swift
//  kuotes-widgetExtension
//
//  Created by Nico Stern on 14.11.25.
//

import SwiftUI
import WidgetKit

struct MediumSizeView: View {
    var entry: KuoteEntry
    
    func fontSize(for text: String) -> CGFloat {
        switch text.count {
        case 0...25:
            return 32
        case 26...50:
            return 27
        case 51...100:
            return 22
        case 101...150:
            return 20
        case 151...200:
            return 15
        case 201...:
            return 12
        default:
            return 12
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let displayNameHeight: CGFloat = 24
            
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 4) {
                    Spacer()
                    
                    Text(entry.kuote.fileItem.displayName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(0.3)
                        .lineLimit(1)
                        .frame(width: geometry.size.width * 0.9, height: displayNameHeight, alignment: .leading)
                    Text("\(entry.kuote.text)")
//                        .font(.system(size: fontSize(for: entry.kuote.text)))
                        .lineLimit(4)
                        .foregroundColor(.white)
                        .opacity(0.6)
                        .lineLimit(3)
                    Text("\(entry.kuote.chapter) ⋅ page \(entry.kuote.pageno)")
                        .font(.system(size: 12))
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .opacity(0.3)
                    
                    Spacer()
                }
                .containerBackground(for: .widget) {
                    ContainerRelativeShape()
                        .fill(Color(red: 0x29/255, green: 0x29/255, blue: 0x28/255))
                }
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
