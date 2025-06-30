//
//  CustomDrinksView.swift
//  Yesh
//
//  Created by Manith Kha on 18/1/2024.
//

/*
 to filter by tag, we re use the taggable protocol / tageditor.
 So we make a dummy drink, and add tags to this via tageditor
 then we filter drinks based on the tag
 
 
 We still have a question though, how much filtering/searching done by api/database?
 how much done by swift app??
 
 logically the point of the database is to allow all this filtering/searching
 
 but this requires another api call any time we update filters
 for now we will do filtering in app
 even though we have scope for filters in the
 */

import SwiftUI

struct CustomDrinksView: View {
    @State var dummyDrink = AlcoholicDrink(id: 0, name: "dummy", ingredients: [])
    @State var searchText = ""
    @State var Drinks : [AlcoholicDrink] = []
    
    var searchResults: [AlcoholicDrink] {
        var filteredDrinks = Drinks
        
        for tag in dummyDrink.tags {
            filteredDrinks = filteredDrinks.filter({$0.hasTag(tag)})
        }
        
        if searchText.isEmpty {
            return filteredDrinks
        } else {
            return filteredDrinks.filter({$0.name.contains(searchText)})
        }
    }
    
    var body: some View {
        Form {
            
            Section {
                TagEditor(object: $dummyDrink, type: "Drink", isSearchable: false)
            } header: {
                Text("Filter")
            }
            
            Section {
                List {
                    ForEach(searchResults) { drink in
                        HStack {
                            ResizeableImageView(imageName: "none", width: 60, height: 60)
                            Spacer()
                            CustomNavigationLink(drink.name, value: drink)
                        }
                        
                    }
                }
            } header: {
                HStack {
                    Text("Drinks")
                    Spacer()
                    NavigationLink(value: AlcoholicDrink.Sample) {
                        Text("New")
                    }
                }
            }
        }
        .navigationDestination(for: AlcoholicDrink.self) { drink in
            Text("test")
                .navigationTitle(drink == AlcoholicDrink.Sample ? "Edit drink" : "New drink")
        }
    }
}

#Preview {
    CustomDrinksView()
}
