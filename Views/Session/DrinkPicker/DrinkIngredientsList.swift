//
//  DrinkIngredientsList.swift
//  Shot of Greed
//
//  Created by Manith Kha on 18/7/2025.
//

import SwiftUI

struct DrinkIngredientsList: View {
    @Binding var Drink: AlcoholicDrink
    var editable: Bool = false
    var body: some View {
        ForEach(Drink.ingredients) { wrapper in
            IngredientWrapperRowView(Ingredient: wrapper)
        }
        .onDelete(perform: ingredientDeleted)
        .deleteDisabled(!editable)
        Text(String(format: "Total standards: %.2f, Total sugar: %.1fg", Drink.numStandards(), Drink.totalSugar()))
    }
    
    func ingredientDeleted(at offsets: IndexSet) {
        Drink.ingredients.remove(atOffsets: offsets)
    }

}

#Preview {
    DrinkIngredientsList(Drink: .constant(AlcoholicDrink.Sample))
}
