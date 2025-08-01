//
//  DrinkOverviewRowView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 18/7/2025.
//

import SwiftUI

struct DrinkOverviewRowView: View {
    var drink: AlcoholicDrinkOverview
    var body: some View {
        HStack {
            VStack {
                Text(drink.name)
                    .fontWeight(.bold)
            }
            Spacer()
            VStack {
                Text("\(drink.n_ingredients) ingredient" + ((drink.n_ingredients == 1) ? "" : "s"))
                Spacer()
                Text(String(format: "%.2f standard drinks", drink.n_standards))
                Spacer()
                Text(String(format: "%.2f g of sugar", drink.sugar_g))
            }
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    DrinkOverviewRowView(drink: AlcoholicDrinkOverview(drink: AlcoholicDrink.Sample))
}
