//
//  EditIngredientView.swift
//  Yesh
//
//  Created by Manith Kha on 22/1/2024.
//

import SwiftUI

struct EditIngredientView: View {
    @State var Ingredient: DrinkIngredient
    @EnvironmentObject var Manager: SessionManager
    @Environment(\.dismiss) private var dismiss
    @FocusState var isFocused: Bool

    var title: String = "Edit Ingredient"
    
    init(Ingredient: DrinkIngredient) {
        self.Ingredient = Ingredient
        self.title = "Edit Drink"
    }
    
    init(_ Ingredient: DrinkIngredient?) {
        self.Ingredient = Ingredient ?? DrinkIngredient()
        if (Ingredient == nil) {
            self.title = "Create Ingredient"
        }
    }
    var body: some View {
        Form {
            Section("Info") {
                TextField("Name", text: $Ingredient.name)
                OptionalTextField("Description", text: $Ingredient.description)
            }
            Section("Tags") {
                DisclosureGroup("Show/hide") {
                    TagEditor(object: $Ingredient, LoadedTags: Manager.CurrentTagsManager.IngredientTags)
                }
            }
            Section("Parameters") {
                InputSlider(name: "ABV", value: $Ingredient.ABV, min: 0.0, max: 100.0, step: 0.01, nSigFigs: 3)
                InputSlider(name: "Sugar (%)", value: $Ingredient.sugarPercent, min: 0.0, max: 100.0, step: 0.01, nSigFigs: 3)
            }
            .focused($isFocused)
            
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isFocused = false
                }
            }
        }
        .keyboardType(.decimalPad)
    }
}

#Preview {
    EditIngredientView(nil)
}
