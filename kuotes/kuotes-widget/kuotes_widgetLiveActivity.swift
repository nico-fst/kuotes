//
//  kuotes_widgetLiveActivity.swift
//  kuotes-widget
//
//  Created by Nico Stern on 13.11.25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct kuotes_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct kuotes_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: kuotes_widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension kuotes_widgetAttributes {
    fileprivate static var preview: kuotes_widgetAttributes {
        kuotes_widgetAttributes(name: "World")
    }
}

extension kuotes_widgetAttributes.ContentState {
    fileprivate static var smiley: kuotes_widgetAttributes.ContentState {
        kuotes_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: kuotes_widgetAttributes.ContentState {
         kuotes_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: kuotes_widgetAttributes.preview) {
   kuotes_widgetLiveActivity()
} contentStates: {
    kuotes_widgetAttributes.ContentState.smiley
    kuotes_widgetAttributes.ContentState.starEyes
}
