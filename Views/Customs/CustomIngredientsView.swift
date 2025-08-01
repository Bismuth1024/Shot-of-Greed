//
//  CustomDrinksView.swift
//  Yesh
//
//  Created by Manith Kha on 18/1/2024.
//

import SwiftUI
import Sliders

struct CustomIngredientsView: View {
    @EnvironmentObject var Manager: SessionManager
    @State var SelectedIngredient: DrinkIngredient? = nil
    @State var requestingUpdate: Bool = false
    @State var showingEditor: Bool = false
    @State var SearchResults: [DrinkIngredient] = []

    var body: some View {
        Form {
            Section("Search") {
                IngredientSearcherView(updateRequested: $requestingUpdate) { QueryParams in
                    refreshResults(QueryParams: QueryParams)
                }
                Button("Refresh") {
                    requestingUpdate = true
                }
            }
            Section {
                ForEach(SearchResults) { ingredient in
                    NavigationLink(destination: EditIngredientView(ingredient)) {
                        IngredientRowView(Ingredient: ingredient)
                    }
                }
            } header: {
                HStack {
                    Text("Ingredients")
                    Spacer()
                    NavigationLink("New") {
                        EditIngredientView(nil)
                    }
                }
            }
        }

    }
    
    func refreshResults(QueryParams: IngredientQueryParams) {
        var ModifiedQuery = QueryParams
        ModifiedQuery.includePublic = true
        API.getIngredients(authSession: Manager.CurrentLoginSession!, using: ModifiedQuery) { result in
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

#Preview {
    CustomIngredientsView()
}
