//
//  CategoryForm.swift
//  SwiftBites
//
//  Created by Shubham Tripathi on 21/07/24.
//

import SwiftUI

struct CategoryForm: View {
    enum Mode: Hashable {
        case add
        case edit(Category)
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
            title = "Add Category"
            _name = .init(initialValue: "")
        case .edit(let category):
            title = "Edit \(category.name)"
            _name = .init(initialValue: category.name)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .focused($isNameFocused)
            }
            if case .edit(let category) = mode {
                Button(
                    role: .destructive,
                    action: {
                        delete(category: category)
                    },
                    label: {
                        Text("Delete Category")
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
                    }
                )
            }
        }
        .onAppear{
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
    
    private func delete(category: Category) {
        context.delete(category)
        dismiss()
    }
    
    private func save() {
        switch self.mode {
        case .add:
            context.insert(Category(name: name))
        case .edit(let category):
            category.name = name
            context.insert(category)
        }
        dismiss()
    }
}

//#Preview {
//    CategoryForm()
//}
