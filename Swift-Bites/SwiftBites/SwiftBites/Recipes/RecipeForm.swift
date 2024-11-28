//
//  RecipeForm.swift
//  SwiftBites
//
//  Created by Shubham Tripathi on 21/07/24.
//

import SwiftUI
import PhotosUI
import SwiftData

struct RecipeForm: View {
    enum Mode: Hashable {
        case add
        case edit(Recipe)
    }
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var summary: String
    @State private var serving: Int
    @State private var time: Int
    @State private var instructions: String
    @State private var categoryId: Category.ID?
    @State private var recipeIngredients: [RecipeIngredient]
    @State private var imageItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isIngredientsPickerPresented =  false
    
    @Query private var categories: [Category]
    
    var mode: Mode
    private var title: String
    
    init(mode: Mode) {
        self.mode = mode
        switch self.mode {
        case .add:
            title = "Add Recipe"
            _name = .init(initialValue: "")
            _summary = .init(initialValue: "")
            _serving = .init(initialValue: 1)
            _time = .init(initialValue: 5)
            _instructions = .init(initialValue: "")
            _recipeIngredients = .init(initialValue: [])
        case .edit(let recipe):
            title = "Edit \(recipe.name)"
            _name = .init(initialValue: recipe.name)
            _summary = .init(initialValue: recipe.summary)
            _serving = .init(initialValue: recipe.serving)
            _time = .init(initialValue: recipe.time)
            _instructions = .init(initialValue: recipe.instructions)
            _recipeIngredients = .init(initialValue: recipe.ingredients ?? [])
            _categoryId = .init(initialValue: recipe.category?.id)
            _imageData = .init(initialValue: recipe.imageData)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            Form {
                imageSection(width: geometry.size.width)
                nameSection
                categorySection
                summarySection
                ingredientsSection
                servingAndTimeSection
                instructionsSection
                deleteButton
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: save)
                    .disabled(name.isEmpty || instructions.isEmpty)
            }
        }
        .onChange(of: imageItem) { _, _ in
            Task {
                self.imageData = try? await imageItem?.loadTransferable(type: Data.self)
            }
        }
        .sheet(isPresented: $isIngredientsPickerPresented, content: ingredientPicker)
    }
    
    // MARK: - Views
    
    private func ingredientPicker() -> some View {
        IngredientsView { selectedIngredient in
            print(selectedIngredient.name)
            let recipeIngredient = RecipeIngredient(ingredient: selectedIngredient, quantity: "")
            context.insert(recipeIngredient)
            recipeIngredients.append(recipeIngredient)
        }
    }
    
    @ViewBuilder
    private func imageSection(width: CGFloat) -> some View {
        Section {
            imagePicker(width: width)
            removeImage
        }
    }
    
    @ViewBuilder
    private func imagePicker(width: CGFloat) -> some View {
        PhotosPicker(selection: $imageItem, matching: .images) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width)
                    .clipped()
                    .listRowInsets(EdgeInsets())
                    .frame(maxWidth: .infinity, minHeight: 200, idealHeight: 200, maxHeight: 200, alignment: .center)
            } else {
                Label("Select Image", systemImage: "photo")
            }
        }
    }
    
    @ViewBuilder
    private var removeImage: some View {
        if imageData != nil {
            Button(
                role: .destructive,
                action: {
                    imageData = nil
                },
                label: {
                    Text("Remove Image")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            )
        }
    }
    
    @ViewBuilder
    private var nameSection: some View {
        Section("Name") {
            TextField("Margherita Pizza", text: $name)
        }
    }
    
    @ViewBuilder
    private var categorySection: some View {
        Section {
            Picker("Category", selection: $categoryId) {
                Text("None").tag(nil as Category.ID?)
                ForEach(categories) { category in
                    Text(category.name).tag(category.id as Category.ID?)
                }
            }
        }
    }
    
    @ViewBuilder
    private var summarySection: some View {
        Section("Summary") {
            TextField(
                "Delicious blend of fresh basil, mozzarella, and tomato on a crispy crust.",
                text: $summary,
                axis: .vertical
            )
            .lineLimit(3...5)
        }
    }
    
    @ViewBuilder
    private var ingredientsSection: some View {
        Section("Ingredients") {
            if recipeIngredients.isEmpty {
                ContentUnavailableView(
                    label: {
                        Label("No Ingredients", systemImage: "list.clipboard")
                    },
                    description: {
                        Text("Recipe ingredients will appear here.")
                    },
                    actions: {
                        Button("Add Ingredient") {
                            isIngredientsPickerPresented = true
                        }
                    }
                )
            } else {
                ForEach(recipeIngredients) { ingredient in
                    HStack(alignment: .center) {
                        Text(ingredient.ingredient.name)
                            .bold()
                            .layoutPriority(2)
                        Spacer()
                        TextField("Quantity", text: .init(
                            get: {
                                ingredient.quantity
                            },
                            set: { quantity in
                                if let index = recipeIngredients.firstIndex(where: { $0.id == ingredient.id }) {
                                    recipeIngredients[index].quantity = quantity
                                }
                            }
                        ))
                        .layoutPriority(1)
                    }
                }
                .onDelete(perform: deleteIngredients)
                
                Button("Add Ingredient") {
                    isIngredientsPickerPresented = true
                }
            }
        }
    }
    
    @ViewBuilder
    private var servingAndTimeSection: some View {
        Section {
            Stepper("Servings: \(serving)p", value: $serving, in: 1...100)
            Stepper("Time: \(time)m", value: $time, in: 5...300, step: 5)
        }
        .monospacedDigit()
    }
    
    @ViewBuilder
    private var instructionsSection: some View {
        Section("Instructions") {
            TextField(
          """
          1. Preheat the oven to 475°F (245°C).
          2. Roll out the dough on a floured surface.
          3. ...
          """,
          text: $instructions,
          axis: .vertical
            )
            .lineLimit(8...12)
        }
    }
    
    @ViewBuilder
    private var deleteButton: some View {
        if case .edit(let recipe) = mode {
            Button(
                role: .destructive,
                action: {
                    delete(recipe: recipe)
                },
                label: {
                    Text("Delete Recipe")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            )
        }
    }
    
    // MARK: - Data
    
    func deleteIngredients(offsets: IndexSet) {
        withAnimation {
            recipeIngredients.remove(atOffsets: offsets)
        }
    }
    
    private func delete(recipe: Recipe) {
        guard case .edit(let recipe) = mode else {
            fatalError("Delete unavailable in add mode")
        }
        
        context.delete(recipe)
        dismiss()
    }
    
    private func save() {
        let category = categories.first(where: {$0.id == categoryId})
        switch self.mode {
        case .add:
            let recipe = Recipe(name: name, summary: summary, category: category,
                time: time, instructions: instructions, imageData: imageData)
            context.insert(recipe)
            recipe.ingredients = recipeIngredients
        case .edit(let recipe):
            recipe.name = name
            recipe.summary = summary
            recipe.category = category
            recipe.serving = serving
            recipe.time = time
            recipe.ingredients = recipeIngredients
            recipe.instructions = instructions
            recipe.imageData = imageData
            category?.recipes.append(recipe)
            context.insert(recipe)
        }
        print("recipe saved")
        dismiss()
    }
}
