//
//  SharedModelConfig.swift
//  kuotes
//
//  Created by Nico Stern on 16.11.25.
//

import Foundation
import SwiftData

struct SharedModelConfig {
    static var schema: Schema {
        Schema([Kuote.self, Folder.self])
    }
    static var config: ModelConfiguration {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.de.nicostern.kuotes")!
            .appendingPathComponent("kuotes.sqlite")
        
        return ModelConfiguration(
            schema: schema,
            url: url
        )
    }
}

extension SharedModelConfig {
    static let sharedContainer: ModelContainer = {
        try! ModelContainer(
            for: schema,
            configurations: [config]
        )
    }()
} 
