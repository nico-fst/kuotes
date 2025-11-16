//
//  SimpleEntry.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import WidgetKit

struct KuoteEntry: TimelineEntry {
    let date: Date
    let kuote: Kuote
    let configuration: ConfigurationAppIntent
}
