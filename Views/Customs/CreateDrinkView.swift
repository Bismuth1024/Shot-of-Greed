//
//  CreateDrinkView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 23/7/2025.
//

import SwiftUI

struct CreateDrinkView: View {
    @Environment(\.dismiss) private var dismiss
    @State var Drink: AlcoholicDrink = .Sample

    var body: some View {
        Form {
            Section("Info") {
                TextField("Name", text: $Drink.name)
                OptionalTextField("Description", text: $Drink.description)
            }
            
            Section("Tags") {
                TagEditor(object: $Drink)
            }
            
            Section {
                DrinkIngredientsList(Drink: $Drink, editable: true)
            } header: {
                HStack {
                    Text("Ingredients")
                    Spacer()
                    Button("Add") {
                    }
                }
            }
        }
    }
}

#Preview {
    CreateDrinkView()
}
