//
//  RecipesView.swift
//  SwiftBites
//
//  Created by Shubham Tripathi on 21/07/24.
//

import SwiftUI
import SwiftData

struct RecipesView: View {
    @Environment(\.modelContext) private var context
    
    @Query private var recipes: [Recipe]
    
    @State private var searchText = ""
    @State private var sortOrder = SortDescriptor(\Recipe.name)
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Recipes")
                .toolbar {
                    if !recipes.isEmpty {
                        sortOptions
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink(value: RecipeForm.Mode.add) {
                                Label("Add", systemImage: "plus")
                            }
                        }
                    }
                }
                .navigationDestination(for: RecipeForm.Mode.self) { mode in
                    RecipeForm(mode: mode)
                }
        }
    }
    
    // MARK: - Views
    
    @ToolbarContentBuilder
    var sortOptions: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Picker("Sort", selection: $sortOrder) {
                    Text("Name")
                        .tag(SortDescriptor(\Recipe.name))
                    
                    Text("Serving (low to high)")
                        .tag(SortDescriptor(\Recipe.serving, order: .forward))
                    
                    Text("Serving (high to low)")
                        .tag(SortDescriptor(\Recipe.serving, order: .reverse))
                    
                    Text("Time (short to long)")
                        .tag(SortDescriptor(\Recipe.time, order: .forward))
                    
                    Text("Time (long to short)")
                        .tag(SortDescriptor(\Recipe.time, order: .reverse))
                }
            }
            .pickerStyle(.inline)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if recipes.isEmpty {
            empty
        } else {
            ScrollView(.vertical) {
                if filteredRecipes.isEmpty {
                    noResults
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredRecipes, content: RecipeCell.init)
                    }
                }
            }
            .searchable(text: $searchText)
        }
    }
    
    var empty: some View {
        ContentUnavailableView(
            label: {
                Label("No Recipes", systemImage: "list.clipboard")
            },
            description: {
                Text("Recipes you add will appear here.")
            },
            actions: {
                NavigationLink("Add Recipe", value: RecipeForm.Mode.add)
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
    }
    
    // MARK: - Data
    
    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return recipes.sorted(using: sortOrder)
        } else {
            return recipes.filter {
                $0.name.localizedStandardContains(searchText) || $0.summary.localizedStandardContains(searchText)
            }.sorted(using: sortOrder)
        }
    }
}

//#Preview {
//    RecipesView()
//}
