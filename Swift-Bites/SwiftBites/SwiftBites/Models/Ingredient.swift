//
//  Ingredient.swift
//  SwiftBites
//
//  Created by Shubham Tripathi on 21/07/24.
//

import Foundation
import SwiftData

@Model
final class Ingredient: Identifiable, Hashable {
    let id: UUID
    
    @Attribute(.unique) var name: String
    
    init(id: UUID = UUID(), name: String = "") {
        self.id = id
        self.name = name
    }
    
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
