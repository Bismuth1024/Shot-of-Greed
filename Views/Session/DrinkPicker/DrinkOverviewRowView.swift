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
                Text("\(drink.n_ingredients)")
            }
            VStack {
                Text("\(drink.n_standards)")
                Text("\(drink.sugar_g)")
            }
        }
    }
}

#Preview {
    DrinkOverviewRowView(drink: AlcoholicDrinkOverview(drink: AlcoholicDrink.Sample))
}
