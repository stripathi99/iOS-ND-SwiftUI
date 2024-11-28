//
//  ContentView.swift
//  EventCountdown
//
//  Created by Shubham Tripathi on 15/07/24.
//

import SwiftUI

struct EventsView: View {
    @State var events: [Event]
    
    var body: some View {
        NavigationStack {
            listContentView
                .navigationTitle("Events")
                .toolbar {
                    if !events.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink(value: EventForm.Mode.add) {
                                Label("Add", systemImage: "plus")
                            }
                        }
                    }
                }
                .navigationDestination(for: EventForm.Mode.self) { mode in
                    EventForm(with: mode) { event in
                        save(event)
                    }
                }
        }
    }
    
    @ViewBuilder
    private var listContentView: some View {
        if events.isEmpty {
            emptyEventsView // shows no content available view
        } else {
            List {
                ForEach(events.sorted()) { // events sorted in ascending order of Date.
                    event in
                    NavigationLink(value: EventForm.Mode.edit(event)) {
                        EventCell(event: event)
                    }
                }.onDelete() { indexSet in
                    events.remove(atOffsets: indexSet)
                }
            }
        }
    }
    
    private var emptyEventsView: some View {
        ContentUnavailableView(
            label: {
                Label("No Events", systemImage: "list.clipboard")
            },
            description: {
                Text("Events you add will appear here.")
            },
            actions: {
                NavigationLink(value: EventForm.Mode.add) {
                    Label("Add", systemImage: "plus")
                }
            }
        )
    }
    
    // updates and/or saves event returned via onSave closure of EventForm
    private func save(_ eventToSave: Event) {
        if let idx = events.firstIndex(where: { $0.id == eventToSave.id }) {
            events[idx] = eventToSave
        } else {
            events.append(eventToSave)
        }
    }
}

#Preview {
    EventsView(events: [
        Event(title: "Halloween 🎃", date: Date.now, textColor: Color.orange),
        Event(title: "Christmas 🎄", date: Date.now, textColor: Color.green),
        Event(title: "New Year's Eve 🥳", date: Date.now, textColor: Color.yellow),
        Event(title: "Independance Day 🇮🇳", date: Date.now, textColor: Color.indigo)
    ])
}
