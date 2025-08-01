//
//  IngredientRowView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 18/7/2025.
//

import SwiftUI

struct IngredientWrapperRowView: View {
    var Ingredient: AlcoholicDrink.IngredientWrapper
    var body: some View {
        HStack {
            VStack {
                Text(Ingredient.ingredientType.name)
                    .fontWeight(.bold)
            }
            Spacer()
            VStack {
                Text(String(format: "%.1f mL", Ingredient.volume))
                Spacer()
                Text(String(format: "%.1f%% sugar", Ingredient.ingredientType.sugarPercent))
                Spacer()
                Text(String(format: "%.1f%% ABV", Ingredient.ingredientType.ABV))
            }
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    IngredientWrapperRowView(Ingredient: .Sample)
}
