//
//  EditIngredientView.swift
//  Yesh
//
//  Created by Manith Kha on 22/1/2024.
//

import SwiftUI

struct EditIngredientView: View {
    @State var update = false
    @State var ingredient: DrinkIngredient = .Sample
    @State var oldName: String = ""
    @State var confirmingDelete = false
    @State var isNameCollision = false

    var body: some View {
        Form {
            Section {
                    TextField("Name", text: $ingredient.name)
                } header: {
                    Text("Name")
                }
                        
            /*
            Section {
                    HStack {
                        Picker("Image", selection: $drink.imageName) {
                            ForEach(AlcoholicDrink.ImageNames, id: \.self) {name in
                                Text(name).tag(name)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .labelsHidden()
                        
                        Spacer()
                        
                        ResizeableImageView(imageName: drink.imageName, width: 100, height: 100)
                    }
                } header: {
                    Text("Image")
            }
             */
            
            Section {
                TagEditor(object: $ingredient, type: "Ingredient")

            } header: {
                Text("Tags")
            }
            
            Section {
                OptionalTextField("Description (optional)", text: $ingredient.description)
            }
            
            Section {
                InputSlider(name: "ABV", value: $ingredient.ABV, min: 0.0, max: 100.0, step: 0.1, nSigFigs: 4)
                InputSlider(name: "Sugar percentage", value: $ingredient.sugarPercent, min: 0.0, max: 100.0, step: 0.1, nSigFigs: 3)
            } header: {
                Text("")
            }
            
            Section(
                content: {
                    HStack {
                        SafeButton("Delete") {
                            confirmingDelete.toggle()
                        }
                        .foregroundStyle(.red)
                        Spacer()
                        SafeButton("Save") {
                            do {
                                let data = try JSONEncoder().encode(ingredient)
                                print(String(data: data, encoding: .utf8)!)
                            } catch {
                                print(error)
                            }
                        }
                        .foregroundStyle(.blue)
                    }
                },
                header: {
                    
                }
            )
            .alert("", isPresented: $confirmingDelete, actions: {
                Button("Delete", role: .destructive) {
                    deleteIngredient()
                }
            }, message: {
                Text("Delete this drink?")
            })
            
        }
        .alert("", isPresented: $isNameCollision, actions: {
            Button("Overwrite", role: .destructive) {
                saveIngredient()
            }
        }, message: {
            Text("An ingredient already exists with that name.  Would you like to overwrite this drink?")
        })
        .onAppear {
            oldName = ingredient.name
        }
    }
    
    func deleteIngredient() {

    }
    
    func saveIngredient() {
        
    }
    
    func checkName() {
        
    }
}

#Preview {
    EditIngredientView()
}
