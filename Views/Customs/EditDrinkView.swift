//
//  EditDrinkView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 24/7/2025.
//

import SwiftUI

struct EditDrinkView: View {
    @State var Drink: AlcoholicDrink
    @EnvironmentObject var Manager: SessionManager
    @Environment(\.dismiss) private var dismiss

    var title: String = "Edit Drink"
    
    init(Drink: AlcoholicDrink) {
        self.Drink = Drink
        self.title = "Edit Drink"
    }
    
    init(_ Drink: AlcoholicDrink?) {
        self.Drink = Drink ?? AlcoholicDrink()
        if (Drink == nil) {
            self.title = "Create Drink"
        }
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
            Form {
                Section("Info") {
                    TextField("Name", text: $Drink.name)
                    OptionalTextField("Description", text: $Drink.description)
                }
                Section("Tags") {
                    TagEditor(object: $Drink, LoadedTags: Manager.CurrentTagsManager.DrinkTags)
                }
                Section {
                    DrinkIngredientsList(Drink: $Drink)
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
        .onAppear {
            //if 
        }
    }
}

#Preview {
    EditDrinkView(nil)
}
