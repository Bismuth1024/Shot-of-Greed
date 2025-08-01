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
 
 drinksearcherview with a binding to drinkqueryparams!!
 */

import SwiftUI

struct CustomDrinksView: View {
    @EnvironmentObject var Manager: SessionManager
    @State var requestingUpdate: Bool = false
    @State var showingEditor: Bool = false
    @State var SearchResults: [AlcoholicDrinkOverview] = []
    
    var body: some View {
        Form {
            Section("Search") {
                DrinkSearcherView(updateRequested: $requestingUpdate) { QueryParams in
                    refreshResults(QueryParams: QueryParams)
                }
                Button("Refresh") {
                    requestingUpdate = true
                }
            }
            
            Section {
                ForEach(SearchResults) { overview in
                    NavigationLink("Test") {
                        LazyLoadView(id: overview.id, loader: ({ id in
                            API.getDrink(authSession: Manager.CurrentLoginSession!, drinkID: id) { result in
                                switch result {
                                case .failure(let error):
                                    fatalError(String(describing: error))
                                case .success(let fetchedDrink):
                                    return fetchedDrink
                                }
                            }
                        })) { drink in
                            EditDrinkView(drink)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Drinks")
                    Spacer()
                    Button("New") {
                        //SelectedDrink = nil
                        showingEditor = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingEditor) {
            //EditDrinkView(SelectedDrink)
        }
    }
    
    func refreshResults(QueryParams: DrinkQueryParams) {
        var ModifiedQuery = QueryParams
        ModifiedQuery.includePublic = false
        API.getDrinks(authSession: Manager.CurrentLoginSession!, using: ModifiedQuery) { result in
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
    CustomDrinksView()
}
