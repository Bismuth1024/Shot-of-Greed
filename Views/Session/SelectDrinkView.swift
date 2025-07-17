//
//  SelectDrinkView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 18/7/2025.
//

import SwiftUI

struct SelectDrinkView: View {
    @Binding var drink: AlcoholicDrink
    @State var SearchResults: [AlcoholicDrinkOverview] = []
    var body: some View {
        Form {
            Section("Name") {
                Button("Refresh") {
                    API.getDrinks(using: DrinkQueryParams()) { result in
                        switch result {
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        case .success(let response):
                            DispatchQueue.main.async {
                                SearchResults = response
                            }
                        }
                    }
                }
            }
            
            Section("Drinks") {
                ForEach(SearchResults) { overview in
                    DrinkOverviewRowView(drink: overview)
                }
            }
        }
    }
    
}

#Preview {
    SelectDrinkView(drink: .constant(AlcoholicDrink.Sample))
}
