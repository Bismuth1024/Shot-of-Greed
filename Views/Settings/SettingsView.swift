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
                Section("") {
                    NavigationLink("BAC Settings") {
                        BACSettingsView()
                    }
                }
                
                Section("") {
                    NavigationLink("Custom Ingredients") {
                        CustomIngredientsView()
                    }
                }
                
                Section("") {
                    NavigationLink("Custom Drinks") {
                        CustomDrinksView()
                    }
                }
                
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
