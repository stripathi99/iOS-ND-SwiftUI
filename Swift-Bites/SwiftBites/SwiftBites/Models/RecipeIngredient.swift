//
//  RecipeIngredient.swift
//  SwiftBites
//
//  Created by Shubham Tripathi on 21/07/24.
//

import Foundation
import SwiftData

@Model
final class RecipeIngredient: Identifiable, Hashable {
    let id: UUID
    
    @Relationship(deleteRule: .cascade, inverse: \Recipe.ingredients)
    var recipe: Recipe?
    
    @Relationship(deleteRule: .nullify)
    var ingredient: Ingredient
    
    var quantity: String
    
    init(id: UUID = UUID(), ingredient: Ingredient = Ingredient(), quantity: String = "") {
        self.id = id
        self.ingredient = ingredient
        self.quantity = quantity
    }
    
    static func == (lhs: RecipeIngredient, rhs: RecipeIngredient) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
