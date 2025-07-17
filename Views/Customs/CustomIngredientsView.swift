//
//  CustomDrinksView.swift
//  Yesh
//
//  Created by Manith Kha on 18/1/2024.
//

import SwiftUI
import Sliders

struct CustomIngredientsView: View {
    @State var dummyIngredient = DrinkIngredient(id: 0, name: "", ABV: 0.0, sugarPercent: 0.0, tags: [])
    @State var searchText: String = ""
    @State var Ingredients : [DrinkIngredient] = []
    @State var ABVRange = 0...100.0
    @State var minABV = 0.0
    @State var maxABV = 100.0
    @State var minSugar = 0.0
    @State var maxSugar = 100.0
    @State var minDate = Date(timeIntervalSince1970: 0)
    @State var maxDate = Date.now
    
    var searchResults: [DrinkIngredient] {
        var filteredIngredients = Ingredients
        
        for tag in dummyIngredient.tags {
            filteredIngredients = filteredIngredients.filter({$0.hasTag(tag)})
        }
        
        if searchText.isEmpty {
            return filteredIngredients
        } else {
            return filteredIngredients.filter({$0.name.contains(searchText)})
        }
    }
    
    var body: some View {
        Form {
            
            Section {
                TagEditor(object: $dummyIngredient, type: "Ingredient")
            } header: {
                Text("Tags")
            }
            
            Section("filter") {
                InputSlider(name: "Minimum ABV", value: $minABV, min: 0.0, max: 100.0, step: 0.1, nSigFigs: 3)
                InputSlider(name: "Maximum ABV", value: $maxABV, min: 0.0, max: 100.0, step: 0.1, nSigFigs: 3)
                InputSlider(name: "Minimum sugar", value: $minSugar, min: 0.0, max: 100.0, step: 0.1, nSigFigs: 3)
                InputSlider(name: "Maximum sugar", value: $maxSugar, min: 0.0, max: 100.0, step: 0.1, nSigFigs: 3)
                DatePicker(
                    "Earliest creation date",
                    selection: $minDate,
                    in: Date.distantPast...Date.now,
                    displayedComponents: [.date]
                )
                DatePicker(
                    "Latest creation date",
                    selection: $maxDate,
                    in: Date.distantPast...Date.now,
                    displayedComponents: [.date]
                )
                
            }
            
            Section {
                Button("Refresh") {
                    refreshResults()
                }
            }
            
            Section {
                List {
                    ForEach(searchResults) {ingredient in
                        HStack {
                            CustomNavigationLink(ingredient.name, value: ingredient)
                        }
                    }
                    
                }
            } header: {
                Text("Ingredients")
            }
        }
        .onChange(of: minABV) {
            maxABV = max(maxABV, minABV)
        }
        .onChange(of: maxABV) {
            minABV = min(maxABV, minABV)
        }
        .onChange(of: minSugar) {
            maxSugar = max(maxSugar, minSugar)
        }
        .onChange(of: maxSugar) {
            minSugar = min(maxSugar, minSugar)
        }
        .onAppear {
         
        }
        .navigationDestination(for: DrinkIngredient.self) { ingredient in
            EditIngredientView(ingredient: ingredient)
                .navigationTitle("Edit Ingredient")
            
        }
        
    }
    
    func refreshResults() {
        /*
        API.getIngredients(authSession: CurrentAppSession, userID: CurrentAppSession.currentUser!, minABV: minABV, maxABV: maxABV, minSugar: minSugar, maxSugar: maxSugar, minDate: minDate, maxDate: maxDate) {response in
            switch response {
            case .failure(let error):
                print(error)
            case .success(let ingredients):
                Ingredients = ingredients.ingredients
                print(Ingredients)
            }
        }
         */
    }
}

#Preview {
    CustomIngredientsView()
}
