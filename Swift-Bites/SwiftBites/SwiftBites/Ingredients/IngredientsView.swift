//
//  IngredientsView.swift
//  SwiftBites
//
//  Created by Shubham Tripathi on 21/07/24.
//

import SwiftUI
import SwiftData

struct IngredientsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: [SortDescriptor(\Ingredient.name, order: .forward)])
    private var ingredients: [Ingredient]
    
    @State private var searchText = ""
    
    typealias Selection = (Ingredient) -> Void
    
    let selection: Selection?
    
    init(selection: Selection? = nil) {
        self.selection = selection
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Ingredients")
                .toolbar {
                    if !ingredients.isEmpty{
                        NavigationLink(value: IngredientForm.Mode.add) {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                .navigationDestination(for: IngredientForm.Mode.self) { mode in
                    IngredientForm(mode: mode)
                }
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var content: some View {
        if ingredients.isEmpty {
            empty
        } else {
            list(for: filteredIngredients)
        }
    }
    
    private func list(for ingredients: [Ingredient]) -> some View {
        List {
            if ingredients.isEmpty {
                noResults
            } else {
                ForEach(ingredients) { ingredient in
                    row(for: ingredient)
                }.onDelete(perform: delete)
            }
        }
        .searchable(text: $searchText)
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private func row(for ingredient: Ingredient) -> some View {
        if let selection {
            Button(
                action: {
                    selection(ingredient)
                    dismiss()
                },
                label: {
                    title(for: ingredient)
                }
            )
        } else {
            NavigationLink(value: IngredientForm.Mode.edit(ingredient)) {
                title(for: ingredient)
            }
        }
    }
    
    private func title(for ingredient: Ingredient) -> some View {
        Text(ingredient.name)
            .font(.title3)
    }
    
    private var empty: some View {
        ContentUnavailableView(
            label: {
                Label("No Ingredients", systemImage: "list.clipboard")
            },
            description: {
                Text("Ingredients you add will appear here.")
            },
            actions: {
                NavigationLink("Add Ingredient", value: IngredientForm.Mode.add)
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(.borderedProminent)
            }
        )
    }
    
    private var noResults: some View {
        ContentUnavailableView(
            label: {
                Text("Couldn't find \"\(searchText)\"")
            }
        )
        .listRowSeparator(.hidden)
    }
    
    // MARK: - Data
    
    private var filteredIngredients: [Ingredient] {
        if searchText.isEmpty {
            return ingredients
        } else {
            return ingredients.filter {
                $0.name.localizedStandardContains(searchText)
            }
        }
    }
    
    private func delete(indexSet: IndexSet) {
        for idx in indexSet {
            context.delete(filteredIngredients[idx])
        }
    }
}
