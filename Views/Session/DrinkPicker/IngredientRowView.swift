//
//  IngredientRowView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 18/7/2025.
//

import SwiftUI

struct IngredientRowView: View {
    var Ingredient: DrinkIngredient
    var body: some View {
        HStack {
            VStack {
                Text(Ingredient.name)
                    .fontWeight(.bold)
            }
            Spacer()
            VStack {
                Text(String(format: "%.1f%% sugar", Ingredient.sugarPercent))
                Spacer()
                Text(String(format: "%.1f%% ABV", Ingredient.ABV))
            }
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    IngredientRowView(Ingredient: .Sample)
}
