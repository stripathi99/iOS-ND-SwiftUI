//
//  Event.swift
//  EventCountdown
//
//  Created by Shubham Tripathi on 15/07/24.
//

import Foundation
import SwiftUI

struct Event: Comparable, Identifiable, Hashable {
    let id = UUID()
    var title: String
    var date: Date
    var textColor: Color
    
    static func < (lhs: Event, rhs: Event) -> Bool {
        return ComparisonResult.orderedAscending == lhs.date.compare(rhs.date)
    }
}
