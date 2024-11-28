//
//  EventCountdownApp.swift
//  EventCountdown
//
//  Created by Shubham Tripathi on 15/07/24.
//

import SwiftUI

@main
struct EventCountdownApp: App {
    var body: some Scene {
        WindowGroup {
            EventsView(events: [
                Event(title: "Halloween 🎃", date: Date.now, textColor: Color.orange),
                Event(title: "Christmas 🎄", date: Date.now, textColor: Color.green),
                Event(title: "New Year's Eve 🥳", date: Date.now, textColor: Color.yellow),
                Event(title: "Independance Day 🇮🇳", date: Date.now, textColor: Color.indigo)
            ])
        }
    }
}
