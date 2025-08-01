//
//  AddDrinkView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 17/7/2025.
//

import SwiftUI

struct AddDrinkView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var Manager: SessionManager
    @State var isSelectingDrink: Bool = false //For the new popup to open SelectDrinkView
    @State var isSavingDrink: Bool = false //For saving the drink as a preset
    @State var Drink: AlcoholicDrink = AlcoholicDrink.Sample
    @State var quantity: Int = 1
    @State var drinkingMethod: AlcoholicDrink.DrinkingMethod = .chug
    @State var time: Date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Drink") {
                    HStack {
                        NavigationLink(destination: SelectDrinkView(drink: $Drink)) {
                            Text(Drink.name)
                        }
                    }
                }
                
                Section("Ingredients") {
                    DisclosureGroup("Show/Hide") {
                        DrinkIngredientsList(Drink: $Drink)
                    }
                }
                
                Section("Quantity") {
                    Stepper(value: $quantity, in: 1...10) {
                        Text("Quantity: \(quantity)")
                    }
                }
                
                Section("Add as a") {
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
                            addDrink()
                            dismiss()
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
        .navigationTitle("Add Drink")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func addDrink() {
        var WrappedDrink = DrinkingSession.SessionDrinkWrapper(drink: Drink, quantity: quantity, startTime: time, endTime: drinkingMethod == .chug ? time : nil)
        let request = SessionDrinksPostRequest(from: WrappedDrink)
        API.addDrinkToSession(authSession: Manager.CurrentLoginSession!, sessionID: Manager.CurrentDrinkingSession!.id, with: request) { result in
            switch result {
            case .failure(let error):
                fatalError(String(describing: error))
            case .success(let response):
                DispatchQueue.main.async {
                    WrappedDrink.id = response.new_pairing_id
                    Manager.CurrentDrinkingSession!.addDrink(WrappedDrink)
                    for wrapper in Manager.CurrentDrinkingSession!.drinks {
                        print(wrapper.description())
                    }
                }
            }
            
        }
    }
    
    func d() {}
}

#Preview {
    AddDrinkView()
}
