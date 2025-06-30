//
//  SettingsView.swift
//  Yesh
//
//  Created by Manith Kha on 12/1/2024.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        NavigationStack {
            Form {
                Section(
                    content: {
                        CustomNavigationLink("BAC Settings", value: CurrentViewWrapper.viewEnum.BACSettings)
                    }, header: {
                        Text("")
                    }
                )
                
                Section(
                    content: {
                        CustomNavigationLink("Custom Ingredients", value: CurrentViewWrapper.viewEnum.customIngredients)
                    }, header: {
                        
                    }
                )
                
                Section (
                    content: {
                        CustomNavigationLink("Custom Drinks", value: CurrentViewWrapper.viewEnum.customDrinks)
                    }, header: {
                        
                    }
                )
                
                Section {
                    Button("debug") {
                        do {

                        }
                        catch {
                            print(error)
                        }
                    }
                } header: {
                    
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(for: CurrentViewWrapper.viewEnum.self) {v in
                switch v {
                case .BACSettings:
                    BACSettingsView()
                        .navigationTitle("BAC Settings")
                case .customDrinks:
                    CustomDrinksView()
                        .navigationTitle("Custom Drinks")
                case .customIngredients:
                    CustomIngredientsView()
                        .navigationTitle("Custom Ingredients")
                default:
                    EmptyView()
                }
            }
            
        }
        /*
        .navigationDestination(for: AlcoholicDrink.self) { drink in
            EditDrinkView(drink: drink, isShowing: .constant(true))
                .navigationTitle("Edit drink")
        }
         */
    }
}

#Preview {
    SettingsView()
}
