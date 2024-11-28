//
//  IngredientForm.swift
//  SwiftBites
//
//  Created by Shubham Tripathi on 21/07/24.
//

import SwiftUI

struct IngredientForm: View {
    enum Mode: Hashable {
        case add
        case edit(Ingredient)
    }
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNameFocused: Bool
    @State private var name: String
    
    private var title: String
    var mode: Mode
    
    init(mode: Mode) {
        self.mode = mode
        switch self.mode {
        case .add:
            title = "Add Ingredient"
            _name = .init(initialValue: "")
        case .edit(let ingredient):
            title = "Edit \(ingredient.name)"
            _name = .init(initialValue: ingredient.name)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .focused($isNameFocused)
            }
            if case .edit(let ingredient) = mode {
                Button(
                    role: .destructive,
                    action: {
                        delete(ingredient: ingredient)
                    },
                    label: {
                        Text("Delete Ingredient")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                )
            }
        }
        .onAppear {
            isNameFocused = true
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: save)
                    .disabled(name.isEmpty)
            }
        }
    }
    
    // MARK: - Data
    
    private func delete(ingredient: Ingredient) {
        context.delete(ingredient)
        dismiss()
    }
    
    private func save() {
        switch self.mode {
        case .add:
            context.insert(Ingredient(name: name))
        case .edit(let ingredient):
            ingredient.name = name
            context.insert(ingredient)
        }
        dismiss()
    }
}

//#Preview {
//    IngredientForm()
//}
