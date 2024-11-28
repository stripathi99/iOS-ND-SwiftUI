//
//  EventForm.swift
//  EventCountdown
//
//  Created by Shubham Tripathi on 15/07/24.
//

import SwiftUI

struct EventForm: View {
    enum Mode: Hashable {
        case add
        case edit(Event)
    }
    
    @State private var title: String
    @State private var date: Date
    @State private var textColor: Color
    @State private var navTitle: String
    
    @Environment(\.presentationMode) var presentationMode
    
    let mode: Mode
    let onSave: ((Event) -> Void) // closure called via save button
    
    init(with mode: Mode, onSave: @escaping ((Event) -> Void)) {
        self.mode = mode
        self.onSave = onSave
        
        switch mode {
        case .add:
            _title = .init(initialValue: "")
            _date = .init(initialValue: Date.now)
            _textColor = .init(initialValue: Color.black)
            _navTitle = .init(initialValue: "Add Event")
        case .edit(let event):
            _title = .init(initialValue: event.title)
            _date = .init(initialValue: event.date)
            _textColor = .init(initialValue: event.textColor)
            _navTitle = .init(initialValue: "Edit \(event.title)")
        }
    }
    
    var body: some View {
        Form {
            TextField("Event Title", text: $title)
                .foregroundColor($textColor.wrappedValue)
            DatePicker("Date", selection: $date)
            ColorPicker("Text Color", selection: $textColor)
        }
        .navigationTitle($navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .tint($textColor.wrappedValue)
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", systemImage: "square.and.arrow.down") {
                    switch mode {
                    case .add: // save new event
                        onSave(Event(title: $title.wrappedValue, date: $date.wrappedValue, textColor: $textColor.wrappedValue))
                    case .edit(var eventToEdit): // update the current event
                        eventToEdit.title = $title.wrappedValue
                        eventToEdit.textColor = $textColor.wrappedValue
                        eventToEdit.date = $date.wrappedValue
                        onSave(eventToEdit)
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }
                .disabled($title.wrappedValue.isEmpty)
            }
        }
    }
}
