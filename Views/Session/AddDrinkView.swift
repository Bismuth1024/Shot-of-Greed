//
//  AddDrinkView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 17/7/2025.
//

import SwiftUI

struct AddDrinkView: View {
    @Binding var isShowing: Bool //Because this window is a popup
    @State var isSelectingDrink: Bool = false //For the new popup to open SelectDrinkView
    @State var isSavingDrink: Bool = false //For saving the drink as a preset
    @State var drink: AlcoholicDrink = AlcoholicDrink.Sample
    @State var quantity: Int = 1
    @State var drinkingMethod: AlcoholicDrink.DrinkingMethod = .chug
    @State var time: Date = Date()
    
    var body: some View {
        Form {
            Section(
                content: {
                    HStack {
                        Text("drink.name")
                        Spacer()
                        Button("Change") {
                            isSelectingDrink.toggle()
                        }
                        .fullScreenCover(isPresented: $isSelectingDrink) {
                            NavigationStack {
                                SelectDrinkView(drink: $drink)
                            }
                        }
                    }
                },
                header: {
                    Text("Drink")
                }
            )
            
            //DrinkIngredientsList(drink: $drink)
            
            Section(
                content: {
                    Stepper(value: $quantity, in: 1...10) {
                        Text("Quantity: \(quantity)")
                    }
                    
                    
                    HStack {
                        Spacer()
                        Button("Save as a preset") {
                            isSavingDrink.toggle()
                        }
                        //.disabled(!drink.isValid())
                    }
                    .sheet(isPresented: $isSavingDrink) {
                        NavigationStack {
                            HistoryView()
                        }
                    }
                },
                header: {
                    Text("Quantity")
                }
            )
            
            Section(
                content: {
                    Picker("Drinking speed", selection: $drinkingMethod) {
                        Text("Shot/chug").tag(AlcoholicDrink.DrinkingMethod.chug)
                        Text("Slow (start now)").tag(AlcoholicDrink.DrinkingMethod.slow)
                    }
                    .pickerStyle(.segmented)
                    
                    HStack {
                        Text("\(drinkingMethod == .chug ? "at" : "starting at")")
                        Spacer()
                        DatePicker("Time", selection: $time, displayedComponents: [.hourAndMinute, .date])
                            .labelsHidden()
                    }
                    
                    HStack {
                        Spacer()
                        Button("Add") {
                            //addDrink()
                        }
                        //.disabled(!drink.isValid())
                    }
                },
                header: {
                    Text("Add as a:")
                }
            )
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(role: .destructive, action: {
                    isShowing = false
                }) {
                    Text("Cancel")
                }
            }
        }
    }
}

#Preview {
    AddDrinkView(isShowing: .constant(true))
}
