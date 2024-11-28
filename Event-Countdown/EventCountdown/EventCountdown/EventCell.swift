//
//  EventCell.swift
//  EventCountdown
//
//  Created by Shubham Tripathi on 15/07/24.
//

import SwiftUI

struct EventCell: View {
    var event: Event
    
    @State private var currentDate = Date.now
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Text(event.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(event.textColor)
                .bold()
                .font(.title2)
                .padding(.leading)
            Text(RelativeDateTimeFormatter().localizedString(for: event.date, relativeTo: currentDate))
                .onReceive(timer) { input in
                    currentDate = input
                }
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
        }
    }
}

#Preview {
    EventCell(event: Event(title: "Party-1", date: Date.now, textColor: Color.red))
}
