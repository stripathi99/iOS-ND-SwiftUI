//
//  SwiftBitesApp.swift
//  SwiftBites
//
//  Created by Shubham Tripathi on 20/07/24.
//

import SwiftUI
import SwiftData

@main
struct SwiftBitesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(SwiftBitesContainer.create())
        }
    }
}
