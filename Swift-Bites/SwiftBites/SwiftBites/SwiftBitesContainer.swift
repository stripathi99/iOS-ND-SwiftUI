//
//  SwiftBitesContainer.swift
//  SwiftBites
//
//  Created by Shubham Tripathi on 21/07/24.
//

import Foundation
import SwiftData
import UIKit

class SwiftBitesContainer {
    
    @MainActor
    static func create() -> ModelContainer {
        let schema = Schema([Ingredient.self, Category.self, RecipeIngredient.self, Recipe.self])
        let configuration = ModelConfiguration()
        let container = try! ModelContainer(for: schema, configurations: configuration)
        
        if isEmptyIngredients(context: container.mainContext) {
            sampleIngredients().forEach { ingredient in
                container.mainContext.insert(ingredient)
            }
        }
        
        if isEmptyCategories(context: container.mainContext) {
            sampleCategories().forEach { category in
                container.mainContext.insert(category)
            }
        }
        
        if isEmptyRecipes(context: container.mainContext) {
            sampleRecipes().forEach { recipe in
                container.mainContext.insert(recipe)
            }
        }
        
        print("recipe ingredients -> \(isEmptyRecipeIngredients(context: container.mainContext))")
        
        return container
    }
    
    private static func isEmptyIngredients(context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Ingredient>()
        
        do {
            let existingNotes = try context.fetch(descriptor)
            return existingNotes.isEmpty
        } catch {
            return false
        }
    }
    
    private static func isEmptyCategories(context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Category>()
        
        do {
            let existingNotes = try context.fetch(descriptor)
            return existingNotes.isEmpty
        } catch {
            return false
        }
    }
    
    private static func isEmptyRecipes(context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Recipe>()
        
        do {
            let existingNotes = try context.fetch(descriptor)
            return existingNotes.isEmpty
        } catch {
            return false
        }
    }
    
    private static func isEmptyRecipeIngredients(context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<RecipeIngredient>(predicate: #Predicate<RecipeIngredient>{
            $0.recipe == nil
        })
        
        do {
            let existingRecipeIngredient = try context.fetch(descriptor)
            return existingRecipeIngredient.isEmpty
        } catch {
            return false
        }
    }
    
    // MARK: - Load
    
    private static func sampleRecipes() -> [Recipe] {
        return [
            Recipe(
                name: "Classic Margherita Pizza",
                summary: "A simple yet delicious pizza with tomato, mozzarella, basil, and olive oil.",
                category: nil,
                serving: 2,
                time: 50,
                instructions: "Preheat oven, roll out dough, apply sauce, add cheese and basil, bake for 20 minutes.",
                imageData: UIImage(named: "margherita")?.pngData()
            ),
            Recipe(
                name: "Spaghetti Carbonara",
                summary: "A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.",
                category: nil,
                serving: 4,
                time: 30,
                instructions: "Cook spaghetti. Fry pancetta until crisp. Whisk eggs and Parmesan, add to pasta with pancetta, and season with black pepper.",
                imageData: UIImage(named: "spaghettiCarbonara")?.pngData()
            ),
            Recipe(
                name: "Classic Hummus",
                summary: "A creamy and flavorful Middle Eastern dip made from chickpeas, tahini, and spices.",
                category: nil,
                serving: 6,
                time: 10,
                instructions: "Blend chickpeas, tahini, lemon juice, garlic, and spices. Adjust consistency with water. Garnish with olive oil, paprika, and parsley.",
                imageData: UIImage(named: "hummus")?.pngData()
            )
        ]
    }
    
    private static func sampleRecipeIngredients() -> [RecipeIngredient] {
        return [
            RecipeIngredient(ingredient: sampleIngredients()[1], quantity: ""),
            RecipeIngredient(ingredient: sampleIngredients()[2], quantity: ""),
            RecipeIngredient(ingredient: sampleIngredients()[3], quantity: "")
        ]
    }
    
    private static func sampleCategories() -> [Category] {
        return [
            Category(name: "Italian"),
            Category(name: "Indian"),
            Category(name: "Middle Eastern"),
            Category(name: "Chinese")
        ]
    }
    
    private static func sampleIngredients() -> [Ingredient] {
        return [
            Ingredient(name: "Pizza Dough"),
            Ingredient(name: "Tomato Sauce"),
            Ingredient(name: "Mozzarella Cheese"),
            Ingredient(name: "Fresh Basil Leaves"),
            Ingredient(name: "Extra Virgin Olive Oil"),
            Ingredient(name: "Salt"),
            Ingredient(name: "Chickpeas"),
            Ingredient(name: "Tahini"),
            Ingredient(name: "Lemon Juice"),
            Ingredient(name: "Garlic"),
            Ingredient(name: "Cumin"),
            Ingredient(name: "Water"),
            Ingredient(name: "Paprika"),
            Ingredient(name: "Parsley"),
            Ingredient(name: "Spaghetti"),
            Ingredient(name: "Eggs"),
            Ingredient(name: "Parmesan Cheese"),
            Ingredient(name: "Pancetta"),
            Ingredient(name: "Black Pepper"),
            Ingredient(name: "Dried Chickpeas"),
            Ingredient(name: "Onions"),
            Ingredient(name: "Cilantro"),
            Ingredient(name: "Coriander"),
            Ingredient(name: "Baking Powder"),
            Ingredient(name: "Chicken Thighs"),
            Ingredient(name: "Yogurt"),
            Ingredient(name: "Cardamom"),
            Ingredient(name: "Cinnamon"),
            Ingredient(name: "Turmeric")
        ]
    }
}
