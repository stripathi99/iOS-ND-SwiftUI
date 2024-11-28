//
//  CategoriesView.swift
//  SwiftBites
//
//  Created by Shubham Tripathi on 21/07/24.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: [SortDescriptor(\Category.name, order: .forward)])
    private var categories: [Category]
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Categories")
                .toolbar {
                    if !categories.isEmpty {
                        NavigationLink(value: CategoryForm.Mode.add) {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                .navigationDestination(for: CategoryForm.Mode.self) { mode in
                  CategoryForm(mode: mode)
                }
                .navigationDestination(for: RecipeForm.Mode.self) { mode in
                  RecipeForm(mode: mode)
                }
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var content: some View {
        if categories.isEmpty {
            empty
        } else {
            ScrollView(.vertical) {
                if filteredCategories.isEmpty {
                    noResults
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(categories, content: CategorySection.init)
                    }
                }
            }
            .searchable(text: $searchText)
        }
    }
    
    private var empty: some View {
        ContentUnavailableView(
            label: {
                Label("No Categories", systemImage: "list.clipboard")
            },
            description: {
                Text("Categories you add will appear here.")
            },
            actions: {
                NavigationLink("Add Categories", value: CategoryForm.Mode.add)
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
    
    private var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter {
                $0.name.localizedStandardContains(searchText)
            }
        }
    }
}
