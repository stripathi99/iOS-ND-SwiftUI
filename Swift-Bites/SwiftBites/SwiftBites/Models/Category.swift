//
//  Category.swift
//  SwiftBites
//
//  Created by Shubham Tripathi on 21/07/24.
//

import Foundation
import SwiftData

@Model
final class Category: Identifiable, Hashable {
    let id: UUID
    
    @Attribute(.unique) var name: String
    
    @Relationship(deleteRule: .nullify, inverse: \Recipe.category)
    var recipes: [Recipe]
    
    init(id: UUID = UUID(), name: String = "", recipes: [Recipe] = []) {
        self.id = id
        self.name = name
        self.recipes = recipes
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
